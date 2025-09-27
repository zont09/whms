import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:whms/untils/scale_utils.dart';

class FormatTextView extends StatelessWidget {
  final String content;
  final double fontSize;
  final int? maxLines;

  const FormatTextView(
      {super.key, required this.content, this.fontSize = 16, this.maxLines});

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
      // print('Error parsing content: $e');

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

    return AbsorbPointer(
      absorbing: maxLines != null,
      child: QuillEditor.basic(
        controller: _controller,
        config: QuillEditorConfig(
          scrollable: true,
          autoFocus: false,
          showCursor: false,
          padding: EdgeInsets.zero,
          maxHeight: maxLines != null
              ? ScaleUtils.scaleSize(maxLines! * 1.2 * fontSize, context)
              : null,
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize, context),
                  overflow: TextOverflow.ellipsis,
                  fontFamily: 'Afacad'),
              const HorizontalSpacing(0, 0),
              const VerticalSpacing(0, 0),
              const VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }
}
