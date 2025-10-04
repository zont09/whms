import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';

class EditableFormatTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final Function(String) onSubmit;
  final TextStyle textStyle;
  final bool isPermissionEdit;

  const EditableFormatTextField(
      {super.key,
      required this.text,
      required this.textStyle,
      this.isPermissionEdit = true,
      required this.onSubmit,
      required this.controller});

  @override
  EditableFormatTextFieldState createState() => EditableFormatTextFieldState();
}

class EditableFormatTextFieldState extends State<EditableFormatTextField> {
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
    return Stack(alignment: Alignment.bottomRight, children: [
      InkWell(
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
                })
            : IgnorePointer(
                ignoring: widget.isPermissionEdit,
                child: FormatTextView(content: localText)),
      ),
      if (_isEditing)
        Container(
            margin: EdgeInsets.only(
                right: ScaleUtils.scaleSize(10, context),
                bottom: ScaleUtils.scaleSize(10, context)),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        print('========> ooooooo ');

                        setState(() {
                          _isEditing = false;
                        });
                        localText = widget.controller.text;
                        widget.onSubmit(widget.controller.text);
                      },
                      // borderRadius: BorderRadius.circular(
                      //     ScaleUtils.scaleSize(5, context)),
                      child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: ColorConfig.textTertiary,
                                  width: ScaleUtils.scaleSize(1, context)),
                              borderRadius: BorderRadius.circular(
                                  ScaleUtils.scaleSize(5, context))),
                          child: Padding(
                              padding: EdgeInsets.all(
                                  ScaleUtils.scaleSize(5, context)),
                              child: Icon(Icons.check,
                                  color: ColorConfig.textColor,
                                  size: ScaleUtils.scaleSize(16, context)))))),
              SizedBox(width: ScaleUtils.scaleSize(5, context)),
              Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _isEditing = false;
                        widget.controller.text = widget.text;
                        localText = widget.text;
                        print(
                            '========>jjjjj  ${widget.controller.text} === ${localText} == ${widget.text}');
                        setState(() {});
                      },
                      // borderRadius: BorderRadius.circular(
                      //     ScaleUtils.scaleSize(5, context)),
                      child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: ColorConfig.textTertiary,
                                  width: ScaleUtils.scaleSize(1, context)),
                              borderRadius: BorderRadius.circular(
                                  ScaleUtils.scaleSize(5, context))),
                          child: Padding(
                              padding: EdgeInsets.all(
                                  ScaleUtils.scaleSize(5, context)),
                              child: Icon(Icons.close,
                                  color: ColorConfig.textColor,
                                  size: ScaleUtils.scaleSize(16, context))))))
            ]))
    ]);
  }
}
