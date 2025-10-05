import 'package:flutter/material.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';

class EditableTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final Function(String) onSave;
  final bool isPermissionEdit;

  const EditableTextField(
      {super.key,
      required this.text,
      this.isPermissionEdit = true,
      required this.onSave,
      required this.controller});

  @override
  EditableTextFieldState createState() => EditableTextFieldState();
}

class EditableTextFieldState extends State<EditableTextField> {
  bool _isEditing = false;
  bool isUpdate = false;
  late String localText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    localText = widget.text;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isEditing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: _focusNode,
      onTap: widget.isPermissionEdit
          ? () {
              setState(() => _isEditing = true);
            }
          : null,
      child: _isEditing
          ? FormatTextField(
              initialContent: widget.controller.text,
              fixedLines: 10,
              onContentChanged: (v) {
                widget.controller.text = v;
              },
              onSave: (v) {
                widget.onSave(v);
              },
            )
          : IgnorePointer(
              ignoring: widget.isPermissionEdit,
              child: FormatTextView(content: localText)),
    );
  }
}
