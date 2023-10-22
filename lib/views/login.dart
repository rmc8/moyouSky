import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moyousky/controllers/providers.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/widgets/common/headerLogo.dart' as hl;
import 'package:moyousky/views/switch_account.dart';
import 'package:moyousky/animation/fade_route.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false; // 新しく追加
  final _serviceController = TextEditingController(text: _defaultService);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _defaultService = 'bsky.social';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: hl.HeaderLogo(title: 'ログイン'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const SwitchAccountScreen()),
              );
            }
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
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
              Consumer(
                builder: (context, WidgetRef ref, child) {
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      setState(() {
                        isLoading = true;
                      });

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
                        // if (!bsky.isValidAppPassword(password)) {
                        //   throw Exception('Not a valid app password.');
                        // }

                        await ref
                            .read(loginStateProvider.notifier)
                            .login(service, id, password);
                        Navigator.of(context).push(FadeRoute(page: Timeline()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: isLoading ? CircularProgressIndicator() : const Text('Login'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
