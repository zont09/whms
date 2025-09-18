import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class SelectTimeOfDayWidget extends StatelessWidget {
  const SelectTimeOfDayWidget({
    super.key,
    required this.onTap,
    required this.time,
  });

  final Function() onTap;
  final Timestamp time;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(34, context)),
                  border: Border.all(
                      width: ScaleUtils.scaleSize(1, context),
                      color: ColorConfig.border4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.16),
                        offset: const Offset(0, 2))
                  ]),
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(12, context),
                  vertical: ScaleUtils.scaleSize(4, context)),
              child: Row(
                children: [
                  Text(DateTimeUtils.convertTimestampToString(time),
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textColor)),
                  SizedBox(width: ScaleUtils.scaleSize(6, context)),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: ScaleUtils.scaleSize(24, context))
                ],
              )),
        ],
      ),
    );
  }
}
