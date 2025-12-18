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
            Container(
              height: ScaleUtils.scaleSize(28, context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: ScaleUtils.scaleSize(2.5, context),
                  color: ColorConfig.primary2,
                ),
              ),
              child: Center(
                child: Icon(Icons.close, weight: 800, size: ScaleUtils.scaleSize(16, context), color: ColorConfig.primary2,),
              ),
            ),
          SizedBox(width: ScaleUtils.scaleSize(9, context)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScaleUtils.scaleSize(24, context),
              fontWeight: FontWeight.w600,
              color: ColorConfig.primary2,
            ),
          ),
        ],
      ),
    );
  }
}
