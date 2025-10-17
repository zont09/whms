import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final Function() onTap;
  final String title;
  final bool isFirstIcon;
  final double textSize;
  const AddButton(this.title,
      {required this.onTap,
      this.isFirstIcon = false,
      this.textSize = 18,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            overlayColor: ColorConfig.primary4,
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(5, context)),
            backgroundColor: Colors.white,
            elevation: 0),
        child: isFirstIcon
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Card(
                  color: const Color(0xFFFFD1D1),
                  shape: const CircleBorder(),
                  margin: EdgeInsets.zero,
                  child: Padding(
                      padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
                      child: Image.asset('assets/images/icons/ic_add.png',
                          color: ColorConfig.primary2,
                          width: ScaleUtils.scaleSize(11, context),
                          height: ScaleUtils.scaleSize(11, context))),
                ),
                SizedBox(width: ScaleUtils.scaleSize(5, context)),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: ScaleUtils.scaleSize(textSize, context),
                        color: ColorConfig.textColor,
                        letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                        shadows: [
                          BoxShadow(
                              blurRadius: ScaleUtils.scaleSize(4, context),
                              color: Colors.black.withOpacity(0.2),
                              offset:
                                  Offset(0, ScaleUtils.scaleSize(2, context)))
                        ]))
              ])
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: ScaleUtils.scaleSize(textSize, context),
                        color: ColorConfig.textColor,
                        letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                        shadows: [
                          BoxShadow(
                              blurRadius: ScaleUtils.scaleSize(4, context),
                              color: Colors.black.withOpacity(0.2),
                              offset:
                                  Offset(0, ScaleUtils.scaleSize(2, context)))
                        ])),
                SizedBox(width: ScaleUtils.scaleSize(5, context)),
                Card(
                  color: const Color(0xFFFFD1D1),
                  shape: const CircleBorder(),
                  margin: EdgeInsets.zero,
                  child: Padding(
                      padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
                      child: Image.asset('assets/images/icons/ic_add.png',
                          color: ColorConfig.primary2,
                          width: ScaleUtils.scaleSize(11, context),
                          height: ScaleUtils.scaleSize(11, context))),
                )
              ]));
  }
}
