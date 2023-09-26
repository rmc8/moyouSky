import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/repository/shared_preferences_repository.dart';

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

  Future<List<Map<String, dynamic>>> getTimeline({int limit = 10}) async {
    final blueskyInstance = await bluesky;
    final pagination = blueskyInstance.feeds.paginateTimeline();

    final List<Map<String, dynamic>> allFeeds = [];

    while (pagination.hasNext && allFeeds.length < limit) {
      final response = await pagination.next();
      allFeeds.addAll(response.data.toJson()['feed']);

      if (allFeeds.length > limit) {
        allFeeds.length = limit;
      }
    }

    return allFeeds;
  }
}
