import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class RichTextHelper {
  static TextSpan linkTextSpan({
    required String text,
    required String uri,
    required double fontSize
  }) {
    return TextSpan(
      text: text,
      style: TextStyle(color: Colors.blueAccent, fontSize: fontSize),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          if (await canLaunch(uri)) {
            await launch(uri);
          }
        },
    );
  }

  static TextSpan hashtagTextSpan({required String text, required double fontSize}) {
    return TextSpan(
      text: text,
      style: TextStyle(color: Colors.blueAccent, fontSize: fontSize),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          print("Navigating to another View for hashtag $text");
        },
    );
  }
}
