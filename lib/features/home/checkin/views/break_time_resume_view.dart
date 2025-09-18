import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/widgets/custom_time_picker.dart';
import 'package:whms/features/home/checkin/widgets/select_time_of_day.dart';
import 'package:whms/features/home/checkin/widgets/time_of_day_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class BreakTimeResumeView extends StatelessWidget {
  const BreakTimeResumeView({super.key, required this.cubit});

  final CheckOutCubit cubit;

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    return BlocProvider(
      create: (context) => BreakResumeCubit(),
      child: BlocBuilder<BreakResumeCubit, int>(
        builder: (cc, ss) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  if (checkIn == StatusCheckInDefine.checkIn)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(AppText.titleTimeBreak.text,
                            style: TextStyle(
                                color: ColorConfig.textColor6,
                                fontSize: ScaleUtils.scaleSize(18, context),
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.41)),
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(18, context)),
                      Expanded(
                        flex: 5,
                        child: SelectTimeOfDayWidget(
                            onTap: () {
                              showCustomOverlay(context, cubit, false);
                              // cubitBR.changeTimePicker(!cubitBR.openTP);
                              // if(cubitBR.openTP) {
                              //
                              // }
                            },
                            time: DateTimeUtils.getTimestampWithDateTime(cubit.timeBreak)),
                      )
                    ],
                  ),
                  if (checkIn == StatusCheckInDefine.checkIn)
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  if (checkIn == StatusCheckInDefine.checkIn)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(AppText.titleTimeResume.text,
                              style: TextStyle(
                                  color: ColorConfig.textColor6,
                                  fontSize: ScaleUtils.scaleSize(18, context),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.41)),
                        ),
                        SizedBox(width: ScaleUtils.scaleSize(18, context)),
                        Expanded(
                          flex: 5,
                          child: SelectTimeOfDayWidget(
                              onTap: () {
                                showCustomOverlay(context, cubit, true);
                                // cubitBR.changeTimePicker(!cubitBR.openTP);
                                // if(cubitBR.openTP) {
                                //
                                // }
                              },
                              time: DateTimeUtils.getTimestampWithDateTime(cubit.timeResume)),
                        )
                      ],
                    ),
                  if (checkIn == StatusCheckInDefine.breakTime)
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(AppText.titleTimeRecordBreakTime.text,
                              style: TextStyle(
                                  color: ColorConfig.textColor6,
                                  fontSize: ScaleUtils.scaleSize(18, context),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.41)),
                        ),
                        SizedBox(width: ScaleUtils.scaleSize(18, context)),
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              TimeOfDayView(
                                  time: cubit.workShift.breakTimes.last),
                            ],
                          ),
                        )
                      ],
                    ),
                  if (checkIn == StatusCheckInDefine.breakTime)
                    SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  if (checkIn == StatusCheckInDefine.breakTime)
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(AppText.titleTimeRecordResume.text,
                              style: TextStyle(
                                  color: ColorConfig.textColor6,
                                  fontSize: ScaleUtils.scaleSize(18, context),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.41)),
                        ),
                        SizedBox(width: ScaleUtils.scaleSize(18, context)),
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              TimeOfDayView(
                                  time: DateTimeUtils.getTimestampNow()),
                            ],
                          ),
                        )
                      ],
                    ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void showCustomOverlay(BuildContext context, CheckOutCubit cubit, bool isResume) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    final maxH = MediaQuery.of(context).size.height;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Container(
              color: Colors.transparent, // Để nhận sự kiện click
            ),
          ),
          Positioned(
            top: isResume ? 470 * maxH / 788  : 416 * maxH / 788,
            left: ScaleUtils.scaleSize(632, context),
            child: SizedBox(
              child: Material(
                color: Colors.transparent,
                child: CustomTimePicker(
                  defaultTime: DateTime.now(),
                  onOk: (v) {
                    if(isResume) {
                      cubit.changeTimeResume(v);
                    }
                    else {
                      cubit.changeTimeBreak(v);
                    }
                    overlayEntry.remove();
                  },
                  onCancel: () {
                    overlayEntry.remove(); // Đóng overlay khi nhấn Cancel
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class BreakResumeCubit extends Cubit<int> {
  BreakResumeCubit() : super(0);

  bool openTP = false;
  DateTime resumeTime = DateTime.now();

  changeTimePicker(bool v) {
    openTP = v;
    EMIT();
  }

  changeResumeTime(DateTime time) {
    resumeTime = time;
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
