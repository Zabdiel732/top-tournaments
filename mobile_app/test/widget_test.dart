// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MobileApp());

    // Verify that our counter starts at 0.
    expect(find.text('Estado BLE: Desconectado'), findsOneWidget);
    expect(find.text('Pasos: 0'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    expect(find.text('Ritmo: 0'), findsOneWidget);
    expect(find.text('Calorías: 0'), findsOneWidget);
  });
}
