import 'package:flutter/material.dart';
import 'package:moyousky/utils/database_helper.dart' as dh;
import 'package:moyousky/views/login.dart' as li;
import 'package:moyousky/repository/shared_preferences_repository.dart';
import 'package:moyousky/views/timeline.dart';
import 'package:moyousky/widgets/headerLogo.dart' as hl;

class SwitchAccountScreen extends StatefulWidget {
  const SwitchAccountScreen({super.key});

  @override
  SwitchAccountScreenState createState() => SwitchAccountScreenState();
}

class SwitchAccountScreenState extends State<SwitchAccountScreen> {
  List<Map<String, dynamic>>? _accounts;
  final _sharedPreferencesRepo = SharedPreferencesRepository();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    var accounts = await dh.DatabaseHelper.instance.getLoginInfo();
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: hl.HeaderLogo(),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            Navigator.of(context).pop();
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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('アカウントを追加する'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => li.LoginScreen()),
              );
            },
          ),
          ..._accounts!.map((account) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(account['avatar_url'] ?? ''),
              ),
              title: Text(account['display_name'] ?? '{Null}'),
              subtitle: Text(account['handle'] ?? '{Null}'),
              trailing: PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 1) {
                    _deleteAccount(account['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text('ログアウト'),
                  ),
                ],
              ),
              onTap: () async {
                await _sharedPreferencesRepo.setId(account['handle']);
                await _sharedPreferencesRepo.setService(account['service']);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Timeline()),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(String accountId) async {
    await dh.DatabaseHelper.instance.deleteLoginInfo(accountId);
    _loadAccounts();
  }
}
