import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class ModeLine extends StatelessWidget {
  const ModeLine({
    super.key,
    required this.title,
    required this.onTap,
    this.isShowIcon = true,
  });

  final bool isShowIcon;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isShowIcon)
            Image.asset(
              'assets/images/icons/ic_close.png',
              height: ScaleUtils.scaleSize(28, context),
            ),
          SizedBox(width: ScaleUtils.scaleSize(9, context)),
          Text(title,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(24, context),
                  fontWeight: FontWeight.w600,
                  color: ColorConfig.primary2))
        ],
      ),
    );
  }
}
