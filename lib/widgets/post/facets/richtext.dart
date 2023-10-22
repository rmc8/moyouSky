import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:moyousky/views/search.dart';

class RichTextHelper {
  static TextSpan linkTextSpan(
      {required String text, required String uri, required double fontSize}) {
    return TextSpan(
      text: text,
      style: TextStyle(color: Colors.blueAccent, fontSize: fontSize),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          try {
            await ul.launchUrl(Uri.parse(uri),
                mode: ul.LaunchMode.externalApplication);
          } catch (e) {
            print('Could not launch $uri. Error: $e');
          }
        },
    );
  }

  static TextSpan hashtagTextSpan(
      {required String text, required double fontSize, required BuildContext context}) {
    return TextSpan(
      text: text,
      style: TextStyle(color: Colors.blueAccent, fontSize: fontSize),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.of(context).push(FadeRoute(page: SearchScreen(initialQuery: text)));
        },
    );
  }
}
