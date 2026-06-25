import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erxes_flutter_sdk/erxes_flutter_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('erxes_flutter_sdk/methods');
  final log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          log.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('configure sends method name and stripped argument map', () async {
    await ErxesMessenger.configure(
      integrationId: 'abc',
      endpoint: 'https://co.erxes.io',
      displayMode: ErxesDisplayMode.chat,
      primaryColor: '#7c3aed',
      homeActions: const [
        ErxesAction(
          id: 'close',
          title: 'Close',
          iosIcon: 'xmark',
          androidIcon: 'Close',
        ),
      ],
    );

    expect(log, hasLength(1));
    final call = log.single;
    expect(call.method, 'configure');

    final args = Map<String, dynamic>.from(call.arguments as Map);
    expect(args['integrationId'], 'abc');
    expect(args['endpoint'], 'https://co.erxes.io');
    expect(args['displayMode'], 'chat');
    expect(args['primaryColor'], '#7c3aed');
    // Null optionals are stripped before crossing the channel.
    expect(args.containsKey('serverUrl'), isFalse);
    expect(args.containsKey('cachedCustomerId'), isFalse);

    final home = (args['homeActions'] as List).cast<Map>();
    expect(home.single['id'], 'close');
    // iosIcon is mirrored into systemIcon for the native iOS bridge.
    expect(home.single['systemIcon'], 'xmark');
  });

  test('configure with a user also forwards setUser', () async {
    await ErxesMessenger.configure(
      integrationId: 'abc',
      endpoint: 'https://co.erxes.io',
      user: const ErxesUser(name: 'Jane', email: 'j@e.io'),
    );

    expect(log.map((c) => c.method), ['configure', 'setUser']);
    final userArgs = Map<String, dynamic>.from(log[1].arguments as Map);
    expect(userArgs['name'], 'Jane');
    expect(userArgs['email'], 'j@e.io');
    expect(userArgs.containsKey('phone'), isFalse);
  });

  test('command methods send the right method names', () async {
    await ErxesMessenger.showMessenger();
    await ErxesMessenger.hideMessenger();
    await ErxesMessenger.showLauncher();
    await ErxesMessenger.hideLauncher();
    await ErxesMessenger.clearUser();

    expect(log.map((c) => c.method), [
      'showMessenger',
      'hideMessenger',
      'showLauncher',
      'hideLauncher',
      'clearUser',
    ]);
  });

  test('onAction parses {"id": ...} payloads from the event channel', () async {
    const eventChannel = 'erxes_flutter_sdk/events';

    final received = <String>[];
    final sub = ErxesMessenger.onAction.listen(received.add);

    // Simulate the platform sending a stream event.
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          eventChannel,
          const StandardMethodCodec().encodeSuccessEnvelope(<String, String>{
            'id': 'close',
          }),
          (_) {},
        );
    await Future<void>.delayed(Duration.zero);

    expect(received, ['close']);
    await sub.cancel();
  });
}
