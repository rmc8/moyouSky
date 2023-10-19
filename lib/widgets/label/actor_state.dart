import 'package:flutter/material.dart';

enum LabelType { following,follower, mutualFollow, muted, blocked, spam }

class LabelWidget extends StatelessWidget {
  final LabelType labelType;

  const LabelWidget({Key? key, required this.labelType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String labelText;

    switch (labelType) {
      case LabelType.following:
        labelText = "フォロー";
        break;
      case LabelType.follower:
        labelText = "フォロワー";
        break;
      case LabelType.mutualFollow:
        labelText = "相互フォロー";
        break;
      case LabelType.muted:
        labelText = "ミュート";
        break;
      case LabelType.blocked:
        labelText = "ブロック";
        break;
      case LabelType.spam:
        labelText = "スパム";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      margin: const EdgeInsets.only(right: 4.0), // 右側の外の余白
      decoration: BoxDecoration(
        color: Colors.grey[200], // 薄いグレーの背景
        borderRadius: BorderRadius.circular(8.0), // 角丸
      ),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 12.0, // 小さい文字
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
