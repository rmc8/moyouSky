import 'package:url_launcher/url_launcher.dart' as ul;

void launchHelpURL() async {
  const url = 'https://blueskyweb.zendesk.com/';
  try {
    await ul.launchUrl(Uri.parse(url), mode: ul.LaunchMode.externalApplication);
  } catch (e) {
    print('Could not launch $url. Error: $e');
  }
}
