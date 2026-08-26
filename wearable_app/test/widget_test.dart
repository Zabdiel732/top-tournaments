// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:wearable_app/main.dart';

void main() {
  testWidgets('muestra las metricas iniciales del Wear', (WidgetTester tester) async {
    await tester.pumpWidget(const WearableApp());

    expect(find.text('Pasos'), findsOneWidget);
    expect(find.text('Ritmo'), findsOneWidget);
    expect(find.text('Calorías'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
  });
}
