import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(229),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x1A000000),
            offset: Offset(0, 4),
          ),
          //box-shadow: 0px 4px 4px 0px #0000001A;
        ],
      ),
      child: TextField(
        style: TextStyle(
          fontSize: ScaleUtils.scaleSize(16, context),
          color: ColorConfig.textColor,
        ),
        controller: widget.controller,
        cursorColor: const Color(0xFF757575),
        obscureText: isObscure,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: ScaleUtils.scaleSize(5, context)),
            child: IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
            ),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: ScaleUtils.scaleSize(10, context),
              right: ScaleUtils.scaleSize(5, context),
            ),
            child: Icon(
              Icons.lock_outline_sharp,
              size: ScaleUtils.scaleSize(15, context),
              color: ColorConfig.mainLogin,
            ),
          ),
          hintText: AppText.titlePassword.text,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: ScaleUtils.scaleSize(17, context),
            horizontal: ScaleUtils.scaleSize(12, context),
          ),
          hintStyle: TextStyle(
            fontSize: ScaleUtils.scaleSize(16, context),
            fontWeight: FontWeight.w300,
            color: ColorConfig.hintText,
          ),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(229, context),
            ),
            borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(229, context),
            ),
            borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(229, context),
            ),
            borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
          ),
        ),
      ),
    );
  }
}
