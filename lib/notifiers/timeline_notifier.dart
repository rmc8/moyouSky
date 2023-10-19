import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moyousky/utils/post_utils.dart';
import 'package:moyousky/services/timeline_service.dart';
import 'package:moyousky/widgets/post/post.dart' as pw;
import 'package:bluesky/bluesky.dart' as bsky;

class PostWithTimestamp {
  final pw.Post post;
  final DateTime timestamp;

  PostWithTimestamp({required this.post, required this.timestamp});
}

class TimelineNotifier extends StateNotifier<Map<String, List<PostWithTimestamp>>> {
  final TimelineService apiService;
  Map<String, List<bsky.FeedView>> postsDataCache = {};

  TimelineNotifier(this.apiService) : super({});

  void savePostsData(String did, List<bsky.FeedView> postsData) {
    postsDataCache[did] = postsData;
  }

  List<bsky.FeedView>? getPostsData(String did) {
    return postsDataCache[did];
  }

  Future<void> fetchPosts(String did, {bool forceRefresh = false}) async {
    if (!forceRefresh && state.containsKey(did) && state[did]!.isNotEmpty) {
      return;
    }

    final feedViews = await apiService.getTimeline(limit: 32);
    savePostsData(did, feedViews.feeds);  // 保存するデータをキャッシュに追加

    final fetchedPosts = getPostWidgets(feedViews.feeds)
        .map((post) => PostWithTimestamp(post: post, timestamp: DateTime.now()))
        .toList();

    state[did] = [...fetchedPosts, ...?state[did]];

    _cleanupOldData(did);
    _limitPostCount(did);
  }

  void _cleanupOldData(String did) {
    final expirationDate = DateTime.now().subtract(const Duration(hours: 6));
    state[did] = state[did]!.where((postWithTimestamp) {
      return postWithTimestamp.timestamp.isAfter(expirationDate);
    }).toList();
  }

  void _limitPostCount(String did) {
    if (state[did]!.length > 128) {
      state[did] = state[did]!.take(32).toList();
    }
  }
}
