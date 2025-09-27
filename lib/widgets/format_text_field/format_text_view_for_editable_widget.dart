import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FormatTextViewForEditableWidget extends StatelessWidget {
  final String content;
  final Function() onTap;

  const FormatTextViewForEditableWidget(
      {super.key, required this.content, required this.onTap});

  @override
  Widget build(BuildContext context) {

    QuillController _controller;

    // if (content.isEmpty) {
    //   _controller = QuillController.basic();
    // } else {
    try {
      // Parse content
      final json = jsonDecode(content);

      if (json is List && json.isNotEmpty && json.first['insert'] != null) {
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } else {
        final formattedContent = [
          {'insert': "$content\n"} // Thêm nội dung vào DeltaQuill
        ];
        _controller = QuillController(
          document: Document.fromJson(formattedContent),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (e) {
      print('Error parsing content: $e');

      final formattedContent = [
        {'insert': "$content\n"} // Thêm nội dung vào DeltaQuill
      ];
      _controller = QuillController(
        document: Document.fromJson(formattedContent),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
    // }
    return GestureDetector(
      onTap: () {
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: QuillEditor.basic(
        controller: _controller,
        config: const QuillEditorConfig(
          scrollable: true,
          autoFocus: false,
          showCursor: false,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
