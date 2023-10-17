import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:moyousky/views/report.dart';
import 'package:moyousky/widgets/post/actions/actions.dart';
import 'package:moyousky/services/bluesky_api_service.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:bluesky/bluesky.dart' as bsky;

void showBottomSheetCustom(BuildContext context, bsky.FeedView feedView,
    BlueskyApiService apiService, bool myOwnPost) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('共有'),
              onTap: () {
                final postUri = feedView.post.uri.toString();
                Share.share(postUri);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('ポストをコピー'),
            onTap: () {
              final postContent = feedView.post.record.text.toString();
              Clipboard.setData(ClipboardData(text: postContent));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ポストをコピーしました！'),
                ),
              );
            },
          ),
          if (myOwnPost) ...[
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('ポストを削除'),
              onTap: () {
                handleDeleteAction(
                    context, feedView.post.uri.toString(), apiService);
              },
            ),
          ],
          if (!myOwnPost) ...[
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('ポストを報告'),
              onTap: () async {
                Navigator.of(context).push(
                  FadeRoute(
                    page: ReportScreen(
                      postDid: feedView.post.author.did ?? '',
                      apiService: apiService,
                    ),
                  ),
                );
              },
            ),
          ],
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
        Icon(
          icon,
          color: color ?? Colors.black45,
        ),
        const SizedBox(width: 4.0),
        Text(
          '$count',
          style: TextStyle(
              color: color ?? Colors.black45, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
