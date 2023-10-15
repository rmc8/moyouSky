import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/repository//shared_preferences_repository.dart';

const double ICON_SIZE = 15.0;

class UserAvatar extends StatefulWidget {
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    final prefs = SharedPreferencesRepository();
    final did = await prefs.getDiD();
    return DatabaseHelper.instance.getLoginInfoByDiD(did);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData &&
              snapshot.data!['avatar_url'] != null &&
              snapshot.data!['avatar_url'].isNotEmpty) {
            return CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data!['avatar_url']),
              radius: ICON_SIZE,
            );
          } else {
            return const Icon(
              Icons.menu,
              color: Colors.black54,
              size: ICON_SIZE,
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
