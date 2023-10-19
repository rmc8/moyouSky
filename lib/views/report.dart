import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/report_service.dart';
import 'package:moyousky/utils/constants.dart';

class ReportScreen extends StatefulWidget {
  final String postDid;
  final ReportService apiService;

  const ReportScreen(
      {super.key, required this.postDid, required this.apiService});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  Future<void> _confirmAndSendReport(bsky.ModerationReasonType reason) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('問題を報告しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('報告する'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await widget.apiService.sendReport(widget.postDid, reason);
      Navigator.pop(context);
    }
  }

  ListTile _buildReportTile(
      String title, String subtitle, bsky.ModerationReasonType reason) {
    return ListTile(
      subtitle: Text(subtitle,
          style: const TextStyle(
            fontFamily: DEFAULT_FONT,
          )),
      title: Text(title,
          style: const TextStyle(
            fontFamily: DEFAULT_FONT,
          )),
      onTap: () => _confirmAndSendReport(reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '問題を報告する',
          style: TextStyle(
              color: Color(0xff333333),
              fontFamily: DEFAULT_FONT,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('このポストにはどのような問題がありますか？',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          _buildReportTile(
              '迷惑行為', '過度なメンションや返信', bsky.ModerationReasonType.spam),
          _buildReportTile(
              '規約違反', '法律や利用規約の違反', bsky.ModerationReasonType.violation),
          _buildReportTile(
              '誤解を招く内容', 'フェイクや誤解を招く内容', bsky.ModerationReasonType.misleading),
          _buildReportTile(
              '性的な内容', 'ラベル付けされていない性的なコンテンツ', bsky.ModerationReasonType.sexual),
          _buildReportTile(
              '不適切・無礼な内容', '嫌がらせや不適切な行為など', bsky.ModerationReasonType.rude),
          _buildReportTile(
              'その他', '上記に該当しないもの', bsky.ModerationReasonType.other),
        ],
      ),
    );
  }
}
