import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';

class ChooseDatetimeItem extends StatefulWidget {
  final bool isEdit;
  final TextEditingController controller;
  final DateTime initialStart;
  final DateTime? deadline;
  final String icon;
  final Function(DateTime) onTap;
  final bool isShowIcon;
  const ChooseDatetimeItem(
      {this.isEdit = true,
      required this.controller,
      required this.initialStart,
      required this.onTap,
      this.isShowIcon = true,
      this.icon = 'assets/images/icons/ic_urgent_date.png',
      this.deadline,
      super.key});

  @override
  ChooseDatetimeItemState createState() => ChooseDatetimeItemState();
}

class ChooseDatetimeItemState extends State<ChooseDatetimeItem> {
  DateTime? selectedDate;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: widget.initialStart,
        lastDate: widget.deadline ?? DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ColorConfig.primary1,
                  surface: Colors.white,
                ),
              ),
              child: child!);
        });
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        widget.controller.text =
            DateTimeUtils.formatDateDayMonthYear(selectedDate!);
        widget.onTap(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: const Color(0xFF323232),
                selectionColor: const Color(0xFF323232).withOpacity(0.3),
                selectionHandleColor: const Color(0xFF323232))),
        child: InkWell(
            onTap: widget.isEdit ? () async => _pickDate() : (){
              ToastUtils.showBottomToast(context, AppText.toastNotCreator.text);
            },
            borderRadius: BorderRadius.circular(1000),
            child: Container(
                alignment: Alignment.center,
                height: ScaleUtils.scaleSize(32, context),
                // width: ScaleUtils.scaleSize(
                //     widget.controller.text ==
                //             '${AppText.textTime.text} ${AppText.titleUrgent.text}'
                //         ? 125
                //         : 100,
                //     context),
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(10, context)
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFFD7D7D7),
                        width: ScaleUtils.scaleSize(1, context)),
                    borderRadius: BorderRadius.circular(1000),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        offset: Offset(1, 1),
                        blurRadius: 5.9,
                        spreadRadius: 0,
                      ),
                    ]),
                child: Row(
                  children: [
                    if (widget.isShowIcon) Image.asset(widget.icon, scale: 4),
                    SizedBox(width: ScaleUtils.scaleSize(5, context)),
                    Text(widget.controller.text,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: ScaleUtils.scaleSize(12, context),
                            color: ColorConfig.textColor)),
                    if (widget.controller.text ==
                        '${AppText.textTime.text} ${AppText.titleUrgent.text}')
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: ColorConfig.textColor,
                          size: ScaleUtils.scaleSize(20, context))
                  ],
                ))));
  }
}
