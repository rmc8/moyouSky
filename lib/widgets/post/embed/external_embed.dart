import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:url_launcher/url_launcher.dart' as ul;

class ExternalEmbed extends StatelessWidget {
  final bsky.EmbedViewExternal data;

  const ExternalEmbed({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewData = data.toJson();
    final uri = viewData['external']['uri'] as String;
    final title = viewData['external']['title'] as String;
    final description = viewData['external']['description'] as String?;
    final img = viewData['external']['thumb'] as String?;

    final domain = Uri.parse(uri).host;

    return InkWell(
      onTap: () async {
        try {
          await ul.launchUrl(Uri.parse(uri),
              mode: ul.LaunchMode.externalApplication);
        } catch (e) {
          print('Could not launch $uri. Error: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (img != null)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final widgetWidth = constraints.maxWidth;
                  final imageProvider = NetworkImage(img);

                  return FutureBuilder<ui.Image>(
                    future: _getImageSize(imageProvider),
                    builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        final image = snapshot.data!;
                        final imageWidth = image.width.toDouble();
                        final imageHeight = image.height.toDouble();

                        final calculatedHeight = widgetWidth / imageWidth * imageHeight;
                        final finalHeight = math.min(widgetWidth, calculatedHeight);

                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(7.0)),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            height: finalHeight,
                            width: widgetWidth,
                          ),
                        );
                      } else {
                        // 画像情報の取得中、またはエラーが発生した場合の表示
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                    ),
                    child: Text(
                      domain,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (description != null)
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<ui.Image> _getImageSize(ImageProvider provider) {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  provider.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo info, bool _) => completer.complete(info.image),
    ),
  );
  return completer.future;
}


