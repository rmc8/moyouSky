import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/views/switch_account.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/utils/providers.dart';
import 'package:moyousky/widgets/common/headerLogo.dart' as hl;

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLoading = false;
  final _serviceController = TextEditingController(text: _defaultService);
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _defaultService = 'bsky.social';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'サービス',
                hintText: _defaultService,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名/メールアドレス',
                hintText: 'ユーザー名かパスワードを入力してください',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'パスワード',
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
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
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
      child: isLoading ? CircularProgressIndicator() : const Text('ログイン'),
    );
  }
}
