import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/comment_cubit.dart';

class FormatTextFieldForComment extends StatefulWidget {
  final String? initialContent;
  final Function(String) onContentChanged;
  final double fontSize;
  final Color? cursorColor;
  final int maxLines;
  final double fixedLines;
  final CommentCubit cubit;

  const FormatTextFieldForComment(
      {super.key,
      this.initialContent,
      required this.onContentChanged,
      required this.cubit,
      this.fontSize = 14,
      this.cursorColor,
      this.maxLines = 5,
      this.fixedLines = 0});

  @override
  State<FormatTextFieldForComment> createState() =>
      _FormatTextFieldForCommentState();
}

class _FormatTextFieldForCommentState extends State<FormatTextFieldForComment> {
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
            {'insert': "${widget.initialContent}\n"}
            // Thêm nội dung vào DeltaQuill
          ];
          _controller = QuillController(
            document: Document.fromJson(formattedContent),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (e) {
        print('Error parsing content: $e');

        final formattedContent = [
          {'insert': "${widget.initialContent}\n"}
          // Thêm nội dung vào DeltaQuill
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
      if (newLines <= 5) {
        setState(() {
          lines = newLines;
        });
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
                  iconTheme: IconThemeData(color: Colors.black, size: 5),
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
                    config: QuillSimpleToolbarConfig(
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                          base: QuillToolbarBaseButtonOptions(
                        iconSize: 12,
                      )),
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
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                            icon: Icon(
                              Icons.image,
                              size: 16,
                            ),
                            tooltip: AppText.textPickImage.text,
                            onPressed: () async {
                              await widget.cubit.pickImage();
                            }),
                        QuillToolbarCustomButtonOptions(
                            icon: Icon(
                              Icons.video_camera_back_rounded,
                              size: 16,
                            ),
                            tooltip: AppText.textPickVideo.text,
                            onPressed: () async {
                              await widget.cubit.pickVideo();
                            }),
                        QuillToolbarCustomButtonOptions(
                            icon: Icon(
                              Icons.attachment,
                              size: 16,
                            ),
                            tooltip: AppText.textPickFile.text,
                            onPressed: () async {
                              await widget.cubit.pickFile();
                            })
                      ],
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
              height: widget.fontSize *
                  1.2 *
                  (widget.fixedLines != 0 ? widget.fixedLines : lines),
              constraints: BoxConstraints(
                maxHeight: widget.fontSize *
                    1.2 *
                    (widget.fixedLines != 0 ? widget.fixedLines : lines),
              ),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
                config: QuillEditorConfig(
                  scrollable: true,
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                  // placeholder: 'Nhập nội dung...',
                  // apply font size
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                          fontSize: widget.fontSize,
                          color: Colors.black,
                          fontFamily: 'Afacad'),
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
