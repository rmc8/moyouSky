import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_service_manager.dart';

class PostThreadService {
  final BlueskySessionManager _sessionManager;

  PostThreadService() : _sessionManager = BlueskySessionManager();

  Future<bsky.PostThread> getPostThread(bsky.AtUri uri, int? depth) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final thread =
        await blueskyInstance.feeds.findPostThread(uri: uri, depth: depth);
    return thread.data;
  }
}
