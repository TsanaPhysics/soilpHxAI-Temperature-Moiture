import 'package:flutter_test/flutter_test.dart';
import 'package:soil_pht_x_ai/services/dataset_generator_service.dart';
import 'package:soil_pht_x_ai/services/edge_ph_model_trainer.dart';

void main() {
  group('EdgePhModelTrainer Tests', () {
    test('Trains on-device model with high accuracy R2 > 0.99', () async {
      final dataset = DatasetGeneratorService.generateFullResearchDataset();
      final trainPoints = dataset.where((p) => p.split == 'train').toList();

      expect(trainPoints.length, greaterThanOrEqualTo(100));

      final result = await EdgePhModelTrainer.trainModel(trainingPoints: trainPoints);

      expect(result.weights.length, equals(6));
      expect(result.r2, greaterThan(0.99));
      expect(result.rmse, lessThan(0.15));
      expect(result.mae, lessThan(0.15));
      expect(result.trainingDuration.inMilliseconds, lessThan(500)); // Fast on-device convergence
    });

    test('Predicts pH correctly using trained weights', () {
      final weights = [7.0, -0.035, 0.0, 0.0, 0.0, 0.0];
      final predicted = EdgePhModelTrainer.predictWithWeights(weights, 0.0, 25.0);
      expect(predicted, equals(7.0));
    });
  });
}
