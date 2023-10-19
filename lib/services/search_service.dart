import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_service_manager.dart';

class SearchServiceBeta {
  final BlueskySessionManager _sessionManager = BlueskySessionManager();

  SearchServiceBeta();

  Future<Map<String, dynamic>> searchForUsers(String term,
      {int? limit, String? cursor}) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    try {
      final response = await blueskyInstance.actors.searchActors(
        term: term,
        limit: limit,
        cursor: cursor,
      );
      return response.toJson();
    } catch (e) {
      print("Error searching for users: $e");
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> searchForPost(String query) async {
    try {
      final String baseUrl = "https://search.bsky.social/search/posts?q=$query";
      final r = await http.get(Uri.parse(baseUrl));

      if (r.statusCode != 200) {
        throw Exception(
            'Failed to fetch search results with status code: ${r.statusCode}');
      }

      var searchRes = json.decode(r.body);
      List<bsky.AtUri> uris = [];
      for (var entry in searchRes) {
        String uri = 'at://${entry['user']['did']}/${entry['tid']}';
        uris.add(bsky.AtUri.parse(uri));
      }

      final blueskyInstance = await _sessionManager.getBlueskySession();
      List<Map<String, dynamic>> allPosts = [];

      for (int i = 0; i < uris.length; i += 5) {
        List<bsky.AtUri> limitedUris = uris.sublist(i, min(i + 5, uris.length));
        final res = await blueskyInstance.feeds.findPosts(uris: limitedUris);
        for (var rec in res.data.toJson()['posts']) {
          allPosts.add({'post': rec});
        }
      }
      return {'data': allPosts};
    } catch (e) {
      print(e);
      return {'error': e.toString()};
    }
  }
}
