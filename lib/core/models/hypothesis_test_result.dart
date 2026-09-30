class HypothesisTestResult {
  final double rmseTraditional;
  final double rmseAi;
  final double maeTraditional;
  final double maeAi;
  final double r2Traditional;
  final double r2Ai;
  final double errorReductionPct;
  final double tStatistic;
  final double pValue;
  final int sampleCount;
  final bool isNullHypothesisRejected;
  final String conclusion;

  HypothesisTestResult({
    required this.rmseTraditional,
    required this.rmseAi,
    required this.maeTraditional,
    required this.maeAi,
    required this.r2Traditional,
    required this.r2Ai,
    required this.errorReductionPct,
    required this.tStatistic,
    required this.pValue,
    required this.sampleCount,
    required this.isNullHypothesisRejected,
    required this.conclusion,
  });
}
