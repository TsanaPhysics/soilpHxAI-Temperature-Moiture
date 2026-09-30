import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soil_pht_x_ai/main.dart';
import 'package:soil_pht_x_ai/viewmodels/soil_pht_viewmodel.dart';
import 'package:soil_pht_x_ai/ui/views/live_monitor_screen.dart';
import 'package:soil_pht_x_ai/ui/views/dataset_screen.dart';
import 'package:soil_pht_x_ai/ui/views/hypothesis_screen.dart';
import 'package:soil_pht_x_ai/ui/views/field_survey_screen.dart';
import 'package:soil_pht_x_ai/ui/views/project_firmware_screen.dart';

void main() {
  final screenSizes = [
    const Size(320, 568), // Compact iPhone SE / small Android
    const Size(360, 640), // Standard Android (360dp)
    const Size(393, 852), // iPhone 14/15
    const Size(412, 915), // Pixel 7 / Galaxy S23
  ];

  for (final size in screenSizes) {
    testWidgets('Zero overflow test on ${size.width}x${size.height} screen', (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SoilPhtViewModel(),
          child: const SoilpHTxAIApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Test Tab 1
      expect(find.byType(LiveMonitorScreen), findsOneWidget);

      // Tap Tab 2
      await tester.tap(find.text('ชุดข้อมูล Lab'));
      await tester.pumpAndSettle();
      expect(find.byType(DatasetScreen), findsOneWidget);

      // Tap Tab 3
      await tester.tap(find.text('สมมติฐาน H₀'));
      await tester.pumpAndSettle();
      expect(find.byType(HypothesisScreen), findsOneWidget);

      // Tap Tab 4
      await tester.tap(find.text('สำรวจดิน'));
      await tester.pumpAndSettle();
      expect(find.byType(FieldSurveyScreen), findsOneWidget);

      // Tap Tab 5
      await tester.tap(find.text('ESP32 / ทุน'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFirmwareScreen), findsOneWidget);
    });
  }
}
