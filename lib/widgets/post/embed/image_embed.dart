import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:moyousky/permissions/media.dart';
import 'package:moyousky/utils/fade_route.dart';
import 'package:moyousky/utils/constants.dart' as cons;

const DOUBLE_IMAGE_WIDTH_FACTOR = 0.35;
const SINGLE_IMAGE_WIDTH_FACTOR = 0.725;
const OTHER_IMAGE_WIDTH_FACTOR = 0.29;

class ImageEmbed extends StatelessWidget {
  final bsky.EmbedViewImages data;

  const ImageEmbed({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageData = data.toJson();
    final images = imageData['images'] as List;

    double imageWidth;
    if (images.length == 1) {
      imageWidth =
          MediaQuery.of(context).size.width * SINGLE_IMAGE_WIDTH_FACTOR;
    } else if (images.length == 2) {
      imageWidth =
          MediaQuery.of(context).size.width * DOUBLE_IMAGE_WIDTH_FACTOR;
    } else {
      imageWidth = MediaQuery.of(context).size.width * OTHER_IMAGE_WIDTH_FACTOR;
    }

    bool scrollable = images.length > 1;

    return Container(
      height: imageWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: scrollable ? ScrollPhysics() : NeverScrollableScrollPhysics(),
        child: Row(
          children: images
              .map((image) =>
                  _buildImageThumbnail(context, image, imageWidth, images))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(
      BuildContext context, dynamic image, double imageWidth, List images) {
    final thumbUrl = image['thumb'] as String;
    final altText = image['alt'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(FadeRoute(
            page: ImageGallery(
                images: images, initialIndex: images.indexOf(image))));
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
                  fit: BoxFit.cover, width: imageWidth, height: imageWidth),
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
    try {
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
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "エラーが発生しました: $e");
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
                      if (hasPermission) {
                        _saveImage(fullSizeUrl);
                      } else {
                        Fluttertoast.showToast(msg: "アクセス権限が必要です");
                      }
                    },
                    child: PhotoView(
                      imageProvider: NetworkImage(fullSizeUrl),
                      minScale: PhotoViewComputedScale.contained,
                    ),
                  ),
                  if (altText != null && altText.isNotEmpty)
                    Positioned(
                      bottom: 30,
                      child: Text(
                        altText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: cons.DEFAULT_FONT,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 4.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned(
            top: 60,
            right: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                radius: 20,
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
