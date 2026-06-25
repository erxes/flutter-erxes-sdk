import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erxes_flutter_sdk/erxes_flutter_sdk.dart';

// Replace with your own Erxes integration details.
const String kIntegrationId = 'YOUR_INTEGRATION_ID';
const String kEndpoint = 'https://yourcompany.erxes.io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erxes Flutter SDK example',
      routes: {'/profile': (_) => const ProfileScreen()},
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SupportScreen())),
          ),
        ],
      ),
    );
  }
}

/// Opens a full-screen Erxes chat. The `close` home action pops this screen
/// and the `profile` action navigates to the profile route.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  StreamSubscription<String>? _actionSub;

  @override
  void initState() {
    super.initState();

    _actionSub = ErxesMessenger.onAction.listen((id) {
      if (!mounted) return;
      switch (id) {
        case 'close':
          Navigator.of(context).pop();
          break;
        case 'profile':
          Navigator.of(context).pushNamed('/profile');
          break;
      }
    });

    ErxesMessenger.configure(
      integrationId: kIntegrationId,
      endpoint: kEndpoint,
      displayMode: ErxesDisplayMode.chat,
      primaryColor: '#7c3aed',
      user: const ErxesUser(name: 'Jane Doe', email: 'user@example.com'),
      homeActions: const [
        ErxesAction(
          id: 'close',
          title: 'Close',
          iosIcon: 'xmark',
          androidIcon: 'Close',
        ),
        ErxesAction(
          id: 'profile',
          title: 'Profile',
          iosIcon: 'person',
          androidIcon: 'Person',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _actionSub?.cancel();
    ErxesMessenger.hideMessenger();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The native messenger renders over this screen; show a placeholder while
    // it loads.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile')),
    );
  }
}
