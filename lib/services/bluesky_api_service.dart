import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';

class BlueskySessionResult {
  final bsky.Session? session;
  final bsky.Bluesky bluesky;

  BlueskySessionResult({this.session, required this.bluesky});
}

class TimelineResult {
  final List<Map<String, dynamic>> feeds;
  final String cursor;

  TimelineResult({required this.feeds, required this.cursor});
}

class BlueskyApiService {
  final DatabaseHelper _databaseHelper;
  bsky.Bluesky? _bluesky;

  BlueskyApiService(this._databaseHelper);

  Future<BlueskySessionResult> getBlueskySession() async {
    if (_bluesky != null)
      return BlueskySessionResult(session: null, bluesky: _bluesky!);

    // SharedPreferencesからIDを取得
    final spr = SharedPreferencesRepository();
    final currentUserId = await spr.getId();
    final currentService = await spr.getService();
    if (currentUserId.isEmpty) {
      throw Exception('User ID not found in shared preferences.');
    }

    final loginInfo = await _databaseHelper.getLoginInfoByServiceAndId(currentService, currentUserId);
    if (loginInfo.isEmpty) {
      throw Exception('Login information not found for user ID: $currentUserId.');
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
    return BlueskySessionResult(session: response.data, bluesky: _bluesky!);
  }


  Future<TimelineResult> getTimeline({int limit = 32, String? cursor}) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final pagination = blueskyInstance.feeds.paginateTimeline(cursor: cursor);
    String nextCursor = "";

    final List<Map<String, dynamic>> allFeeds = [];

    while (pagination.hasNext && allFeeds.length < limit) {
      final response = await pagination.next();
      allFeeds.addAll(response.data.toJson()['feed']);

      if (allFeeds.length > limit) {
        allFeeds.length = limit;
        nextCursor = response.data.toJson()['cursor'];
      }
    }

    return TimelineResult(feeds: allFeeds, cursor: nextCursor);
  }

  Future<Map<String, dynamic>> fetchProfileData(String actor) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final profile = await blueskyInstance.actors.findProfile(actor: actor);
    return profile.data.toJson();
  }
}
