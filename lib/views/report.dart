import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/utils/constants.dart';
import 'package:moyousky/services/report_service.dart';

class ReportScreen extends StatefulWidget {
  final String postDid;
  final ReportService apiService;

  const ReportScreen({
    Key? key,
    required this.postDid,
    required this.apiService,
  }) : super(key: key);

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  Future<void> _confirmAndSendReport(bsky.ModerationReasonType reason) async {
    final bool? confirm = await _showConfirmationDialog();

    if (confirm == true) {
      await widget.apiService.sendReport(widget.postDid, reason);
      Navigator.pop(context);
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
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
  }

  ListTile _buildReportTile({
    required String title,
    required String subtitle,
    required bsky.ModerationReasonType reason,
  }) {
    return ListTile(
      subtitle:
          Text(subtitle, style: const TextStyle(fontFamily: DEFAULT_FONT)),
      title: Text(title, style: const TextStyle(fontFamily: DEFAULT_FONT)),
      onTap: () => _confirmAndSendReport(reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        '問題を報告する',
        style: TextStyle(
          color: Color(0xff333333),
          fontFamily: DEFAULT_FONT,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {}, // settings action
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'このポストにはどのような問題がありますか？',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        _buildReportTile(
            title: '迷惑行為',
            subtitle: '過度なメンションや返信',
            reason: bsky.ModerationReasonType.spam),
        _buildReportTile(
            title: '規約違反',
            subtitle: '法律や利用規約の違反',
            reason: bsky.ModerationReasonType.violation),
        _buildReportTile(
            title: '誤解を招く内容',
            subtitle: 'フェイクや誤解を招く内容',
            reason: bsky.ModerationReasonType.misleading),
        _buildReportTile(
            title: '性的な内容',
            subtitle: 'ラベル付けされていない性的なコンテンツ',
            reason: bsky.ModerationReasonType.sexual),
        _buildReportTile(
            title: '不適切・無礼な内容',
            subtitle: '嫌がらせや不適切な行為など',
            reason: bsky.ModerationReasonType.rude),
        _buildReportTile(
            title: 'その他',
            subtitle: '上記に該当しないもの',
            reason: bsky.ModerationReasonType.other),
      ],
    );
  }
}
