import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/widgets/post_detail/sub_post.dart';

class ChildRepliesWidget extends StatelessWidget {
  final bsky.PostThreadViewRecord postThreadData;

  ChildRepliesWidget({Key? key, required this.postThreadData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<bsky.PostThreadViewRecord?> childList = _getChildList(postThreadData, []);
    return SubPostWidget(postList: childList, borderTop: true,);
  }

  List<bsky.PostThreadViewRecord?> _getChildList(
      bsky.PostThreadViewRecord recObj,
      [List<bsky.PostThreadViewRecord?>? res]) {
    res ??= [];
    if (recObj.replies == null) {
      return res;
    }
    for (var childObj in recObj.replies as UnmodifiableListView<bsky.PostThreadView>) {
      final child = childObj.data as bsky.PostThreadViewRecord;
      res.add(child);
      _getChildList(child, res);
    }
    return res;
  }

}
