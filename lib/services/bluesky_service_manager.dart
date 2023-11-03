import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';

class BlueskySessionManager {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bsky.Bluesky? _bluesky;

  Future<bsky.Bluesky> getBlueskySession() async {
    if (_bluesky != null) {
      return _bluesky!;
    }

    final spr = SharedPreferencesRepository();
    final currentUserId = await spr.getId();
    final currentService = await spr.getService();
    if (currentUserId.isEmpty) {
      throw Exception('User ID not found in shared preferences.');
    }

    final loginInfo = await _databaseHelper.getLoginInfoByServiceAndId(
        currentService, currentUserId);
    if (loginInfo.isEmpty) {
      throw Exception(
          'Login information not found for user ID: $currentUserId.');
    }
    final service = loginInfo['service'];
    final id = loginInfo['handle'];
    final password = loginInfo['password'];

    final response = await bsky.createSession(
      service: service,
      identifier: id,
      password: password,
    );
    _bluesky = bsky.Bluesky.fromSession(response.data, service: service);
    return _bluesky!;
  }
}
