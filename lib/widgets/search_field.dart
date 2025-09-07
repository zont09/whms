import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class SearchField extends StatelessWidget {
  const SearchField(
      {super.key,
      this.fontSize = 18,
      this.hintText,
      this.padHor = 12,
      this.padVer = 15,
      this.radius = 229,
      this.mainColor = ColorConfig.mainLogin,
      required this.controller,
      required this.onChanged});

  final double fontSize;
  final double padVer;
  final double padHor;
  final double radius;
  final String? hintText;
  final TextEditingController controller;
  final Color mainColor;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: mainColor,
          selectionColor: mainColor.withOpacity(0.3),
          selectionHandleColor: mainColor,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
            boxShadow: const [ColorConfig.boxShadow2]),
        child: TextField(
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(fontSize, context),
              color: mainColor),
          controller: controller,
          cursorColor: mainColor,
          cursorHeight: ScaleUtils.scaleSize(fontSize, context),
          onChanged: (value) => onChanged(value),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                  left: ScaleUtils.scaleSize(14, context),
                  right: ScaleUtils.scaleSize(8, context)),
              child: Icon(
                Icons.search,
                size: ScaleUtils.scaleSize(fontSize + 5, context),
                color: mainColor,
              ),
            ),
            hintText: hintText ?? AppText.titleSearch.text,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(padVer, context),
                horizontal: ScaleUtils.scaleSize(padHor, context)),
            hintStyle: TextStyle(
                fontSize: ScaleUtils.scaleSize(fontSize, context),
                fontWeight: FontWeight.w300,
                color: mainColor.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
              borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
              borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
              borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
            ),
          ),
        ),
      ),
    );
  }
}
