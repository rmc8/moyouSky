import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class TakePictureScreen extends StatefulWidget {
  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // initStateが呼ばれた後に_takePictureメソッドを呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imgFile = getImageFile(pickedFile);
      Navigator.of(context).pop(imgFile);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // カメラのUIを表示しないため、Containerを返す
    return Container();
  }
}

ImageFile getImageFile(XFile pickedFile) {
  return ImageFile(
    UniqueKey().toString(),
    name: pickedFile.name,
    extension: '.jpg',
    path: pickedFile.path,
  );
}
