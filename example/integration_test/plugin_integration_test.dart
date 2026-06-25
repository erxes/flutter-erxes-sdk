// Basic Flutter integration test for the Erxes plugin.
//
// Integration tests run in a full Flutter application, so they can interact
// with the host side of the plugin implementation.
//
// See https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:erxes_flutter_sdk/erxes_flutter_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('clearUser completes without throwing', (
    WidgetTester tester,
  ) async {
    // A no-arg command round-trips through the platform channel.
    await ErxesMessenger.clearUser();
  });
}
