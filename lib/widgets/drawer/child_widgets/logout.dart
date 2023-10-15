import 'package:flutter/material.dart';
import 'package:moyousky/views/switch_account.dart' as sa;
import 'package:moyousky/utils/database_helper.dart' as dh;
import 'package:moyousky/repository/shared_preferences_repository.dart' as spr;

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    final sprObj = spr.SharedPreferencesRepository();
    final uid = await sprObj.getId();
    await dh.DatabaseHelper.instance.deleteLoginInfo(uid);
    await sprObj.setId('');
    await sprObj.setService('');

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) => sa.SwitchAccountScreen(),
    ));
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (result == true) {
      _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.exit_to_app, color: Colors.redAccent),
            const SizedBox(width: 3),
            TextButton(
              onPressed: () => _showLogoutConfirmation(context),
              child: const Text(
                'ログアウト',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}