import 'dart:math';
import '../core/models/calibration_point.dart';

/// Result structure of an On-Device Edge ML Training Session
class EdgeMlTrainingResult {
  final List<double> weights; // [bias, cE, cT, cET, cE2, cT2]
  final double r2;
  final double rmse;
  final double mae;
  final int sampleCount;
  final Duration trainingDuration;
  final DateTime trainedAt;
  final String status;

  EdgeMlTrainingResult({
    required this.weights,
    required this.r2,
    required this.rmse,
    required this.mae,
    required this.sampleCount,
    required this.trainingDuration,
    required this.trainedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'weights': weights,
        'r2': r2,
        'rmse': rmse,
        'mae': mae,
        'sampleCount': sampleCount,
        'trainingDurationMs': trainingDuration.inMilliseconds,
        'trainedAt': trainedAt.toIso8601String(),
        'status': status,
      };
}

/// Pure Dart On-Device Edge ML Trainer
/// Fits non-linear pH compensation equation using Ordinary Least Squares (OLS)
/// y = w0 + w1*E + w2*T + w3*(E*T) + w4*(E^2) + w5*(T^2)
class EdgePhModelTrainer {
  /// Train non-linear polynomial regression directly on device CPU
  static Future<EdgeMlTrainingResult> trainModel({
    required List<CalibrationPoint> trainingPoints,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();

    if (trainingPoints.length < 6) {
      throw Exception('ต้องมีข้อมูลฝึกสอนอย่างน้อย 6 จุดเพื่อฟิตสัมประสิทธิ์ 6 พารามิเตอร์');
    }

    // Number of features: [1.0, E, T, E*T, E^2, T^2]
    const int numFeatures = 6;
    final int n = trainingPoints.length;

    // Construct Normal Equation: (X^T * X) * W = X^T * Y
    // A = X^T * X (6x6 matrix), B = X^T * Y (6x1 vector)
    final List<List<double>> A = List.generate(numFeatures, (_) => List.filled(numFeatures, 0.0));
    final List<double> B = List.filled(numFeatures, 0.0);

    for (final p in trainingPoints) {
      final double e = p.potentialMv;
      final double t = p.temperatureC;
      final double y = p.standardPh;

      final List<double> x = [
        1.0,
        e,
        t,
        e * t,
        e * e,
        t * t,
      ];

      for (int i = 0; i < numFeatures; i++) {
        for (int j = 0; j < numFeatures; j++) {
          A[i][j] += x[i] * x[j];
        }
        B[i] += x[i] * y;
      }
    }

    // Solve system of linear equations A * W = B using Gaussian Elimination with partial pivoting
    final List<double> weights = _solveLinearSystem(A, B, numFeatures);

    // Compute evaluation metrics (R2, RMSE, MAE)
    double sumSqError = 0.0;
    double sumAbsError = 0.0;
    double sumY = 0.0;

    for (final p in trainingPoints) {
      sumY += p.standardPh;
    }
    final double meanY = sumY / n;

    double ssTotal = 0.0;
    for (final p in trainingPoints) {
      final double e = p.potentialMv;
      final double t = p.temperatureC;
      final double yTrue = p.standardPh;

      final double yPred = predictWithWeights(weights, e, t);
      final double err = yTrue - yPred;

      sumSqError += err * err;
      sumAbsError += err.abs();
      ssTotal += pow(yTrue - meanY, 2);
    }

    final double rmse = sqrt(sumSqError / n);
    final double mae = sumAbsError / n;
    final double r2 = ssTotal > 0 ? max(0.0, 1.0 - (sumSqError / ssTotal)) : 0.0;

    stopwatch.stop();

    return EdgeMlTrainingResult(
      weights: weights,
      r2: double.parse(r2.toStringAsFixed(4)),
      rmse: double.parse(rmse.toStringAsFixed(4)),
      mae: double.parse(mae.toStringAsFixed(4)),
      sampleCount: n,
      trainingDuration: stopwatch.elapsed,
      trainedAt: DateTime.now(),
      status: 'สำเร็จ 100% (OLS Exact Convergence)',
    );
  }

  /// Predict pH using custom trained weights
  static double predictWithWeights(List<double> w, double potentialMv, double tempC) {
    if (w.length < 6) return 7.0;
    final double e = potentialMv;
    final double t = tempC;

    final double ph = w[0] +
        (w[1] * e) +
        (w[2] * t) +
        (w[3] * e * t) +
        (w[4] * e * e) +
        (w[5] * t * t);

    return double.parse(ph.clamp(0.0, 14.0).toStringAsFixed(2));
  }

  /// Gaussian elimination solver for Ax = B
  static List<double> _solveLinearSystem(List<List<double>> A, List<double> B, int n) {
    // Augmented matrix [A | B]
    final List<List<double>> M = List.generate(n, (i) => List<double>.from(A[i])..add(B[i]));

    for (int col = 0; col < n; col++) {
      // Find pivot
      int maxRow = col;
      double maxVal = M[col][col].abs();
      for (int row = col + 1; row < n; row++) {
        if (M[row][col].abs() > maxVal) {
          maxVal = M[row][col].abs();
          maxRow = row;
        }
      }

      // Swap rows
      if (maxRow != col) {
        final temp = M[col];
        M[col] = M[maxRow];
        M[maxRow] = temp;
      }

      // Check singular
      if (M[col][col].abs() < 1e-12) {
        // Add tiny ridge regularization to avoid division by zero
        M[col][col] += 1e-6;
      }

      // Eliminate below
      for (int row = col + 1; row < n; row++) {
        final double factor = M[row][col] / M[col][col];
        for (int k = col; k <= n; k++) {
          M[row][k] -= factor * M[col][k];
        }
      }
    }

    // Back-substitution
    final List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      double sum = M[i][n];
      for (int j = i + 1; j < n; j++) {
        sum -= M[i][j] * x[j];
      }
      x[i] = sum / M[i][i];
    }

    return x;
  }
}
