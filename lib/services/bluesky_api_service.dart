import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/repository/shared_preferences_repository.dart';

class TimelineResult {
  final List<Map<String, dynamic>> feeds;
  final String cursor;

  TimelineResult({required this.feeds, required this.cursor});
}

class BlueskyApiService {
  final SharedPreferencesRepository _prefsRepository;
  bsky.Bluesky? _bluesky;

  BlueskyApiService(this._prefsRepository);

  Future<bsky.Bluesky> get bluesky async {
    if (_bluesky != null) return _bluesky!;

    final service = await _prefsRepository.getService();
    final id = await _prefsRepository.getId();
    final password = await _prefsRepository.getPassword();

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
