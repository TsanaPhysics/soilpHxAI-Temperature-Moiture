class CalibrationPoint {
  final String id;
  final double potentialMv;
  final double temperatureC;
  final double standardPh;
  final String split; // 'train' (70%), 'val' (15%), 'test' (15%)
  final DateTime timestamp;
  final double nernstPh;
  final double aiPredictedPh;

  CalibrationPoint({
    required this.id,
    required this.potentialMv,
    required this.temperatureC,
    required this.standardPh,
    required this.split,
    required this.timestamp,
    required this.nernstPh,
    required this.aiPredictedPh,
  });

  double get traditionalError => (nernstPh - standardPh).abs();
  double get aiError => (aiPredictedPh - standardPh).abs();
  double get squaredTraditionalError => (nernstPh - standardPh) * (nernstPh - standardPh);
  double get squaredAiError => (aiPredictedPh - standardPh) * (aiPredictedPh - standardPh);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'potential_mv': potentialMv,
      'temperature_c': temperatureC,
      'standard_ph': standardPh,
      'split': split,
      'nernst_ph': nernstPh,
      'ai_predicted_ph': aiPredictedPh,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CalibrationPoint.fromMap(Map<String, dynamic> map) {
    return CalibrationPoint(
      id: map['id'] ?? '',
      potentialMv: (map['potential_mv'] as num).toDouble(),
      temperatureC: (map['temperature_c'] as num).toDouble(),
      standardPh: (map['standard_ph'] as num).toDouble(),
      split: map['split'] ?? 'train',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      nernstPh: (map['nernst_ph'] as num).toDouble(),
      aiPredictedPh: (map['ai_predicted_ph'] as num).toDouble(),
    );
  }
}
