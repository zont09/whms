import 'package:flutter/material.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/text_utils.dart';

class PriorityWorkingUnitCircle extends StatelessWidget {
  const PriorityWorkingUnitCircle(
      {super.key, required this.priority, required this.size});

  final PriorityLevelDefine priority;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: priority.background),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
      child: Tooltip(
        message: priority.title,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            TextUtils.firstCharInString(priority.title),
            style: TextStyle(
                color: priority.color,
                fontWeight: FontWeight.w500,
                fontSize: ScaleUtils.scaleSize(14, context)),
          ),
        ),
      ),
    );
  }
}
