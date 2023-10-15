import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

void _launchHpURL() async {
  const url = 'https://https://rmc-8.com/moyouSky';
  try {
    await ul.launchUrl(Uri.parse(url), mode: ul.LaunchMode.externalApplication);
  } catch (e) {
    print('Could not launch $url. Error: $e');
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchHpURL,
      child: const SizedBox(
        height: 36,
        child: Center(
          child: Text(
            'moyouSky',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 89, 186)),
          ),
        ),
      ),
    );
  }
}
