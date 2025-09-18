import 'package:flutter/material.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/widgets/progress_slider.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class MainWorkContent extends StatelessWidget {
  const MainWorkContent(
      {super.key,
      required this.work,
      required this.isInSelectedView,
      required this.cubit});

  final WorkingUnitModel work;
  final bool isInSelectedView;
  final CheckInCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    final cfC = ConfigsCubit.fromContext(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cubit!.mapAddress[work.id] != null)
          for (int i = cubit!.mapAddress[work.id]!.length - 1; i >= 0; i--)
            Row(
              children: [
                Tooltip(
                  message: cubit!.mapAddress[work.id]![i].title,
                  child: Text(
                    cubit!.mapAddress[work.id]![i].type,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(11, context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA6A6A6)),
                  ),
                ),
                if (i > 0)
                  Text(
                    " > ",
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(11, context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA6A6A6)),
                  ),
              ],
            ),
        SizedBox(
          height: ScaleUtils.scaleSize(8, context),
        ),
        Text(
          work.title,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(14, context),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF191919),
              overflow: TextOverflow.ellipsis),
        ),
        if (work.status >= 100 &&
            checkIn == StatusCheckInDefine.checkIn &&
            !isInSelectedView)
          ProgressSlider(
              initialValue: work.status % 100,
              onChanged: (value) async {
                DialogUtils.showLoadingDialog(context);
                final workService = WorkingService.instance;
                final user = ConfigsCubit.fromContext(context).user;
                final workShift = await UserServices.instance
                    .getWorkShiftByIdUserAndDate(
                        user.id, DateTimeUtils.getCurrentDate());
                final workField = await workService
                    .getWorkFieldByWorkShiftAndIdWork(workShift!.id, work.id);
                if (workField != null) {
                  cfC.updateWorkField(workField.copyWith(
                      toStatus: ((workField.toStatus ~/ 100) * 100 + value)
                          .toInt()), workField);
                  // await WorkingService.instance.updateWorkField(
                  //     workField.copyWith(
                  //         toStatus: ((workField.toStatus ~/ 100) * 100 + value)
                  //             .toInt()));
                  if (cubit != null) {
                    cubit!.updateWorkStatus(work.copyWith(
                        status: ((workField.toStatus ~/ 100) * 100 + value)
                            .toInt()));
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }),
      ],
    );
  }
}
