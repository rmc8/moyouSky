import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/services/post_service.dart';

Future<void> handleRepostAction(bsky.Post post, bool isReposted,
    PostService apiService, Function(bool, int) updateState) async {
  updateState(!isReposted, isReposted ? -1 : 1);

  String cid = post.cid;
  String uri = post.uri.toString();

  try {
    if (isReposted) {
      await apiService.deletePost(uri);
    } else {
      await apiService.repost(cid, uri);
    }
  } catch (e) {
    updateState(isReposted, isReposted ? 1 : -1);
  }
}

Future<void> handleFavoriteAction(bsky.Post post, bool isLiked,
    PostService apiService, Function(bool, int) updateState) async {
  updateState(!isLiked, isLiked ? -1 : 1);

  String cid = post.cid;
  bsky.AtUri uri = post.uri;

  try {
    if (isLiked) {
      await apiService.deletePost(uri.toString());
    } else {
      await apiService.likePost(cid, uri.toString());
    }
  } catch (e) {
    updateState(isLiked, isLiked ? 1 : -1);
  }
}

Future<void> handleDeleteAction(
  BuildContext context,
  String uri,
    PostService apiService,
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
