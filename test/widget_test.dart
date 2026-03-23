// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:babycare/main.dart';

void main() {
  testWidgets('Gateway Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BabyCareApp());

    // Verify that the BabyCare branding is visible.
    expect(find.text('BabyCare'), findsOneWidget);
    expect(find.text('Managing trusted care,\none family at a time'), findsOneWidget);

    // Verify role selection buttons are present.
    expect(find.text('I am a Parent'), findsOneWidget);
    expect(find.text('I am a Babysitter'), findsOneWidget);
  });
}
