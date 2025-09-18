import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class CustomTimePicker extends StatelessWidget {
  const CustomTimePicker({
    super.key,
    required this.defaultTime,
    required this.onOk,
    required this.onCancel,
  });

  final DateTime defaultTime;
  final Function(DateTime) onOk;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimePickerCubit()..initData(defaultTime),
      child: BlocBuilder<TimePickerCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<TimePickerCubit>(c);
          return Container(
            width: ScaleUtils.scaleSize(194, context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ScaleUtils.scaleSize(12, context),
              ),
              border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: ColorConfig.border4,
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScaleUtils.scaleSize(8, context)),
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //       horizontal: ScaleUtils.scaleSize(8, context)),
                //   child: Text(AppText.titleExpectedEndTime.text,
                //       style: TextStyle(
                //           fontSize: ScaleUtils.scaleSize(12, context),
                //           fontWeight: FontWeight.w500,
                //           color: Colors.black)),
                // ),
                SizedBox(height: ScaleUtils.scaleSize(2, context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          cubit.increaseHour();
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up_outlined,
                          size: ScaleUtils.scaleSize(24, context),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          cubit.increaseMinute();
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up_outlined,
                          size: ScaleUtils.scaleSize(24, context),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 0) {
                            // Scroll xuống
                            cubit.increaseHour();
                            print("Scroll down");
                          } else if (details.delta.dy < 0) {
                            // Scroll lên
                            cubit.decreaseHour();
                            print("Scroll up");
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${cubit.time.hour < 23 ? cubit.time.hour + 1 : "0"}",
                            style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 0) {
                            cubit.increaseMinute();
                            print("Scroll down");
                          } else if (details.delta.dy < 0) {
                            cubit.decreaseMinute();
                            print("Scroll up");
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${cubit.time.minute < 59 ? cubit.time.minute + 1 : "0"}",
                            style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Color(0xFFFFECEC),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy > 0) {
                              // Scroll xuống
                              cubit.increaseHour();
                              print("Scroll down");
                            } else if (details.delta.dy < 0) {
                              // Scroll lên
                              cubit.decreaseHour();
                              print("Scroll up");
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${cubit.time.hour} giờ",
                              style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w700,
                                color: ColorConfig.primary3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy > 0) {
                              // Scroll xuống
                              cubit.increaseMinute();
                              print("Scroll down");
                            } else if (details.delta.dy < 0) {
                              // Scroll lên
                              cubit.decreaseMinute();
                              print("Scroll up");
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${cubit.time.minute} phút",
                              style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w700,
                                color: ColorConfig.primary3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 0) {
                            // Scroll xuống
                            cubit.increaseHour();
                            print("Scroll down");
                          } else if (details.delta.dy < 0) {
                            // Scroll lên
                            cubit.decreaseHour();
                            print("Scroll up");
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${cubit.time.hour > 0 ? cubit.time.hour - 1 : 23}",
                            style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.delta.dy > 0) {
                            // Scroll xuống
                            cubit.increaseMinute();
                            print("Scroll down");
                          } else if (details.delta.dy < 0) {
                            // Scroll lên
                            cubit.decreaseMinute();
                            print("Scroll up");
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${cubit.time.minute > 0 ? cubit.time.minute - 1 : 59}",
                            style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          cubit.decreaseHour();
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          size: ScaleUtils.scaleSize(24, context),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          cubit.decreaseMinute();
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          size: ScaleUtils.scaleSize(24, context),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: ScaleUtils.scaleSize(1, context),
                  color: ColorConfig.border4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: IntrinsicWidth(
                          child: ZButton(
                            title: AppText.btnCancel.text,
                            icon: "",
                            colorTitle: ColorConfig.primary2,
                            colorBackground: Colors.white,
                            colorBorder: Colors.white,
                            sizeTitle: 12,
                            paddingVer: 4,
                            onPressed: () {
                              onCancel();
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: IntrinsicWidth(
                          child: ZButton(
                            title: AppText.btnConfirm.text,
                            icon: "",
                            colorTitle: Colors.white,
                            colorBackground: ColorConfig.primary2,
                            colorBorder: ColorConfig.primary2,
                            sizeTitle: 12,
                            paddingVer: 4,
                            onPressed: () {
                              if (context.mounted) {
                                onOk(cubit.time);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScaleUtils.scaleSize(6, context)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TimePickerCubit extends Cubit<int> {
  TimePickerCubit() : super(0);

  DateTime time = DateTime.now();

  initData(DateTime defaultTime) {
    time = defaultTime;
    EMIT();
  }

  increaseHour() {
    if (time.hour == 23) return;
    time = time.copyWith(hour: time.hour + 1);
    EMIT();
  }

  decreaseHour() {
    if (time.hour == 0) return;
    time = time.copyWith(hour: time.hour - 1);
    EMIT();
  }

  increaseMinute() {
    if (time.minute == 59) {
      if (time.hour == 23) return;
      time = time.copyWith(minute: 0);
    } else {
      time = time.copyWith(minute: time.minute + 1);
    }
    EMIT();
  }

  decreaseMinute() {
    if (time.minute == 0) {
      if (time.hour == 0) return;
      time = time.copyWith(minute: 59);
    } else {
      time = time.copyWith(minute: time.minute - 1);
    }
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
