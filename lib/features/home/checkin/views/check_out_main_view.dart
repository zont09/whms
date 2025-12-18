import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/list_task_view.dart';
import 'package:whms/features/home/checkin/views/no_task_check_in.dart';
import 'package:whms/features/home/checkin/views/select_time_view.dart';
import 'package:whms/features/home/checkin/widgets/custom_time_picker.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class CheckOutMainView extends StatelessWidget {
  const CheckOutMainView(
      {super.key, required this.cubit, required this.cubitSW});

  final CheckOutCubit cubit;
  final SelectWorkCubit cubitSW;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShowTime(),
      child: BlocBuilder<ShowTime, bool>(
        builder: (c, s) {
          var cubitST = BlocProvider.of<ShowTime>(c);
          return Stack(
            children: [
              Column(
                children: [
                  SelectTimeView(
                    endTime: DateTimeUtils.getTimestampWithDateTime(cubit.timeCheckout),
                    onTap: () {
                      cubitST.changeValue(!s);
                    },
                    cubitLocal: null,
                    cubit: null,
                    isCheckIn: false,
                    startTime: cubit.workShift.checkIn,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppText.titleTaskList.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(18, context),
                            color: ColorConfig.textColor,
                            fontWeight: FontWeight.w500,
                            shadows: const [ColorConfig.textShadow]),
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(9, context)),
                      InkWell(
                        onTap: () {
                          cubit.changeTab(2);
                        },
                        child: Image.asset(
                          'assets/images/icons/ic_add_meeting.png',
                          height: ScaleUtils.scaleSize(24, context),
                        ),
                      ),
                    ],
                  ),
                  if (cubit.listWorkSelected.isEmpty)
                    const Expanded(child: Center(child: NoTaskCheckIn())),
                  if (cubit.listWorkSelected.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: ScaleUtils.scaleSize(18, context)),
                          // HeaderTaskTable(cubitCO: cubit, isAddTask: false,),
                          SizedBox(height: ScaleUtils.scaleSize(9, context)),
                          Expanded(
                              child: ListTaskView(cubit: cubit, cubitSW: cubitSW)),
                        ],
                      ),
                    )
                ],
              ),
              if (s)
                Positioned(
                  top: ScaleUtils.scaleSize(108, context),
                  left: ScaleUtils.scaleSize(328, context),
                  child: IntrinsicWidth(
                      child: CustomTimePicker(
                        defaultTime: cubit.timeCheckout,
                        onOk: (value) {
                          cubit.changeTimeCheckOut(value);
                          cubitST.changeValue(false);
                        },
                        onCancel: () {
                          cubitST.changeValue(false);
                        },
                      )),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ShowTime extends Cubit<bool> {
  ShowTime() : super(false);

  changeValue(bool value) {
    emit(value);
  }
}