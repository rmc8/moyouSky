import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moyousky/views/switch_account.dart' as sa;
import 'package:moyousky/utils/database_helper.dart' as dh;
import 'package:moyousky/repository/shared_preferences_repository.dart' as spr;

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  MainDrawerState createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  Map<String, dynamic> profileData = {};

  @override
  Widget build(BuildContext context) {
    final dbHelper = dh.DatabaseHelper.instance;
    final sprObj = spr.SharedPreferencesRepository();

    return Drawer(
      child: FutureBuilder<String>(
        future: sprObj.getId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final uid = snapshot.data!;
          return FutureBuilder<String>(
            future: sprObj.getService(),
            builder: (context, serviceSnapshot) {
              if (!serviceSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final serviceName = serviceSnapshot.data!;
              return FutureBuilder<Map<String, dynamic>>(
                future: dbHelper.getLoginInfoByServiceAndId(serviceName, uid),
                builder: (context, localProfileSnapshot) {
                  if (!localProfileSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  profileData = localProfileSnapshot.data!;

                  final imageUrl = profileData['avatar_url'] ?? "";
                  final name = profileData['display_name'] ?? "";
                  final userId = profileData['handle'] ?? "";
                  final followsCount = profileData['follows_count'] ?? 0;
                  final followersCount = profileData['followers_count'] ?? 0;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            ProfileSection(
                              imageUrl: imageUrl,
                              name: name,
                              userId: userId,
                              followers: followersCount,
                              following: followsCount,
                            ),
                            const DrawerMenuItem(
                              title: 'プロフィール',
                              iconData: Icons.account_circle_rounded,
                            ),
                            const SwitchAccountList(),
                            const DrawerMenuItem(
                              title: '招待コード',
                              iconData: Icons.code_rounded,
                            ),
                            const DrawerMenuItem(
                              title: '設定',
                              iconData: Icons.settings,
                            ),
                            const DrawerMenuItem(
                              title: 'ヘルプ',
                              iconData: Icons.help_center,
                              onTapFunction: _launchHelpURL,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.0),
                                  border: Border.all(color: Colors.redAccent),
                                ),
                                child: const Align(
                                  widthFactor: 0.6,
                                  alignment: Alignment.center,
                                  child: LogoutButton(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.0),
                                  color:
                                      const Color.fromARGB(255, 230, 236, 255),
                                ),
                                child: const Align(
                                  alignment: Alignment.center,
                                  child: FeedbackButton(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  static void _launchHelpURL() async {
    const url = 'https://blueskyweb.zendesk.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ProfileSection extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String userId;
  final int followers;
  final int following;

  const ProfileSection({
    required this.imageUrl,
    required this.name,
    required this.userId,
    required this.followers,
    required this.following,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 28, bottom: 28, right: 16, left: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(
                color: Color.fromARGB(255, 212, 216, 216), width: 0.5)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 48.0,
          ),
          const SizedBox(height: 8.0),
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
          const SizedBox(height: 4.0),
          Text(userId,
              style: const TextStyle(color: Colors.grey, fontSize: 16.0)),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text('Followers', style: TextStyle(color: Colors.grey)),
                  Text(followers.toString()),
                ],
              ),
              const SizedBox(width: 16.0),
              Column(
                children: [
                  const Text('Following', style: TextStyle(color: Colors.grey)),
                  Text(following.toString()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SwitchAccountList extends StatelessWidget {
  const SwitchAccountList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.switch_account),
      title: const Text('アカウント切り替え'),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => sa.SwitchAccountScreen(),
        ));
      },
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback? onTapFunction;

  const DrawerMenuItem({
    super.key,
    required this.title,
    required this.iconData,
    this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      onTap: onTapFunction,
    );
  }
}

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

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 36,
      child: Center(
        child: Text(
          'Feedback',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 89, 186)),
        ),
      ),
    );
  }
}
