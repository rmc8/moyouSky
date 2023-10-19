import 'package:bluesky/bluesky.dart' as bsky;
import 'bluesky_service_manager.dart';

class PostService {
  final BlueskySessionManager _sessionManager = BlueskySessionManager();

  Future<Map<String, dynamic>> likePost(String cid, String uri) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final likedRecord = await blueskyInstance.feeds.createLike(
      cid: cid,
      uri: bsky.AtUri.parse(uri),
    );
    return likedRecord.toJson();
  }

  Future<Map<String, dynamic>> repost(String cid, String uri) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final repostRecord = await blueskyInstance.feeds.createRepost(
      cid: cid,
      uri: bsky.AtUri.parse(uri),
    );
    return repostRecord.toJson();
  }

  Future<Map<String, dynamic>> deletePost(String uri) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    try {
      final res = await blueskyInstance.repositories.deleteRecord(
        uri: bsky.AtUri.parse(uri),
      );
      return res.toJson();
    } catch (e) {
      print("Error deleting post: $e");
      return {'error': e.toString()};
    }
  }
}
