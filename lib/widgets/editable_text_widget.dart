import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class EditableTextWidget extends StatefulWidget {
  final String text;
  final String type;
  final TextEditingController controller;
  final Function(String) onSubmit;
  final TextStyle textStyle;
  final bool isPermissionEdit;

  const EditableTextWidget(
      {super.key,
      required this.text,
      this.type = '',
      required this.textStyle,
      this.isPermissionEdit = true,
      required this.onSubmit,
      required this.controller});

  @override
  EditableTextWidgetState createState() => EditableTextWidgetState();
}

class EditableTextWidgetState extends State<EditableTextWidget> {
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
              ? FocusScope(
                  node: FocusScopeNode(),
                  child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          setState(() {
                            _isEditing = false;
                            localText = widget.controller.text;
                            widget.onSubmit(widget.controller.text);
                            print('========> ttttt');
                          });
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.all(ScaleUtils.scaleSize(10, context)),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFA6A6A6)),
                              borderRadius: BorderRadius.circular(
                                  ScaleUtils.scaleSize(8, context))),
                          child: Column(children: [
                            TextField(
                                controller: widget.controller,
                                autofocus: true,
                                maxLines: null,
                                minLines: 1,
                                keyboardType: TextInputType.multiline,
                                onSubmitted: (value) =>
                                    setState(() => _isEditing = false),
                                onEditingComplete: () =>
                                    setState(() => _isEditing = false),
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                    border: InputBorder.none, isDense: true)),
                            SizedBox(height: ScaleUtils.scaleSize(30, context))
                          ]))))
              : SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                              ScaleUtils.scaleSize(5, context)),
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(1000),
                              color: ColorConfig.primary1),
                          child: Text(widget.type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScaleUtils.scaleSize(
                                      8, context)))),
                      // Text(widget.type,
                      //     style: TextStyle(
                      //         height: 1,
                      //         fontWeight: FontWeight.w500,
                      //         color: Colors.black54,
                      //         fontSize: ScaleUtils.scaleSize(8, context))),
                      Text(localText,
                          textAlign: TextAlign.justify,
                          style: widget.textStyle.copyWith(
                            height: 1,
                          ))
                    ],
                  ))),
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

                        // _isEditing = false;
                        // localText = widget.controller.text;
                        // widget.onSubmit(widget.controller.text);
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
                        // _isEditing = false;
                        // widget.controller.text = widget.text;
                        // localText = widget.text;
                        print(
                            '========>jjjjj  ${widget.controller.text} === ${localText} == ${widget.text}');
                        // setState(() {});
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
