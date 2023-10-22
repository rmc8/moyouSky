import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/views/report.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/services/post_service.dart';
import 'package:moyousky/services/report_service.dart';
import 'package:moyousky/widgets/post/actions/actions.dart';

void showBottomSheetCustom(
    BuildContext context,
    bsky.FeedView feedView,
    PostService postApiService,
    ReportService reportApiService,
    bool myOwnPost,
    ) {
  // ignore: no_leading_underscores_for_local_identifiers
  ListTile _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildListTile(
            icon: Icons.share,
            title: '共有',
            onTap: () {
              Share.share(feedView.post.uri.toString());
            },
          ),
          _buildListTile(
            icon: Icons.content_copy,
            title: 'ポストをコピー',
            onTap: () {
              Clipboard.setData(ClipboardData(text: feedView.post.record.text.toString()));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ポストをコピーしました！'),
                ),
              );
            },
          ),
          if (myOwnPost)
            _buildListTile(
              icon: Icons.delete,
              title: 'ポストを削除',
              onTap: () {
                handleDeleteAction(context, feedView.post.uri.toString(), postApiService);
              },
            ),
          if (!myOwnPost)
            _buildListTile(
              icon: Icons.report,
              title: 'ポストを報告',
              onTap: () async {
                Navigator.of(context).push(
                  FadeRoute(
                    page: ReportScreen(
                      postDid: feedView.post.author.did,
                      apiService: reportApiService,
                    ),
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}

Widget iconTextWidget(
    IconData icon,
    int count,
    Function onTap, {
      Color? color,
    }) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Row(
      children: [
        Icon(icon, color: color ?? Colors.black45),
        const SizedBox(width: 4.0),
        Text(
          '$count',
          style: TextStyle(
            color: color ?? Colors.black45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
