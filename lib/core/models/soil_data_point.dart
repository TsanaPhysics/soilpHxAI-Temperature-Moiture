class SoilDataPoint {
  final String sampleId;
  final DateTime timestamp;
  final double potentialMv;
  final double temperatureC;
  final double rawPh;
  final double nernstPh;
  final double aiPh;
  final double? labStandardPh;
  final String siteName;
  final String province;
  final double latitude;
  final double longitude;
  final String soilType;
  final String durianStatus;
  final double recommendedLimeKgPerRai;

  SoilDataPoint({
    required this.sampleId,
    required this.timestamp,
    required this.potentialMv,
    required this.temperatureC,
    required this.rawPh,
    required this.nernstPh,
    required this.aiPh,
    this.labStandardPh,
    required this.siteName,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.soilType,
    required this.durianStatus,
    required this.recommendedLimeKgPerRai,
  });

  double? get aiErrorFromLab =>
      labStandardPh != null ? (aiPh - labStandardPh!).abs() : null;
  double? get traditionalErrorFromLab =>
      labStandardPh != null ? (nernstPh - labStandardPh!).abs() : null;

  Map<String, dynamic> toMap() {
    return {
      'sample_id': sampleId,
      'timestamp': timestamp.toIso8601String(),
      'potential_mv': potentialMv,
      'temperature_c': temperatureC,
      'raw_ph': rawPh,
      'nernst_ph': nernstPh,
      'ai_ph': aiPh,
      'lab_standard_ph': labStandardPh,
      'site_name': siteName,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'soil_type': soilType,
      'durian_status': durianStatus,
      'recommended_lime_kg_per_rai': recommendedLimeKgPerRai,
    };
  }
}
