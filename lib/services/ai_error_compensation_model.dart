class AiErrorCompensationModel {
  // Pre-computed AI Model Coefficients (Default RBRU Research 2569 Baseline)
  // Inverse Non-linear Mapping: pH_predicted = g(E_real, T)
  // Trained via Multi-Layer Error Minimization on Standard Buffers (pH 4.01, 7.00, 10.01 @ 20-50°C)
  static const double cBias = 6.931715;
  static const double cE = -0.03481958;
  static const double cT = 0.00956416;
  static const double cET = -3.47704e-05;
  static const double cE2 = 7.53126e-06;
  static const double cT2 = -1.62641e-05;
  static const double cE2T = -7.34178e-07;
  static const double cE3 = 6.27303e-07;

  // Active On-Device Edge ML Custom Weights [w0, w1, w2, w3, w4, w5]
  static List<double>? _activeCustomWeights;

  static bool get isUsingCustomModel => _activeCustomWeights != null && _activeCustomWeights!.length >= 6;
  static List<double>? get activeCustomWeights => _activeCustomWeights;

  static void setCustomWeights(List<double>? weights) {
    _activeCustomWeights = weights;
  }

  static void resetToDefaultWeights() {
    _activeCustomWeights = null;
  }

  /// High-Accuracy AI Forward Inference: g(E_real, T) -> pH_predicted
  /// Resolves asymmetry potential, non-linear curvature, and temperature drift.
  static double predict({
    required double potentialMv,
    required double temperatureC,
  }) {
    final double e = potentialMv;
    final double t = temperatureC;

    // If edge model trained on-device is active, use custom weights
    if (isUsingCustomModel) {
      final w = _activeCustomWeights!;
      final double phCustom = w[0] +
          (w[1] * e) +
          (w[2] * t) +
          (w[3] * e * t) +
          (w[4] * e * e) +
          (w[5] * t * t);
      return double.parse(phCustom.clamp(0.0, 14.0).toStringAsFixed(2));
    }

    final double phPred = cBias +
        (cE * e) +
        (cT * t) +
        (cET * e * t) +
        (cE2 * e * e) +
        (cT2 * t * t) +
        (cE2T * e * e * t) +
        (cE3 * e * e * e);

    return double.parse(phPred.clamp(0.0, 14.0).toStringAsFixed(2));
  }

  /// Generate embeddable C++ code for flashing into ESP32 / Arduino Microcontroller
  static String generateCppArduinoCode() {
    final w0 = isUsingCustomModel ? _activeCustomWeights![0] : cBias;
    final w1 = isUsingCustomModel ? _activeCustomWeights![1] : cE;
    final w2 = isUsingCustomModel ? _activeCustomWeights![2] : cT;
    final w3 = isUsingCustomModel ? _activeCustomWeights![3] : cET;
    final w4 = isUsingCustomModel ? _activeCustomWeights![4] : cE2;
    final w5 = isUsingCustomModel ? _activeCustomWeights![5] : cT2;

    return '''
// ============================================================================
// SoilpHTxAI - Embedded AI Error Compensation Engine for ESP32 / Arduino
// Project: Development of a High-Accuracy Field-Portable Soil pH Meter Prototype
// Funding: Rambhai Barni Rajabhat University Research Fund 2569
// ============================================================================

#include <Arduino.h>
#include <math.h>

// AI Model Inverse Mapping Parameters ${isUsingCustomModel ? "(On-Device Trained)" : "(RBRU Baseline)"}
static const float C_BIAS = ${w0.toStringAsFixed(6)}f;
static const float C_E    = ${w1.toStringAsFixed(8)}f;
static const float C_T    = ${w2.toStringAsFixed(8)}f;
static const float C_ET   = ${w3.toStringAsExponential(5)}f;
static const float C_E2   = ${w4.toStringAsExponential(5)}f;
static const float C_T2   = ${w5.toStringAsExponential(5)}f;

// Forward Inference Routine for ESP32
float predictAiCompensatedPh(float potentialMv, float tempC) {
  float e = potentialMv;
  float t = tempC;
  
  float phPred = C_BIAS +
                 (C_E * e) +
                 (C_T * t) +
                 (C_ET * e * t) +
                 (C_E2 * e * e) +
                 (C_T2 * t * t);

  if (phPred < 0.0f) phPred = 0.0f;
  if (phPred > 14.0f) phPred = 14.0f;
  return phPred;
}

void setup() {
  Serial.begin(115200);
  Serial.println("SoilpHTxAI Firmware Initialized (RBRU 2569)");
}

void loop() {
  float rawMv = 118.5f;
  float tempC = 28.5f;
  float phAI = predictAiCompensatedPh(rawMv, tempC);
  
  Serial.print("{\\"potential_mv\\":");
  Serial.print(rawMv);
  Serial.print(",\\"temperature_c\\":");
  Serial.print(tempC);
  Serial.print(",\\"ai_ph\\":");
  Serial.print(phAI, 2);
  Serial.println("}");
  
  delay(1000);
}
''';
  }
}
