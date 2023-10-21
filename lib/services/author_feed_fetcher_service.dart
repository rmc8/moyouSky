import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_service_manager.dart';
import 'package:moyousky/utils/post_utils.dart';

class FetchResult {
  final List<bsky.FeedView> feedList;
  final String? cursor;

  FetchResult({required this.feedList, this.cursor});
}

mixin SessionManagerMixin {
  late final BlueskySessionManager _sessionManager = BlueskySessionManager();
}

abstract class Fetcher with SessionManagerMixin {
  final String actor;
  final int limit;
  List<FeedView> feeds = [];

  Fetcher({required this.actor, this.limit = 30});

  Future<XRPCResponse<Feed>> fetchData(String? cursor);

  Future<FetchResult> fetchPosts(String? cursor) async {
    final res = await fetchData(cursor);
    final fetchedFeed = res.data.feed;
    final nextCursor = res.data.cursor;
    feeds.addAll(fetchedFeed);
    return FetchResult(feedList: feeds, cursor: nextCursor);
  }
}

class PostFetcher extends Fetcher {
  final bsky.FeedFilter filter = bsky.FeedFilter.postsNoReplies;

  PostFetcher({required String actor, int limit = 30}) : super(actor: actor, limit: limit);

  @override
  Future<XRPCResponse<Feed>> fetchData(String? cursor) async {
    final bs = await _sessionManager.getBlueskySession();
    return bs.feeds.findFeed(
      actor: actor,
      limit: limit,
      cursor: cursor,
      filter: filter,
    );
  }
}

class ReplyFetcher extends Fetcher {
  final bsky.FeedFilter filter = bsky.FeedFilter.postsWithReplies;

  ReplyFetcher({required String actor, int limit = 30}) : super(actor: actor, limit: limit);

  @override
  Future<XRPCResponse<Feed>> fetchData(String? cursor) async {
    final bs = await _sessionManager.getBlueskySession();
    return bs.feeds.findFeed(
      actor: actor,
      limit: limit,
      cursor: cursor,
      filter: filter,
    );
  }
}

class MediaPostFetcher extends Fetcher {
  final bsky.FeedFilter filter = bsky.FeedFilter.postsWithMedia;

  MediaPostFetcher({required String actor, int limit = 30}) : super(actor: actor, limit: limit);

  @override
  Future<XRPCResponse<Feed>> fetchData(String? cursor) async {
    final bs = await _sessionManager.getBlueskySession();
    return bs.feeds.findFeed(
      actor: actor,
      limit: limit,
      cursor: cursor,
      filter: filter,
    );
  }
}

class LikeFetcher extends Fetcher {
  LikeFetcher({required String actor, int limit = 30}) : super(actor: actor, limit: limit);

  @override
  Future<XRPCResponse<Feed>> fetchData(String? cursor) async {
    final bs = await _sessionManager.getBlueskySession();
    return bs.feeds.findActorLikes(actor: actor, limit: limit, cursor: cursor);
  }
}
