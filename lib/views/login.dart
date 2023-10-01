import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/controllers/providers.dart';
import 'package:moyousky/views/timeline.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({Key? key}) : super(key: key);

  static const _defaultService = 'bsky.social';

  final _serviceController = TextEditingController(text: _defaultService);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('Login', style: TextStyle(color: Colors.black87))),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText: 'Sign into',
                  hintText: _defaultService,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username or email address',
                  hintText: 'Enter your username(e.g. test.bsky.social)',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'App Password',
                  hintText: 'Enter your app password',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: IconButton(
                      onPressed: () => launchUrl(
                        Uri.https('bsky.app', '/settings/app-passwords'),
                      ),
                      icon: Icon(
                        Icons.help_outline,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  String service = _serviceController.text.trim();
                  String id = _usernameController.text.trim();
                  final password = _passwordController.text.trim();

                  if (service.isEmpty) {
                    service = _serviceController.text = _defaultService;
                  }
                  if (!id.contains('.')) {
                    id += '.$service';
                  }
                  try {
                    if (!bsky.isValidAppPassword(password)) {
                      throw Exception('Not a valid app password.');
                    }
                    await ref
                        .read(loginStateProvider.notifier)
                        .login(service, id, password);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Timeline()),
                    );
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
