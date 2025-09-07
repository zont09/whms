import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/date_field_custom.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.widget,
  });

  final DateFieldCustom widget;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: TextField(
        style: TextStyle(
          fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
          color: widget.textColor,
        ),
        controller: widget.controller,
        cursorColor: widget.textColor,
        cursorHeight: ScaleUtils.scaleSize(widget.fontSize, context),
        decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: ScaleUtils.scaleSize(15, context),
            horizontal: ScaleUtils.scaleSize(12, context),
          ),
          hintStyle: TextStyle(
            fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
            fontWeight: FontWeight.w300,
            color: widget.colorHint,
          ),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(8, context),
            ),
            borderSide: BorderSide(
                color: const Color(0xFFE7E7E7),
                width: ScaleUtils.scaleSize(1, context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(8, context),
            ),
            borderSide: BorderSide(
                color: const Color(0xFFE7E7E7),
                width: ScaleUtils.scaleSize(1, context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(8, context),
            ),
            borderSide: BorderSide(
                color: const Color(0xFFE7E7E7),
                width: ScaleUtils.scaleSize(1, context)),
          ),
        ),
        readOnly: true,
      ),
    );
  }
}