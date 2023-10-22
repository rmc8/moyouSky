import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:moyousky/utils/constants.dart' as c;
import 'package:moyousky/widgets/post/facets/richtext.dart';

class FacetsProcessing extends StatelessWidget {
  final Map<String, dynamic> postData;
  final double? fontSize;

  const FacetsProcessing({Key? key, required this.postData, this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: _buildTextSpans(context),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final text = postData['post']['record']['text'];
    final facets = postData['post']['record']['facets'];
    final currentFontSize = fontSize ?? c.FONT_SIZE;

    if (facets == null || facets.isEmpty) {
      return [_createTextSpan(text, currentFontSize)];
    }

    List<TextSpan> spans = [];
    final facetBytes = utf8.encode(text);
    var lastFacetEndByte = 0;

    for (final facet in facets) {
      for (final feature in facet['features']) {
        final byteStart = facet['index']['byteStart'];
        final byteEnd = min<int>(facet['index']['byteEnd'], facetBytes.length);

        if (byteStart > lastFacetEndByte) {
          spans.add(_createTextSpan(
            utf8.decode(facetBytes.sublist(lastFacetEndByte, byteStart)),
            currentFontSize,
          ));
        }

        spans.add(_processFeature(
            feature,
            utf8.decode(facetBytes.sublist(byteStart, byteEnd)),
            currentFontSize,
            context));
        lastFacetEndByte = byteEnd;
      }
    }

    if (lastFacetEndByte < facetBytes.length) {
      spans.add(_createTextSpan(
          utf8.decode(facetBytes.sublist(lastFacetEndByte)), currentFontSize));
    }

    return spans;
  }

  TextSpan _createTextSpan(String text, double fontSize) {
    return TextSpan(text: text, style: TextStyle(fontSize: fontSize));
  }

  TextSpan _processFeature(Map<String, dynamic> feature, String facetText,
      double fontSize, BuildContext context) {
    switch (feature['\$type']) {
      case 'app.bsky.richtext.facet#link':
        return RichTextHelper.linkTextSpan(
            text: facetText, uri: feature['uri'], fontSize: fontSize);
      case 'app.bsky.richtext.facet#tag':
        return RichTextHelper.hashtagTextSpan(
            text: facetText, fontSize: fontSize, context: context);
      default:
        return _createTextSpan(facetText, fontSize);
    }
  }
}
