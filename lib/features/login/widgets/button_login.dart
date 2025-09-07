import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({super.key, required this.title, required this.onPressed});

  final String title;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConfig.primary2,
          shadowColor: ColorConfig.primary2,
          elevation: 2,
          padding: EdgeInsets.symmetric(
            vertical: ScaleUtils.scaleSize(14, context),
            horizontal: ScaleUtils.scaleSize(90, context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(229),
          ),
        ),
        child: Text(
          AppText.btnLogin.text,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(20, context),
              fontWeight: FontWeight.w700,
              color: ColorConfig.textPrimary),
        ));
  }
}
