import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class ZButton extends StatelessWidget {
  const ZButton(
      {super.key,
      required this.title,
      this.icon,
      required this.onPressed,
      this.sizeTitle = 14,
      this.colorTitle = ColorConfig.textPrimary,
      this.sizeIcon = 16,
      this.colorIcon,
      this.colorBorder = ColorConfig.primary2,
      this.colorBackground = ColorConfig.primary2,
      this.paddingHor = 8,
      this.paddingVer = 8,
      this.fontWeight = FontWeight.w500,
      this.radius = 229,
      this.fontFamily = 'Afacad',
      this.suffix,
      this.isShadow = false,
      this.shadowText,
      this.maxWidth,
        this.shadowColor,
      this.enable = true});

  final String title;
  final String? icon;
  final Function() onPressed;

  final double sizeTitle;
  final Color colorTitle;
  final double sizeIcon;
  final Color? colorIcon;
  final Color colorBorder;
  final Color colorBackground;
  final double paddingHor;
  final double paddingVer;
  final FontWeight fontWeight;
  final double radius;
  final String fontFamily;
  final Widget? suffix;
  final bool isShadow;
  final List<BoxShadow>? shadowText;
  final double? maxWidth;
  final Color? shadowColor;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enable,
      child: Stack(
        children: [
          Container(
            width: maxWidth,
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(paddingHor, context),
              vertical: ScaleUtils.scaleSize(paddingVer, context),
            ),
            decoration: BoxDecoration(
                color: enable ? colorBackground : ColorConfig.disable,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: enable ? colorBorder : ColorConfig.disable),
                boxShadow: isShadow
                    ? [
                        BoxShadow(
                            color: shadowColor ?? Colors.black.withOpacity(0.3),
                            blurRadius: ScaleUtils.scaleSize(4, context),
                            offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                      ]
                    : []),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null && icon!.isNotEmpty)
                  Image.asset(
                    icon!,
                    height: ScaleUtils.scaleSize(sizeIcon, context),
                    color: colorIcon,
                  ),
                if (icon != null && icon!.isNotEmpty)
                  SizedBox(width: ScaleUtils.scaleSize(6, context)),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(sizeTitle, context),
                      fontWeight: fontWeight,
                      fontFamily: fontFamily,
                      color: colorTitle,
                      shadows: shadowText),
                ),
                if (suffix != null)
                  SizedBox(
                    width: ScaleUtils.scaleSize(9, context),
                  ),
                if (suffix != null) suffix!,
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onPressed,
                splashColor: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
