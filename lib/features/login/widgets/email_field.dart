import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controllerEmail,
  });

  final TextEditingController controllerEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(229),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // Màu shadow tương ứng với #0000001A
            offset: Offset(0, 4), // Tương ứng với 0px 4px
            blurRadius: 4, // Tương ứng với blur radius = 4px
            spreadRadius: 0, // Không có spread (giá trị mặc định)
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(
            fontSize: ScaleUtils.scaleSize(16, context),
            color: ColorConfig.textColor),
        controller: controllerEmail,
        cursorColor: const Color(0xFF757575),
        decoration: InputDecoration(
          // prefix: Image.asset(
          //   'assets/images/icons/ic_login_user.png',
          //   height: ScaleUtils.scaleSize(24, context),
          //   width: ScaleUtils.scaleSize(24, context),
          //   color: ColorConfig.mainLogin,
          // ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                left: ScaleUtils.scaleSize(10, context),
                right: ScaleUtils.scaleSize(5, context)),
            child: Icon(
              Icons.email_outlined, size: ScaleUtils.scaleSize(15, context),
              color: ColorConfig.mainLogin,)
        ),
        hintText: AppText.titleEmail.text,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
            vertical: ScaleUtils.scaleSize(17, context),
            horizontal: ScaleUtils.scaleSize(12, context)),
        hintStyle: TextStyle(
            fontSize: ScaleUtils.scaleSize(16, context),
            fontWeight: FontWeight.w300,
            color: ColorConfig.hintText),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ScaleUtils.scaleSize(229, context)),
          borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ScaleUtils.scaleSize(229, context)),
          borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(ScaleUtils.scaleSize(229, context)),
          borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
        ),
      ),
    ),);
  }
}
