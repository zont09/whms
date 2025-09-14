import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final int? minLines;
  final double radius;
  final double fontSize;

  const InputField(
      {required this.hintText,
      required this.controller,
      this.minLines = 1,
      this.radius = 8,
      this.fontSize = 16,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: minLines,
      maxLines: minLines,
      cursorHeight: ScaleUtils.scaleSize(fontSize, context),
      cursorColor: ColorConfig.textTertiary,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: ScaleUtils.scalePadding(10, context),
          horizontal: ScaleUtils.scalePadding(15, context),
        ),
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scalePadding(radius, context)),
        ),
        hintStyle: TextStyle(
            color: const Color(0xFF757575),
            fontSize: ScaleUtils.scaleSize(fontSize, context),
            fontWeight: FontWeight.w400),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scalePadding(radius, context)),
          borderSide: BorderSide(
              color: const Color(0xFFA6A6A6),
              width: ScaleUtils.scaleSize(0.5, context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scalePadding(radius, context)),
          borderSide: BorderSide(
              color: ColorConfig.primary2,
              width: ScaleUtils.scaleSize(0.5, context)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng không để trống';
        }
        return null;
      },
    );
  }
}
