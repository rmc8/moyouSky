import 'package:flutter/material.dart';

import 'package:moyousky/views/user_profile.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/utils/database_helper.dart' as dh;
import 'package:moyousky/widgets/drawer/actions/actions.dart';
import 'package:moyousky/widgets/drawer/child_widgets/logout.dart';
import 'package:moyousky/widgets/drawer/child_widgets/moyousky.dart';
import 'package:moyousky/widgets/drawer/child_widgets/drawer_menu.dart';
import 'package:moyousky/widgets/drawer/child_widgets/profileSection.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart' as spr;
import 'package:moyousky/widgets/drawer/child_widgets/switch_account_section.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  MainDrawerState createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  Map<String, dynamic> profileData = {};

  final dbHelper = dh.DatabaseHelper.instance;
  final sprObj = spr.SharedPreferencesRepository();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: sprObj.getId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildDiDFutureBuilder(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildDiDFutureBuilder(String id) {
    return FutureBuilder<String>(
      future: sprObj.getDiD(),
      builder: (context, serviceSnapshot) {
        if (!serviceSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildProfileDataFutureBuilder(serviceSnapshot.data!);
      },
    );
  }

  Widget _buildProfileDataFutureBuilder(String did) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dbHelper.getLoginInfoByDiD(did),
      builder: (context, localProfileSnapshot) {
        if (!localProfileSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        profileData = localProfileSnapshot.data!;

        final imageUrl = profileData['avatar_url'] ?? "";
        final name = profileData['display_name'] ?? profileData['handle'] ?? "";
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
                  _buildProfileMenuItem(did),
                  const SwitchAccountList(),
                  _buildDrawerMenuItems()
                ],
              ),
            ),
            _buildFooterButtons(),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenuItem(String did) {
    return DrawerMenuItem(
      title: 'プロフィール',
      iconData: Icons.account_circle_rounded,
      onTapFunction: () {
        Navigator.of(context).push(FadeRoute(page: UserProfile(did: did)));
      },
    );
  }

  Widget _buildDrawerMenuItems() {
    return const Column(
      children: [
        DrawerMenuItem(
          title: '招待コード',
          iconData: Icons.code_rounded,
        ),
        DrawerMenuItem(
          title: '設定',
          iconData: Icons.settings,
        ),
        DrawerMenuItem(
          title: 'ヘルプ',
          iconData: Icons.help_center,
          onTapFunction: launchHelpURL,
        ),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: _buildLogoutButtonContainer(),
          ),
          Expanded(
            flex: 7,
            child: _buildFeedbackButtonContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButtonContainer() {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: Colors.redAccent),
        color: Colors.white,
      ),
      child: const Align(
        widthFactor: 0.6,
        alignment: Alignment.center,
        child: LogoutButton(),
      ),
    );
  }

  Widget _buildFeedbackButtonContainer() {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: const Color.fromARGB(255, 230, 236, 255),
      ),
      child: const Align(
        alignment: Alignment.center,
        child: FeedbackButton(),
      ),
    );
  }
}
