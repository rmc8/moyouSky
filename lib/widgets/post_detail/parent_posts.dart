import 'package:flutter/material.dart';

import 'package:bluesky/bluesky.dart' as bsky;

import 'package:moyousky/widgets/post_detail/sub_post.dart';

class PreviousRepliesWidget extends StatelessWidget {
  final bsky.PostThreadViewRecord postThreadData;

  PreviousRepliesWidget({Key? key, required this.postThreadData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<bsky.PostThreadViewRecord?> parentList = _getParentList(postThreadData);
    return SubPostWidget(postList: parentList, borderBottom: true,);
  }

  List<bsky.PostThreadViewRecord?> _getParentList(bsky.PostThreadViewRecord recObj, [List<bsky.PostThreadViewRecord?>? res]) {
    res ??= [];
    if (recObj.parent == null) {
      return res;
    }
    final parentObj = recObj.parent as bsky.UPostThreadViewRecord;
    final parent = parentObj.data;
    res.insert(0, parent);
    return _getParentList(parent, res);
  }
}


