import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bsky;

import 'bluesky_service_manager.dart';

class RecordService {
  final BlueskySessionManager _sessionManager = BlueskySessionManager();

  Future<bsky.StrongRef> createPost(String text, bsky.Embed embed, bsky.ReplyRef? reply) async {
    List<bsky.Facet>? facets;
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final record = await blueskyInstance.feeds.createPost(
      text: text,
      embed: embed,
      facets: facets,
      createdAt: DateTime.now(),
      unspecced: {
        "via": "moyouSky"
      }
    );
    return record.data;
  }
}
