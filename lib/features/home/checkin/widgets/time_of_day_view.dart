import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class TimeOfDayView extends StatelessWidget {
  const TimeOfDayView({super.key, required this.time});

  final Timestamp time;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(34, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: ColorConfig.primary3),
            color: const Color(0xFFedf8ff)),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(12, context),
            vertical: ScaleUtils.scaleSize(4, context)),
        child: Text(DateTimeUtils.convertTimestampToString(time),
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor)));
  }
}
