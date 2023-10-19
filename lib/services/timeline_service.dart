import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_service_manager.dart';


class TimelineResult {
  final List<bsky.FeedView> feeds;
  final String cursor;

  TimelineResult({required this.feeds, required this.cursor});
}


class TimelineService {
  final BlueskySessionManager _sessionManager = BlueskySessionManager();

  Future<TimelineResult> getTimeline(
      {int limit = 32, String? cursor}) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final pagination = blueskyInstance.feeds.paginateTimeline(cursor: cursor);
    String nextCursor = "";
    List<bsky.FeedView> filteredFeeds = [];

    while (pagination.hasNext && filteredFeeds.length < limit) {
      final response = await pagination.next();
      for (var feed in response.data.feed) {
        if (feed.post.author.isBlocking || feed.post.author.isBlockedBy) {
          continue;
        } else if (feed.post.author.isMuted) {
          continue;
        }
        filteredFeeds.add(feed);
      }
      if (filteredFeeds.length > limit) {
        filteredFeeds.length = limit;
        nextCursor = response.data.cursor.toString();
      }
    }
    return TimelineResult(feeds: filteredFeeds, cursor: nextCursor);
  }
}
