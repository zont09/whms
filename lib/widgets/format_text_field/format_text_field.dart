import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:js' as js;

import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
class FormatTextField extends StatefulWidget {
  final String? initialContent;
  final Function(String) onContentChanged;
  final double fontSize;
  final Color? cursorColor;
  final int maxLines;
  final double fixedLines;
  final Function(String)? onSave;

  const FormatTextField(
      {super.key,
      this.initialContent,
      required this.onContentChanged,
      this.fontSize = 14,
      this.cursorColor,
      this.maxLines = 5,
      this.fixedLines = 0,
      this.onSave});

  @override
  State<FormatTextField> createState() => _FormatTextFieldState();
}

class _FormatTextFieldState extends State<FormatTextField> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  int lines = 2;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    if (widget.initialContent != null) {
      try {
        // Parse content
        final json = jsonDecode(widget.initialContent!);

        if (json is List && json.isNotEmpty && json.first['insert'] != null) {
          _controller = QuillController(
            document: Document.fromJson(json),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          final formattedContent = [
            {'insert': "${widget.initialContent}\n"} // Thêm nội dung vào DeltaQuill
          ];
          _controller = QuillController(
            document: Document.fromJson(formattedContent),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
        final newLines = _controller.document.toPlainText().split('\n').length;
        if (newLines <= widget.maxLines) {
          setState(() {
            lines = newLines;
          });
        }
      } catch (e) {
        print('Error parsing content: $e');

        final formattedContent = [
          {'insert': "${widget.initialContent}\n"} // Thêm nội dung vào DeltaQuill
        ];
        _controller = QuillController(
          document: Document.fromJson(formattedContent),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }

    _controller.document.changes.listen((event) {
      final json = jsonEncode(_controller.document.toDelta().toJson());
      widget.onContentChanged(json);

      final newLines = _controller.document.toPlainText().split('\n').length;
      if (newLines <= widget.maxLines) {
        setState(() {
          lines = newLines;
        });
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if(widget.onSave != null) {
          widget.onSave!(jsonEncode(_controller.document.toDelta().toJson()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: IconThemeData(
                    color: Colors.black,
                  ),
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Color(0xFFFFE5DB),
                    primary: ColorConfig.primary3,
                    secondary: Colors.red,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: QuillSimpleToolbar(
                    controller: _controller,
                    config: const QuillSimpleToolbarConfig(
                      showUndo: false,
                      showRedo: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showCodeBlock: false,
                      showInlineCode: false,
                      showBackgroundColorButton: false,
                      showLeftAlignment: false,
                      showClipboardCopy: false,
                      showClipboardPaste: false,
                      showClipboardCut: false,
                      showClearFormat: false,
                      showIndent: false,
                      showAlignmentButtons: false,
                      showDirection: false,
                      showListBullets: false,
                      showListCheck: false,
                      showListNumbers: false,
                      showQuote: false,
                      showSearchButton: false,
                      showHeaderStyle: false,
                      showSubscript: false,
                      showSuperscript: false,
                      multiRowsDisplay: true,
                      // sharedConfigurations: QuillSharedConfigurations(
                      //   locale: Locale('vi'),
                      // ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.fontSize * 1.2 * (widget.fixedLines != 0 ? widget.fixedLines : lines),
              constraints: BoxConstraints(
                maxHeight: widget.fontSize * 1.2 * (widget.fixedLines != 0 ? widget.fixedLines : lines),
              ),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
                config: QuillEditorConfig(
                  onLaunchUrl: (String? url) {
                    if (url != null && url.isNotEmpty) {
                      try {
                        js.context.callMethod('open', [url, '_blank']);
                      } catch (e) {
                        print('Error opening link: $e');
                      }
                    }
                  },
                  scrollable: true,
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: widget.fontSize,
                        color: Colors.black,
                        fontFamily: 'Afacad'
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                  // set cursor color
                  // cursorColor: widget.cursorColor ?? Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
