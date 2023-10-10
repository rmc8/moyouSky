import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/database_helper.dart';

class TimelineResult {
  final List<Map<String, dynamic>> feeds;
  final String cursor;

  TimelineResult({required this.feeds, required this.cursor});
}

class BlueskyApiService {
  final DatabaseHelper _databaseHelper;
  bsky.Bluesky? _bluesky;

  BlueskyApiService(this._databaseHelper);

  Future<bsky.Bluesky> get bluesky async {
    if (_bluesky != null) return _bluesky!;

    final loginInfo = await _databaseHelper.getLoginInfo();
    if (loginInfo.isEmpty) {
      throw Exception('Login information not found.');
    }

    final service = loginInfo[0]['service'];
    final id = loginInfo[0]['id'];
    final password = loginInfo[0]['password'];

    final session = await bsky.createSession(
      service: service,
      identifier: id,
      password: password,
    );

    _bluesky = bsky.Bluesky.fromSession(session.data, service: service);
    return _bluesky!;
  }

  Future<TimelineResult> getTimeline({int limit = 32, String? cursor}) async {
    final blueskyInstance = await bluesky;
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
}
