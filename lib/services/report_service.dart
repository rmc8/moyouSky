import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_service_manager.dart';

class ReportService {
  final BlueskySessionManager _sessionManager;

  ReportService() : _sessionManager = BlueskySessionManager();

  Future<Map<String, dynamic>> sendReport(
      String did, bsky.ModerationReasonType moderationReason) async {
    final repoRefData = bsky.RepoRef(did: did);
    final reportSubject = bsky.ReportSubject.repoRef(data: repoRefData);
    final blueskyInstance = await _sessionManager.getBlueskySession();
    final response = await blueskyInstance.moderation.createReport(
      subject: reportSubject,
      reasonType: moderationReason,
    );
    return response.toJson();
  }
}
