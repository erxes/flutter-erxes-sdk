// Basic Flutter widget test for the example app.

import 'package:flutter_test/flutter_test.dart';

import 'package:erxes_flutter_sdk_example/main.dart';

void main() {
  testWidgets('Home screen shows the Support entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
