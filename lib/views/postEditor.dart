import 'package:flutter/material.dart';

import 'package:multi_image_picker_view/multi_image_picker_view.dart';

import 'package:moyousky/views/camera.dart';
import 'package:moyousky/views/alternative_text_editor.dart';
import 'package:moyousky/widgets/post_editor/attached_image.dart' as ai;
import 'package:moyousky/repository/shared_preferences_repository.dart';

class OriginalPost {
  final String? displayName;
  final String handle;
  final String? avatar;
  final String recordText;
  final String? imageUrl;

  OriginalPost({
    this.displayName,
    required this.handle,
    this.avatar,
    required this.recordText,
    this.imageUrl,
  });

  @override
  String toString() {
    return 'displayName: $displayName, handle: $handle, avatar: $avatar, recordText: $recordText, imageUrl: $imageUrl';
  }
}

class PostEditor extends StatefulWidget {
  final OriginalPost? originalPost;
  final bool isQuoteRepost;

  const PostEditor({
    Key? key,
    this.originalPost,
    this.isQuoteRepost = false,
  }) : super(key: key);

  @override
  PostEditorState createState() => PostEditorState();
}

class PostEditorState extends State<PostEditor> {
  final TextEditingController _controller = TextEditingController();
  ValueNotifier<List<Map<ImageFile, String?>>> imageFilesNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 80.0,
        leading: Container(
          width: 72.0,
          margin: const EdgeInsets.only(top: 10.5, bottom: 10.5, left: 8.0),
          // Adjust the margins
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              icon: const Icon(Icons.warning_rounded, color: Colors.black45),
              onPressed: () {},
            ),
          ),
          Container(
            height: 50.0,
            width: 60.0,
            margin: const EdgeInsets.only(top: 10.5, bottom: 10.5, right: 8.0),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text(
                "Post",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]);
  }

  Widget _buildBody() {
    if (widget.originalPost == null) {
      // New post
      return _buildNewPostView();
    } else if (!widget.isQuoteRepost) {
      // Reply
      return Column(
        children: [
          _buildOriginalPostView(withQuote: false),
          _buildNewPostView(),
        ],
      );
    } else {
      // QuoteRepost
      return Column(
        children: [
          _buildOriginalPostView(withQuote: true),
          _buildNewPostView(),
        ],
      );
    }
  }

  Widget _buildNewPostView() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  _buildEditor(),
                ],
              ),
              ValueListenableBuilder<List<Map<ImageFile, String?>>>(
                valueListenable: imageFilesNotifier,
                builder: (context, imageFilesWithAlt, child) {
                  return ai.buildImageListView(
                    imageFilesWithAlt,
                    (int index) => _deleteImage(index),
                    (int index, String? newAltText) =>
                        _editAltText(index, newAltText),
                    imageFilesNotifier,
                  );
                },
              ),
            ],
          ),
        ),
        _buildToolBar(),
      ],
    );
  }

  void _deleteImage(int index) {
    List<Map<ImageFile, String?>> updatedList =
        List.from(imageFilesNotifier.value);
    updatedList.removeAt(index);
    imageFilesNotifier.value = updatedList;
  }

  void _editAltText(int index, String? altText) async {
    final imageMap = imageFilesNotifier.value[index];
    final imageFile = imageMap.keys.first;
    final currentAltText = imageMap[imageFile] ?? '';

    final updatedAltText = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AlternativeTextEditor(
          imagePath: imageFile.path!,
          currentAltText: currentAltText,
        ),
      ),
    );

    if (updatedAltText != null) {
      onAltTextChanged(updatedAltText, index);
    }
  }

  void onAltTextChanged(String newAltText, int index) {
    List<Map<ImageFile, String?>> updatedList =
        List.from(imageFilesNotifier.value);
    final imageFile = updatedList[index].keys.first;
    updatedList[index] = {imageFile: newAltText};
    imageFilesNotifier.value = updatedList;
  }

  Future<void> _pickImage() async {
    if (imageFilesNotifier.value.length >= 4) {
      return;
    }
    final controller = MultiImagePickerController(
      maxImages: 4 - imageFilesNotifier.value.length,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
    );
    await controller.pickImages();
    List<Map<ImageFile, String?>> updatedList =
        List.from(imageFilesNotifier.value);
    for (final image in controller.images) {
      if (updatedList.length >= 4) {
        break;
      }
      if (!containsImageFile(image)) {
        const initAltText = '';
        updatedList.add({image: initAltText});
      }
    }
    imageFilesNotifier.value = updatedList;
  }

  bool containsImageFile(ImageFile target) {
    return imageFilesNotifier.value.any((map) =>
        map.values.any((imageFile) => map.keys.first.path == target.path));
  }

  void _camera() async {
    final ImageFile? imageFile = await Navigator.push<ImageFile>(
      context,
      MaterialPageRoute(builder: (context) => TakePictureScreen()),
    );

    if (imageFile != null) {
      _addImageToPost(imageFile);
    }
  }

  void _addImageToPost(ImageFile imageFile) {
    List<Map<ImageFile, String?>> updatedList = List.from(imageFilesNotifier.value);
    updatedList.add({imageFile: ''});
    imageFilesNotifier.value = updatedList;
  }

  Container _buildToolBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: _camera,
          ),
          const Text('日本語'),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return Text(
                '残り ${300 - _controller.text.length} 文字',
                style: (300 - _controller.text.length >= 0)
                    ? null
                    : const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0x0FFC3333)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        onChanged: (text) {
          // TODO: リンク・ハッシュタグの処理
        },
        decoration: const InputDecoration(
          hintText: 'ここにテキストを入力...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final spr = SharedPreferencesRepository();
    return FutureBuilder<String>(
      future: spr.getAvatar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state, you can show a loading indicator here if you want
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any error from the future here
          return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.error_rounded, color: Colors.white));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.person, color: Colors.white));
        } else {
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 22.5,
                backgroundImage: NetworkImage(snapshot.data!),
              ));
        }
      },
    );
  }

  Widget _buildOriginalPostView({required bool withQuote}) {
    String quoteSymbol = withQuote ? '“' : '';
    return Text('$quoteSymbol${widget.originalPost.toString()}$quoteSymbol');
  }

  @override
  void dispose() {
    _controller.dispose();
    imageFilesNotifier.dispose();
    super.dispose();
  }
}
