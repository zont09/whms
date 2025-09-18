import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/blocs/check_in_main_view_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/check_in_main_view.dart';
import 'package:whms/features/home/checkin/views/list_task_view.dart';
import 'package:whms/features/home/checkin/views/no_task_check_in.dart';
import 'package:whms/features/home/checkin/views/select_time_view.dart';
import 'package:whms/features/home/checkin/widgets/custom_time_picker.dart';
import 'package:whms/features/home/checkin/widgets/header_task_table.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class CheckInMainView extends StatelessWidget {
  const CheckInMainView(
      {super.key, required this.cubit, required this.cubitSW});

  final CheckInCubit cubit;
  final SelectWorkCubit cubitSW;

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    return BlocProvider(
      create: (context) => CheckInMainViewCubit(),
      child: BlocBuilder<CheckInMainViewCubit, int>(
        builder: (c, s) {
          var cubitLocal = BlocProvider.of<CheckInMainViewCubit>(c);
          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectTimeView(
                          onTap: () {},
                            cubitLocal: cubitLocal,
                            cubit: cubit,
                            startTime: null,
                            isCheckIn: true),
                        SizedBox(height: ScaleUtils.scaleSize(18, context)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppText.titleTaskList.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(18, context),
                                    color: ColorConfig.textColor,
                                    fontWeight: FontWeight.w500,
                                    shadows: const [ColorConfig.textShadow])),
                            SizedBox(width: ScaleUtils.scaleSize(9, context)),
                            InkWell(
                              onTap: () {
                                cubit.changeTab(1);
                              },
                              child: Image.asset(
                                'assets/images/icons/ic_add_task.png',
                                height: ScaleUtils.scaleSize(24, context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: ScaleUtils.scaleSize(9, context)),
                    if (checkIn == StatusCheckInDefine.checkIn)
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(30, context)),
                          child: Text(AppText.textPleaseCheckTaskToday.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(12, context),
                                  fontWeight: FontWeight.w400,
                                  color: ColorConfig.textColor))),
                    SizedBox(height: ScaleUtils.scaleSize(9, context)),
                    if (cubit.listWorkSelected.isEmpty)
                      const Expanded(child: NoTaskCheckIn()),
                    if (cubit.listWorkSelected.isNotEmpty)
                      HeaderTaskTable(isAddTask: false, onTapTitle: () {
                        cubit.changeSortTitle();
                      },),
                    if (cubit.listWorkSelected.isNotEmpty)
                      SizedBox(height: ScaleUtils.scaleSize(9, context)),
                    if (cubit.listWorkSelected.isNotEmpty)
                      Expanded(
                        child: ListTaskView(cubit: cubit, cubitSW: cubitSW),
                      ),
                  ],
                ),
                if (cubitLocal.isShowSelectTime)
                  Positioned(
                    top: ScaleUtils.scaleSize(108, context),
                    left: ScaleUtils.scaleSize(328, context),
                    child: IntrinsicWidth(
                        child: CustomTimePicker(
                      defaultTime: cubit.endTime.toDate(),
                      onOk: (value) {
                        cubit.changeEndTime(
                            DateTimeUtils.getTimestampWithDateTime(value));
                        cubitLocal.changeStatusSelectTime();
                      },
                      onCancel: () {
                        cubitLocal.changeStatusSelectTime();
                      },
                    )),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
