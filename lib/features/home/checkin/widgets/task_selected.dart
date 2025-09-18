import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/widgets/main_work_content.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/checkin/widgets/status_dropdown.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class TaskSelected extends StatelessWidget {
  const TaskSelected(
      {super.key,
      required this.work,
      required this.onTap,
      this.isInSelectedView = false,
      this.isSelected = false,
      required this.cubit});

  final WorkingUnitModel work;
  final Function(dynamic) onTap;
  final bool isInSelectedView;
  final bool isSelected;
  final CheckInCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    final cfC = ConfigsCubit.fromContext(context);
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
            width: ScaleUtils.scaleSize(1, context), color: ColorConfig.border),
      )),
      padding: EdgeInsets.only(bottom: ScaleUtils.scaleSize(9, context)),
      margin: EdgeInsets.only(top: ScaleUtils.scaleSize(9, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isInSelectedView && checkIn == StatusCheckInDefine.notCheckIn)
            InkWell(
              onTap: () => onTap(work),
              child: Image.asset('assets/images/icons/ic_close_task.png',
                  height: ScaleUtils.scaleSize(20, context)),
            ),
          if (isInSelectedView)
            InkWell(
              onTap: () => onTap(!isSelected),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScaleUtils.scaleSize(2, context)),
                    border: Border.all(
                        width: ScaleUtils.scaleSize(2, context),
                        color: const Color(0xFFB71C1C)),
                    color: isSelected ? const Color(0xFFB71C1C) : Colors.white),
                height: ScaleUtils.scaleSize(20, context),
                width: ScaleUtils.scaleSize(20, context),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check,
                  weight: 900,
                  size: ScaleUtils.scaleSize(16, context),
                  color: Colors.white,
                ),
              ),
            ),
          if (checkIn == StatusCheckInDefine.notCheckIn || isInSelectedView)
            SizedBox(width: ScaleUtils.scaleSize(18, context)),
          Expanded(
              child: MainWorkContent(
            work: work,
            isInSelectedView: isInSelectedView,
            cubit: cubit,
          )),
          IntrinsicHeight(
              child: checkIn == StatusCheckInDefine.checkIn && !isInSelectedView
                  ? IntrinsicWidth(
                      child: StatusDropdown(
                          options: [
                            const StatusCard(
                              status: 0,
                              isDropdown: true,
                            ),
                            const StatusCard(status: 1, isDropdown: true),
                            const StatusCard(status: 2, isDropdown: true),
                            const StatusCard(status: 3, isDropdown: true),
                            const StatusCard(status: 4, isDropdown: true),
                            const StatusCard(status: 5, isDropdown: true),
                            const StatusCard(status: 6, isDropdown: true),
                            StatusCard(
                                status:
                                    (100 <= work.status && work.status < 200)
                                        ? work.status
                                        : 100,
                                isDropdown: true),
                            StatusCard(
                                status:
                                    (200 <= work.status && work.status < 300)
                                        ? work.status
                                        : 200,
                                isDropdown: true),
                            StatusCard(
                                status:
                                    (300 <= work.status && work.status < 400)
                                        ? work.status
                                        : 300,
                                isDropdown: true),
                          ],
                          defaultValue: getPosition(work.status),
                          onChanged: (index) async {
                            DialogUtils.showLoadingDialog(context);
                            final workService = WorkingService.instance;
                            final user = ConfigsCubit.fromContext(context).user;
                            final workShift = await UserServices.instance
                                .getWorkShiftByIdUserAndDate(
                                    user.id, DateTimeUtils.getCurrentDate());
                            final workField = await workService
                                .getWorkFieldByWorkShiftAndIdWork(
                                    workShift!.id, work.id);
                            if (workField != null) {
                              cfC.updateWorkField(workField.copyWith(
                                  toStatus: getIndex(index)), workField);
                              // await WorkingService.instance.updateWorkField(
                              //     workField.copyWith(
                              //         toStatus: getIndex(index)));
                            }
                            if (cubit != null) {
                              cubit!.updateWorkStatus(
                                  work.copyWith(status: getIndex(index)));
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }),
                    )
                  : StatusCard(status: work.status))
        ],
      ),
    );
  }
}

int getPosition(int index) {
  if (index <= 6) {
    return index;
  }
  if (100 <= index && index < 200) {
    return 7;
  }
  if (200 <= index && index < 300) {
    return 8;
  }
  if (300 <= index && index < 400) {
    return 9;
  }
  return 0;
}

int getIndex(int position) {
  if (position >= 0 && position <= 6) {
    return position;
  }
  if (position == 7) {
    return 100; // Ví dụ: Trả về giá trị bắt đầu trong khoảng 100-199
  }
  if (position == 8) {
    return 200; // Ví dụ: Trả về giá trị bắt đầu trong khoảng 200-299
  }
  if (position == 9) {
    return 300; // Ví dụ: Trả về giá trị bắt đầu trong khoảng 300-399
  }
  return -1; // Trả về -1 nếu position không hợp lệ
}
