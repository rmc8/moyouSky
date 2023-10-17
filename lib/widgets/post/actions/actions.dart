import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/bluesky_api_service.dart';

Future<void> handleRepostAction(
    bsky.Post post,
    bool isReposted,
    BlueskyApiService apiService,
    Function(bool, int) updateState) async {

  String cid = post.cid;
  String uri = post.uri.toString();
  if (isReposted) {
    await apiService.deletePost(uri);
    updateState(false, -1);
  } else {
    await apiService.repost(cid, uri);
    updateState(true, 1);
  }
}

Future<void> handleFavoriteAction(
    bsky.Post post,
    bool isLiked,
    BlueskyApiService apiService,
    Function(bool, int) updateState) async {

  String cid = post.cid;
  bsky.AtUri uri = post.uri;

  if (isLiked) {
    await apiService.deletePost(uri.toString());
    updateState(false, -1);
  } else {
    await apiService.likePost(cid, uri.toString());
    updateState(true, 1);
  }
}

Future<void> handleDeleteAction(
    BuildContext context,
    String uri,
    BlueskyApiService apiService,
    ) async {
  Navigator.of(context).pop();
  final bool confirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('確認'),
        content: const Text('このポストを削除してよろしいですか？'),
        actions: <Widget>[
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('削除'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (confirmed) {
    final result = await apiService.deletePost(uri);
    print(result);
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: ${result['error']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ポストを削除しました。')),
      );
    }
  }
}
