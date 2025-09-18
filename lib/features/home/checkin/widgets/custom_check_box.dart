import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox(
      {super.key,
      required this.isActive,
      required this.onTap,
      this.colorBorder = ColorConfig.border5,
      this.colorCheck = Colors.white,
      this.colorActive = ColorConfig.border5,
      this.colorInactive = Colors.white,
      this.size = 11});

  final bool isActive;
  final Function() onTap;
  final Color colorBorder;
  final Color colorCheck;
  final Color colorActive;
  final Color colorInactive;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: ScaleUtils.scaleSize(size, context),
        width: ScaleUtils.scaleSize(size, context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(3, context)),
          border: Border.all(
              width: ScaleUtils.scaleSize(2, context), color: colorBorder),
          color: isActive ? colorActive : colorInactive,
        ),
        // padding: EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
        child: Icon(
          Icons.check,
          size: ScaleUtils.scaleSize(size - 3, context),
          weight: 1500,
          color: colorCheck,
        ),
      ),
    );
  }
}
