import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moyousky/animation/fade_route.dart';
import 'package:moyousky/permissions/media.dart';
import 'package:moyousky/utils/constants.dart' as cons;

class ImageEmbed extends StatelessWidget {
  final bsky.EmbedViewImages data;

  const ImageEmbed({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageData = data.toJson();
    final images = imageData['images'] as List;

    double imageWidth;
    if (images.length == 1) {
      imageWidth = MediaQuery.of(context).size.width * 0.725;
    } else if (images.length == 2) {
      imageWidth = MediaQuery.of(context).size.width * 0.35;
    } else {
      imageWidth = MediaQuery.of(context).size.width * 0.29;
    }

    bool scrollable = images.length > 1;

    return Container(
      height: imageWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: scrollable ? ScrollPhysics() : NeverScrollableScrollPhysics(),
        // ここでスクロールを制御
        child: Row(
          children: images.map((image) {
            final thumbUrl = image['thumb'] as String;
            final altText = image['alt'] as String?;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    FadeRoute(
                        page: ImageGallery(images: images, initialIndex: images.indexOf(image))
                    )
                );
              },
              child: Container(
                width: imageWidth,
                height: imageWidth,
                margin: EdgeInsets.only(
                  right: image == images.last ? 0.0 : 11.5,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(thumbUrl,
                          fit: BoxFit.cover,
                          width: imageWidth,
                          height: imageWidth),
                    ),
                    if (altText != null && altText.isNotEmpty)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(0.5),
                            child: Text(
                              ' Alt ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: cons.DEFAULT_FONT),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  final List images;
  final int initialIndex;

  final MediaPermissionsHandler permissionsHandler = MediaPermissionsHandler();

  ImageGallery({super.key, required this.images, required this.initialIndex});

  Future<bool> requestStoragePermission() async {
    MediaPermissionStatus status = await permissionsHandler.request();
    return status == MediaPermissionStatus.granted;
  }

  Future<void> _saveImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final result = await ImageGallerySaver.saveImage(bytes);
      if (result["isSuccess"]) {
        Fluttertoast.showToast(msg: "画像を保存しました");
      } else {
        Fluttertoast.showToast(msg: "画像の保存に失敗しました");
      }
    } else {
      Fluttertoast.showToast(msg: "画像の取得に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0x88000000),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final fullSizeUrl = images[index]['fullsize'] as String;
              final altText = images[index]['alt'] as String?;

              return Stack(
                children: [
                  GestureDetector(
                    onLongPress: () async {
                      bool hasPermission = await requestStoragePermission();
                      try {
                        _saveImage(fullSizeUrl);
                      } catch(e) {
                        print(e);
                        if (!hasPermission) {
                          Fluttertoast.showToast(msg: "アクセス権限が必要です");
                        } else {
                          Fluttertoast.showToast(msg: "アクセス権限が必要です: $e");
                        }
                      }
                    },
                    child: PhotoView(
                      backgroundDecoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.4)),
                      imageProvider: NetworkImage(fullSizeUrl),
                      heroAttributes: PhotoViewHeroAttributes(tag: fullSizeUrl),
                    ),
                  ),
                  if (altText != null && altText.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            altText,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
          Positioned(
            top: 64,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.33),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
