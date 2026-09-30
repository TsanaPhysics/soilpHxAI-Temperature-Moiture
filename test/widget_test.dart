import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soil_pht_x_ai/main.dart';
import 'package:soil_pht_x_ai/viewmodels/soil_pht_viewmodel.dart';

void main() {
  testWidgets('SoilpHTxAI app initializes and displays monitor title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SoilPhtViewModel(),
        child: const SoilpHTxAIApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('SoilpHTxAI'), findsAtLeastNWidgets(1));
  });
}
