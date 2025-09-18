import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class TimePickerCustom extends StatelessWidget {
  const TimePickerCustom(
      {super.key, required this.time, required this.onPressed});

  final Timestamp time;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EFFF),
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(24, context)),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFF9F9F9),
                Color(0xFFFFF8F8),
              ],
            ),
            border: Border.all(
              width: 1,
              color: ColorConfig.border
            )
          ),
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(18, context),
              vertical: ScaleUtils.scaleSize(8, context)),
          child: Text(
            DateTimeUtils.convertTimestampToString(time),
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(12, context),
                fontWeight: FontWeight.w600),
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
