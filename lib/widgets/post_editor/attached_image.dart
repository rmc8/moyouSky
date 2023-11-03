import 'dart:io';

import 'package:flutter/material.dart';

import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:moyousky/views/alternative_text_editor.dart';

class _ImageItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onDelete;
  final Function(String) onAltTap;
  final String? currentAltText;

  const _ImageItem({
    Key? key,
    required this.imagePath,
    required this.onDelete,
    required this.onAltTap,
    this.currentAltText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.48,
            height: MediaQuery.of(context).size.width * 0.48,
          ),
        ),
        _buildDeleteButton(onDelete),
        _buildAltButton(context, onAltTap),
      ],
    );
  }

  Widget _buildDeleteButton(VoidCallback onDelete) {
    return Positioned(
      top: 2.0,
      right: 2.0,
      child: GestureDetector(
        onTap: onDelete,
        child: _buildCircleDecoration(
          const Icon(Icons.close, color: Colors.white, size: 20.0),
        ),
      ),
    );
  }

  Widget _buildAltButton(BuildContext context, Function(String) onAltTap) {
    return Positioned(
      top: 2.0,
      left: 2.0,
      child: GestureDetector(
        onTap: () async {
          onAltTap(currentAltText ?? '');
        },
        child: _buildCircleDecoration(
          const Padding(
              padding: EdgeInsets.all(2.5),
              child: Icon(Icons.edit, color: Colors.white, size: 17.5)),
        ),
      ),
    );
  }

  Widget _buildCircleDecoration(Widget child) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

Widget buildImageListView(
  List<Map<ImageFile, String?>> imageFilesWithAlt,
  void Function(int index) onDelete,
  void Function(int index, String? newAltText) onEditAltText,
  ValueNotifier<List<Map<ImageFile, String?>>> imageFilesNotifier,
) {
  final imageLen = imageFilesWithAlt.length;
  return GridView.builder(
    shrinkWrap: true,
    padding: const EdgeInsets.all(8.0),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    ),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: imageLen,
    itemBuilder: (BuildContext context, int index) {
      final imageFile = imageFilesWithAlt[index].keys.first;
      final currentAltText = imageFilesWithAlt[index][imageFile];
      return _ImageItem(
        imagePath: imageFile.path!,
        onDelete: () => onDelete(index),
        onAltTap: (newAltText) {
          onEditAltText(index, newAltText);
        },
        currentAltText: currentAltText,
      );
    },
  );
}
