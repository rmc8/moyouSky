import 'package:flutter/material.dart';
import 'package:moyousky/views/switch_account.dart' as sa;
import 'package:moyousky/animation/fade_route.dart';

class SwitchAccountList extends StatelessWidget {
  const SwitchAccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.switch_account),
      title: const Text('アカウント切り替え'),
      onTap: () {
        Navigator.of(context).push(FadeRoute(page: sa.SwitchAccountScreen()));
      },
    );
  }
}