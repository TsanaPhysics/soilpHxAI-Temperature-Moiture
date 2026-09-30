import 'package:flutter_test/flutter_test.dart';
import 'package:soil_pht_x_ai/services/nernst_physics_engine.dart';
import 'package:soil_pht_x_ai/services/ai_error_compensation_model.dart';
import 'package:soil_pht_x_ai/services/dataset_generator_service.dart';
import 'package:soil_pht_x_ai/services/durian_soil_expert_service.dart';

void main() {
  group('Nernst Physics Engine Tests', () {
    test('Nernst slope at 25°C should be approximately 59.16 mV/pH', () {
      final slope = NernstPhysicsEngine.calculateNernstSlopeMv(25.0);
      expect(slope, closeTo(59.16, 0.1));
    });

    test('Nernst slope at 50°C should be approximately 64.12 mV/pH', () {
      final slope = NernstPhysicsEngine.calculateNernstSlopeMv(50.0);
      expect(slope, closeTo(64.12, 0.2));
    });

    test('Nernst pH at 0 mV and 25°C should be 7.00', () {
      final ph = NernstPhysicsEngine.calculateNernstPh(
        potentialMv: 0.0,
        temperatureC: 25.0,
      );
      expect(ph, equals(7.00));
    });
  });

  group('AI Error Compensation Model Tests', () {
    test('AI model predicts reasonable pH for acidic potential', () {
      final ph = AiErrorCompensationModel.predict(
        potentialMv: 165.0, // Around pH 4.0
        temperatureC: 25.0,
      );
      expect(ph, inInclusiveRange(3.5, 4.8));
    });

    test('AI model generates valid ESP32 C++ firmware string', () {
      final code = AiErrorCompensationModel.generateCppArduinoCode();
      expect(code.contains('float predictAiCompensatedPh'), isTrue);
      expect(code.contains('C_BIAS'), isTrue);
    });
  });

  group('Dataset & Hypothesis Evaluation Tests', () {
    test('Full research dataset generates 168 calibration records with 70/15/15 splits', () {
      final dataset = DatasetGeneratorService.generateFullResearchDataset();
      expect(dataset.length, equals(168));

      final trainCount = dataset.where((p) => p.split == 'train').length;
      final valCount = dataset.where((p) => p.split == 'val').length;
      final testCount = dataset.where((p) => p.split == 'test').length;

      expect(trainCount + valCount + testCount, equals(168));
      expect(trainCount, greaterThan(100)); // Around 70%
    });

    test('Hypothesis test rejects H0 and confirms AI significantly reduces RMSE', () {
      final dataset = DatasetGeneratorService.generateFullResearchDataset();
      final result = DatasetGeneratorService.evaluateHypothesis(dataset);

      expect(result.isNullHypothesisRejected, isTrue);
      expect(result.rmseAi, lessThan(result.rmseTraditional));
      expect(result.pValue, lessThan(0.05));
      expect(result.errorReductionPct, greaterThan(40.0));
    });
  });

  group('Durian Agronomy & Field Survey Tests', () {
    test('Identifies strongly acidic soil under pH 4.5', () {
      final diag = DurianSoilExpertService.diagnoseSoilStatus(4.2);
      expect(diag['status'].toString().contains('ดินกรดรุนแรง'), isTrue);
      expect(diag['isOptimal'], isFalse);
    });

    test('Identifies optimal pH range for Durian (5.5 - 6.5)', () {
      final diag = DurianSoilExpertService.diagnoseSoilStatus(6.0);
      expect(diag['isOptimal'], isTrue);
    });

    test('Budgeted 30 field samples are generated with valid locations', () {
      final samples = DurianSoilExpertService.getResearchFieldSamples();
      expect(samples.length, equals(30));
      expect(samples.any((s) => s.province.contains('จันทบุรี')), isTrue);
      expect(samples.any((s) => s.province.contains('ตราด')), isTrue);
    });
  });
}
