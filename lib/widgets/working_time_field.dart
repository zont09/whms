import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_custom.dart';

class WorkingTimeField extends StatefulWidget {
  const WorkingTimeField(
      {super.key, required this.initTime, required this.onChange});

  final int initTime;
  final Function(int) onChange;

  @override
  State<WorkingTimeField> createState() => _WorkingTimeFieldState();
}

class _WorkingTimeFieldState extends State<WorkingTimeField> {
  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    hours = widget.initTime ~/ 60;
    minutes = widget.initTime % 60;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
            color: ColorConfig.timeSecondary,
            boxShadow: const [ColorConfig.boxShadow]),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(2, context),
            vertical: ScaleUtils.scaleSize(4, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: EdgeInsets.only(left: ScaleUtils.scaleSize(2, context)),
            //   child: Text(
            //     AppText.titleWorkingTime.text,
            //     style: TextStyle(
            //         fontSize: ScaleUtils.scaleSize(10, context),
            //         color: ColorConfig.textColor,
            //         fontWeight: FontWeight.w500,
            //         letterSpacing: -0.33),
            //   ),
            // ),
            // const ZSpace(h: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownGeneric<int>(
                    onChanged: (v) {
                      setState(() {
                        hours = v;
                      });
                      widget.onChange(hours * 60 + minutes);
                    },
                    fontSize: 14,
                    initItem: hours,
                    maxWidth: 45,
                    maxHeight: 18,
                    itemHeight: 24,
                    options: [...List.generate(24, (i) => i)],
                    itemBuilder: (time, isSelected) {
                      return WorkingTimeItem(
                        time: time,
                        isSelected: isSelected,
                        text: AppText.textHour.text,
                      );
                    }),
                Text(
                  ":",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      color: ColorConfig.timePrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.33),
                ),
                DropdownGeneric<int>(
                    onChanged: (v) {
                      setState(() {
                        minutes = v;
                      });
                      widget.onChange(hours * 60 + minutes);
                    },
                    maxWidth: 55,
                    maxHeight: 18,
                    itemHeight: 24,
                    fontSize: 14,
                    initItem: minutes,
                    options: [...List.generate(13, (i) => i * 5)],
                    itemBuilder: (time, isSelected) {
                      return WorkingTimeItem(
                          time: time,
                          isSelected: isSelected,
                          text: AppText.textMinute.text);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkingTimeItem extends StatelessWidget {
  const WorkingTimeItem(
      {super.key,
      required this.time,
      required this.isSelected,
      required this.text});

  final int time;
  final bool isSelected;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
        color: ColorConfig.timePrimary,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(1, context),
          vertical: ScaleUtils.scaleSize(2, context)),
      margin: EdgeInsets.symmetric(
          vertical: isSelected ? 0 : ScaleUtils.scaleSize(3, context)),
      child: Center(
        child: Text(
          "$time $text",
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(10, context),
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.33),
        ),
      ),
    );
  }
}
