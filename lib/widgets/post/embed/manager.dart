import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/widgets/post/embed/external_embed.dart';
import 'package:moyousky/widgets/post/embed/image_embed.dart';
import 'package:moyousky/widgets/post/embed/record_embed.dart';
import 'package:moyousky/widgets/post/embed/record_with_media_embed.dart';


class EmbedManager extends StatelessWidget {
  final bsky.Post post;

  const EmbedManager({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final embedObj = post.embed;

    if (embedObj == null) {
      return const SizedBox.shrink();
    }

    Widget childWidget = embedObj.map(
      external: (externalData) {
        return ExternalEmbed(data: externalData.data);
      },
      images: (imageData) {
        return ImageEmbed(data: imageData.data);
      },
      recordWithMedia: (recordWithMediaData) {
        return RecordWithMediaEmbed(data: recordWithMediaData.data);
      },
      record: (recordData) {
        return RecordEmbed(data: recordData.data);
      },
      unknown: (unknownData) {
        return const SizedBox.shrink();
      },
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: childWidget,
    );
  }
}
