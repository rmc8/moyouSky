import 'dart:io';

import 'package:flutter/material.dart';

class AlternativeTextEditor extends StatefulWidget {
  final String imagePath;
  final String currentAltText;

  const AlternativeTextEditor({
    Key? key,
    required this.imagePath,
    required this.currentAltText,
  }) : super(key: key);

  @override
  AlternativeTextEditorState createState() => AlternativeTextEditorState();
}

class AlternativeTextEditorState extends State<AlternativeTextEditor> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentAltText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose(); // FocusNodeを破棄
    super.dispose();
  }

  void _completeEditing() {
    if (_formKey.currentState?.validate() ?? false) {
      _focusNode?.unfocus();
      Navigator.of(context).pop(_controller?.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('代替テキストを入力', style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _completeEditing,
              child: const Text('完了'),
            ),
          ],
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.file(
                    File(widget.imagePath),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: _focusNode, // TextFieldにFocusNodeを割り当てる
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'この画像の説明を追加してください...',
                      ),
                      maxLines: null, // Makes it grow vertically
                    ),
                  ),
                ],
              ),
            )));
  }
}
