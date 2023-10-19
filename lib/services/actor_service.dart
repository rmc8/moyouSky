import 'package:bluesky/bluesky.dart' as bsky;
import 'bluesky_service_manager.dart';

class ActorListResult {
  final List<bsky.Actor> actorList;
  final String? cursor;

  ActorListResult({required this.actorList, required this.cursor});
}

class ActorService {
  final BlueskySessionManager _sessionManager = BlueskySessionManager();

  Future<bsky.ActorProfile> fetchProfileDataObj(String actor) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final profile = await blueskyInstance.actors.findProfile(actor: actor);
    return profile.data;
  }

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

  Future<ActorListResult> _createActorFetcher(
      String actor, int limit, String? cursor, Function fetchFunction) async {
    final actorListObj =
    await fetchFunction(actor: actor, limit: limit, cursor: cursor);
    final data = actorListObj.data;
    try {
      final actors = data.followers;
      return ActorListResult(actorList: actors!, cursor: data.cursor);
    } catch (e) {
      final actors = data.follows;
      return ActorListResult(actorList: actors!, cursor: data.cursor);
    }
  }

  Future<Function(String?)> createFollowersFetcher(
      String actor, int limit) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    Future<ActorListResult> inner(String? cursor) {
      return _createActorFetcher(
        actor,
        limit,
        cursor,
        blueskyInstance.graphs.findFollowers,
      );
    }

    return inner;
  }

  Future<Function(String?)> createFollowsFetcher(
      String actor, int limit) async {
    final blueskyInstance = await _sessionManager.getBlueskySession();
    Future<ActorListResult> inner(String? cursor) {
      return _createActorFetcher(
        actor,
        limit,
        cursor,
        blueskyInstance.graphs.findFollows,
      );
    }

    return inner;
  }
}
