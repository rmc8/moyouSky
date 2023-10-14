import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moyousky/widgets/post/facets/richtext.dart';
import 'package:moyousky/utils/constants.dart' as c;

class PostWithLinks extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostWithLinks({Key? key, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = _buildTextSpans(context);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: textSpans,
      ),
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final text = postData['post']['record']['text'];
    final facets = postData['post']['record']['facets'];

    List<TextSpan> spans = [];
    final facetBytes = utf8.encode(text);
    var lastFacetEndByte = 0;

    if (facets == null || facets.isEmpty) {
      spans.add(
          TextSpan(text: text, style: const TextStyle(fontSize: c.FONT_SIZE)));
      return spans;
    }

    for (final facet in facets) {
      for (final feature in facet['features']) {
        final byteStart = facet['index']['byteStart'];
        final byteEnd = min<int>(facet['index']['byteEnd'], facetBytes.length);
        final facetText = utf8.decode(facetBytes.sublist(byteStart, byteEnd));

        if (byteStart > lastFacetEndByte) {
          spans.add(
            TextSpan(
              text: utf8.decode(
                facetBytes.sublist(lastFacetEndByte, byteStart),
              ),
              style: const TextStyle(fontSize: c.FONT_SIZE),
            ),
          );
        }

        if (feature['\$type'] == 'app.bsky.richtext.facet#link') {
          spans.add(RichTextHelper.linkTextSpan(
              text: facetText, uri: feature['uri'], fontSize: c.FONT_SIZE));
        } else if (feature['\$type'] == 'app.bsky.richtext.facet#tag') {
          spans.add(RichTextHelper.hashtagTextSpan(
              text: facetText, fontSize: c.FONT_SIZE));
        }

        lastFacetEndByte = byteEnd;
      }
    }

    if (lastFacetEndByte < facetBytes.length) {
      spans.add(
        TextSpan(
          text: utf8
              .decode(facetBytes.sublist(lastFacetEndByte, facetBytes.length)),
          style: const TextStyle(fontSize: c.FONT_SIZE),
        ),
      );
    }

    return spans;
  }
}
