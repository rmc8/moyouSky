import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/database_helper.dart';
import 'package:moyousky/repository/shared_preferences_repository.dart';

class BlueskySessionResult {
  final bsky.Session? session;
  final bsky.Bluesky bluesky;

  BlueskySessionResult({this.session, required this.bluesky});
}

class TimelineResult {
  final List<Map<String, dynamic>> feeds;
  final String cursor;

  TimelineResult({required this.feeds, required this.cursor});
}

class TimelineResultObj {
  final List<bsky.FeedView> feeds;
  final String cursor;

  TimelineResultObj({required this.feeds, required this.cursor});
}

class BlueskyApiService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bsky.Bluesky? _bluesky;

  BlueskyApiService();

  Future<BlueskySessionResult> getBlueskySession() async {
    if (_bluesky != null) {
      return BlueskySessionResult(session: null, bluesky: _bluesky!);
    }

    // SharedPreferencesからIDを取得
    final spr = SharedPreferencesRepository();
    final currentUserId = await spr.getId();
    final currentService = await spr.getService();
    if (currentUserId.isEmpty) {
      throw Exception('User ID not found in shared preferences.');
    }

    final loginInfo = await _databaseHelper.getLoginInfoByServiceAndId(
        currentService, currentUserId);
    if (loginInfo.isEmpty) {
      throw Exception(
          'Login information not found for user ID: $currentUserId.');
    }
    final service = loginInfo['service'];
    final id = loginInfo['handle'];
    final password = loginInfo['password'];

    final response = await bsky.createSession(
      service: service,
      identifier: id,
      password: password,
    );
    _bluesky = bsky.Bluesky.fromSession(response.data, service: service);
    return BlueskySessionResult(session: response.data, bluesky: _bluesky!);
  }

  Future<TimelineResultObj> getTimeline({int limit = 32, String? cursor}) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final pagination = blueskyInstance.feeds.paginateTimeline(cursor: cursor);
    String nextCursor = "";

    final List<bsky.FeedView> allFeeds = [];

    while (pagination.hasNext && allFeeds.length < limit) {
      final response = await pagination.next();
      allFeeds.addAll(response.data.feed);

      if (allFeeds.length > limit) {
        allFeeds.length = limit;
        nextCursor = response.data.toJson()['cursor'];
      }
    }
    final raw = jsonEncode(allFeeds);
    return TimelineResultObj(feeds: allFeeds, cursor: nextCursor);
  }

  Future<bsky.ActorProfile> fetchProfileDataObj(String actor) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final profile = await blueskyInstance.actors.findProfile(actor: actor);
    return profile.data;
  }

  Future<Map<String, dynamic>> likePost(String cid, String uri) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final likedRecord = await blueskyInstance.feeds.createLike(
      cid: cid,
      uri: bsky.AtUri.parse(uri),
    );
    return likedRecord.toJson();
  }

  Future<Map<String, dynamic>> repost(String cid, String uri) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final likedRecord = await blueskyInstance.feeds.createRepost(
      cid: cid,
      uri: bsky.AtUri.parse(uri),
    );
    return likedRecord.toJson();
  }

  Future<Map<String, dynamic>> sendReport(
      String did, bsky.ModerationReasonType moderationReason) async {
    final repoRefData = bsky.RepoRef(did: did);
    final reportSubject = bsky.ReportSubject.repoRef(data: repoRefData);
    final blueskyInstance = (await getBlueskySession()).bluesky;
    final response = await blueskyInstance.moderation.createReport(
      subject: reportSubject,
      reasonType: moderationReason,
    );
    return response.toJson();
  }

  Future<Map<String, dynamic>> deletePost(String uri) async {
    try {
      final blueskyInstance = (await getBlueskySession()).bluesky;
      final res = await blueskyInstance.repositories.deleteRecord(
        uri: bsky.AtUri.parse(uri),
      );
      return res.toJson();
    } catch (e) {
      print("Error deleting post: $e");
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> searchForUsers(String term,
      {int? limit, String? cursor}) async {
    final blueskyInstance = (await getBlueskySession()).bluesky;
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

      final blueskyInstance = (await getBlueskySession()).bluesky;
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
