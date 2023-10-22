import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;

class UnknownEmbed extends StatelessWidget {
  final bsky.EmbedViewImages data;

  const UnknownEmbed({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unknownEmbedData = data.toJson();
    return const SizedBox.shrink();
  }
}
