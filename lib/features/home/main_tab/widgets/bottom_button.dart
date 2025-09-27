import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.mainColor = ColorConfig.primary2,
    this.backgroundColor = Colors.white,
    this.borderColor = ColorConfig.border2,
  });

  final String title;
  final String icon;
  final Color? mainColor;
  final Color backgroundColor;
  final Color borderColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: ScaleUtils.scaleSize(60, context),
          padding: EdgeInsets.symmetric(
              vertical: ScaleUtils.scalePadding(10, context),
              horizontal: ScaleUtils.scalePadding(20, context)),
          decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
              border: Border.all(
                  width: ScaleUtils.scaleSize(1, context), color: borderColor),
              color: backgroundColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: ScaleUtils.scaleSize(26, context),
                color: mainColor,
              ),
              if(title.isNotEmpty)
              SizedBox(
                width: ScaleUtils.scaleSize(10, context),
              ),
              if(title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(20, context),
                    fontWeight: FontWeight.w600,
                    color: mainColor),
              )
            ],
          ),
        ),
        Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  onTap: onPressed),
            ))
      ],
    );
  }
}
