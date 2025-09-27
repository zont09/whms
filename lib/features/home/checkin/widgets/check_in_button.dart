import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class CheckInButton extends StatefulWidget {
  const CheckInButton({super.key, required this.cubit});

  final CheckInCubit cubit;

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  OverlayEntry? _overlayEntry;
  bool isShowToast = false;

  void _showToast(BuildContext context) {
    if (isShowToast) return;
    final overlay = Overlay.of(context);
    isShowToast = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: ScaleUtils.scaleSize(40, context),
        left: MediaQuery.of(context).size.width / 2 -
            ScaleUtils.scaleSize(180, context),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(16, context),
                vertical: ScaleUtils.scaleSize(8, context)),
            decoration: BoxDecoration(
                color: ColorConfig.primary2,
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                boxShadow: const [ColorConfig.boxShadow2]),
            child: Text(
              AppText.textCheckInNoTask.text,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: ScaleUtils.scaleSize(16, context)),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 4), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
      isShowToast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return ZButton(
        paddingHor: 14,
        title: AppText.btnCheckIn.text,
        icon: "",
        colorBackground: const Color(0xFFFF474E),
        colorBorder: const Color(0xFFFF474E),
        sizeTitle: 16,
        paddingVer: 6,
        fontWeight: FontWeight.w600,
        onPressed: () async {
          if (widget.cubit.listWorkSelected.isEmpty) {
            // DialogUtils.showResultDialog(context,
            //     AppText.titleFailed.text, AppText.textChooseWork.text,
            //     mainColor: ColorConfig.error);
            _showToast(context);
            return;
          }
          bool isSuccess = false;
          await DialogUtils.handleDialog(context, () async {
            try {
              String idWorkShift = FirebaseFirestore.instance
                  .collection('whms_pls_work_shift')
                  .doc()
                  .id;
              WorkShiftModel workShift = WorkShiftModel(
                  id: idWorkShift,
                  status: 1,
                  user: ConfigsCubit.fromContext(context).user.id,
                  checkIn: widget.cubit.startTime,
                  checkOut: widget.cubit.endTime,
                  breakTimes: [],
                  resumeTimes: [],
                  date: DateTimeUtils.getCurrentDate());
              for (int i = 0; i < widget.cubit.listWorkSelected.length; i++) {
                WorkingUnitModel work = widget.cubit.listWorkSelected[i];
                String newId = FirebaseFirestore.instance
                    .collection('whms_pls_work_field')
                    .doc()
                    .id;
                WorkFieldModel workField = WorkFieldModel(
                    id: newId,
                    taskId: work.id.toString(),
                    fromStatus: work.status,
                    toStatus: work.status,
                    duration: widget.cubit.mapWorkingTime[work.id] ?? 10,
                    date: DateTimeUtils.getCurrentDate(),
                    workShift: idWorkShift,
                    enable: true);
                await cfC.addWorkField(workField, isAsync: true);
                // await workService.addNewWorkField(workField);

                if (widget.cubit.mapWorkChild.containsKey(work.id)) {
                  for (var subtask in widget.cubit.mapWorkChild[work.id]!) {
                    WorkFieldModel wfSubtask = WorkFieldModel(
                        id: FirebaseFirestore.instance
                            .collection('whms_pls_work_field')
                            .doc()
                            .id,
                        taskId: subtask.id,
                        fromStatus: subtask.status,
                        toStatus: subtask.status,
                        duration: widget.cubit.mapWorkingTime[subtask.id] ?? 0,
                        date: DateTimeUtils.getCurrentDate(),
                        workShift: idWorkShift,
                        enable: true);
                    cfC.addWorkField(wfSubtask);
                    // await workService.addNewWorkField(wfSubtask);
                  }
                }
              }
              cfC.addWorkShift(workShift);
              // await UserServices.instance.addNewWorkShift(workShift);
              isSuccess = true;
              return ResponseModel(status: ResponseStatus.ok, results: "");
            } catch (e) {
              return ResponseModel(
                  status: ResponseStatus.error,
                  error: ErrorModel(text: e.toString()));
            }
          }, () {},
              successMessage: AppText.textCheckInSuccess.text,
              successTitle: AppText.titleSuccess.text,
              failedMessage: AppText.textCheckInFailed.text,
              failedTitle: AppText.titleFailed.text,
              isShowDialogSuccess: false);
          if (isSuccess && context.mounted) {
            await ConfigsCubit.fromContext(context)
                .changeCheckIn(StatusCheckInDefine.checkIn);
          }
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        });
  }
}
