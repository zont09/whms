import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class TaskButton extends StatelessWidget {
  const TaskButton({super.key, required this.onPressed});

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(229),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: ColorConfig.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2))
              ],
              border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: ColorConfig.border,
              )),
          padding: EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppText.btnTask.text,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(14, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.textColor,
                ),
              ),
              SizedBox(width: ScaleUtils.scaleSize(6, context),),
              Image.asset('assets/images/icons/ic_add_task.png', height: ScaleUtils.scaleSize(24, context),)
            ],
          ),
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(229, context)),
              onTap: onPressed),
        ))
      ],
    );
  }
}
