import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatefulWidget {
  const TextFieldCustom(
      {super.key,
      required this.controller,
      this.radius = 229,
      required this.hint,
      this.minLines = 1,
      this.fontSize = 14,
      required this.isEdit,
      this.borderColor = const Color(0xFFA6A6A6),
      this.background,
      this.borderFocus,
      this.onEnter,
      this.fontWeight = FontWeight.w400,
      this.paddingContentHor = 8,
      this.paddingContentVer = 8,
      this.textColor = Colors.black,
      this.borderWidth = 0.5,
      this.focusNode});

  final TextEditingController controller;
  final double radius;
  final String hint;
  final int? minLines;
  final bool isEdit;
  final double fontSize;
  final Color borderColor;
  final Color? borderFocus;
  final Function(String)? onEnter;
  final FontWeight fontWeight;
  final double paddingContentHor;
  final double paddingContentVer;
  final Color textColor;
  final Color? background;
  final double borderWidth;
  final FocusNode? focusNode;

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && widget.onEnter != null) {
        widget.onEnter!.call(widget.controller.text);
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter &&
              !HardwareKeyboard.instance.isShiftPressed &&
              widget.onEnter != null) {
            // widget.onEnter!.call(widget.controller.text);
            FocusScope.of(context).unfocus(); // Bỏ focus khỏi TextField
          }
        }
      },
      child: TextField(
        enabled: widget.isEdit,
        minLines: widget.minLines,
        maxLines: widget.minLines,
        cursorColor: Colors.black,
        cursorHeight: ScaleUtils.scaleSize(widget.fontSize, context),
        controller: widget.controller,
        style: TextStyle(
            fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
            fontFamily: 'Afacad',
            fontWeight: widget.fontWeight,
            letterSpacing: -0.41,
            color: widget.textColor),
        decoration: InputDecoration(
          isDense: true,
          fillColor: widget.background,
          filled: widget.background != null,
          hintText: widget.hint,
          hintStyle: TextStyle(
              fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
              fontFamily: 'Afacad',
              fontWeight: widget.fontWeight,
              letterSpacing: -0.41,
              color: ColorConfig.hintText),
          contentPadding: EdgeInsets.symmetric(
              vertical: ScaleUtils.scaleSize(widget.paddingContentVer, context),
              horizontal:
                  ScaleUtils.scaleSize(widget.paddingContentHor, context)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: ScaleUtils.scaleSize(widget.borderWidth, context),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: ScaleUtils.scaleSize(widget.borderWidth, context),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: widget.borderFocus ?? widget.borderColor,
              width: ScaleUtils.scaleSize(widget.borderWidth, context),
            ),
          ),
        ),
        textInputAction: TextInputAction.newline,
        onSubmitted: (v) {
          FocusScope.of(context).unfocus();
          widget.onEnter?.call(v);
        },
      ),
    );
  }
}
