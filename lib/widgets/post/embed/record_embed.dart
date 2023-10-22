import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:moyousky/views/post_details.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:moyousky/utils/post_author_data.dart';

class RecordEmbed extends StatelessWidget {
  final bsky.EmbedViewRecord data;

  const RecordEmbed({Key? key, required this.data}) : super(key: key);

  String getFormattedPostValue(String postValue) {
    const int maxLength = 128;
    const int maxNewLines = 5;

    int numNewLines = postValue
        .split('\n')
        .length - 1;
    if (postValue.length > maxLength || numNewLines > maxNewLines) {
      int endIndex = math.min(maxLength, postValue.length);
      String result = postValue.substring(0, endIndex);
      int lastNewLine = result.lastIndexOf('\n');
      if (numNewLines > maxNewLines && lastNewLine != -1) {
        result = result.substring(0, lastNewLine);
      }
      return '${result.trim()}...';
    }
    return postValue;
  }

  String? getThumbUrlFromEmbeds(dynamic embeds) {
    if (embeds != null && embeds.isNotEmpty) {
      final images = embeds[0]['images'];
      if (images != null && images.isNotEmpty) {
        return images[0]['thumb'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final recData = data.toJson();
    final record = recData['record'];
    final uri = bsky.AtUri.parse(record['uri']);
    final handle = record['author']['handle'];
    final displayName = record['author']['displayName'];
    final avatar = record['author']['avatar'];
    final did = record['author']['did'];
    final postValue = getFormattedPostValue(record['value']['text']);
    final embeds = record?['embeds'];
    final thumbUrl = getThumbUrlFromEmbeds(embeds);
    final author = AuthorData(
      displayName: displayName ?? handle,
      handle: handle,
      avatar: avatar,
      did: did,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PostDetails(
                  uri: uri,
                  authorData: author,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13.5,
                  backgroundImage:
                  (avatar != null) ? NetworkImage(avatar) : null,
                  child: (avatar == null)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 6.0),
                Text(
                  displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
                const SizedBox(width: 4.0),
                Text(
                  handle,
                  style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                ),
              ],
            ),
            Text(postValue, style: const TextStyle(fontSize: 15.0)),
            if (thumbUrl != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        thumbUrl,
                        width: width,
                        height: (height > width) ? width : height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
