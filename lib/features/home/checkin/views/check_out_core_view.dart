import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/break_time_resume_view.dart';
import 'package:whms/features/home/checkin/views/button_breaktime_view.dart';
import 'package:whms/features/home/checkin/views/button_checkout_view.dart';
import 'package:whms/features/home/checkin/views/check_out_main_view.dart';
import 'package:whms/features/home/checkin/views/check_out_tab_view.dart';
import 'package:whms/features/home/checkin/views/select_work_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

import '../../../../configs/color_config.dart' show ColorConfig;

class CheckOutCoreView extends StatelessWidget {
  const CheckOutCoreView({
    super.key,
    required this.cubit,
    required this.checkIn,
  });

  final CheckOutCubit cubit;
  final StatusCheckInDefine checkIn;

  @override
  Widget build(BuildContext context) {
    final isBreakTime = checkIn == StatusCheckInDefine.breakTime;
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(50, context),
            vertical: ScaleUtils.scaleSize(26, context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cubit.tab == 0 && !isBreakTime
                        ? AppText.titleCheckOutVSub.text
                        : (cubit.tab == 1 || isBreakTime
                            ? (!isBreakTime
                                ? AppText.titleBreakTimeVSub.text
                                : AppText.titleResumeVSub.text)
                            : AppText.titleAddTaskToCheckIn.text),
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(24, context),
                        fontWeight: FontWeight.w500,
                        shadows: const [ColorConfig.textShadow]),
                  ),
                  Text(
                    cubit.tab == 0
                        ? AppText.textCheckOut.text
                        : (cubit.tab == 1
                            ? (checkIn == StatusCheckInDefine.checkIn
                                ? AppText.textCheckOut.text
                                : AppText.textResume.text)
                            : AppText.textAddTaskToCheckIn.text),
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(16, context),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA6A6A6)),
                  ),
                ],
              ),
              const ZSpace(w: 20),
              if (cubit.tab != 2 && !isBreakTime)
                Expanded(child: CheckOutTabView(cubit: cubit)),
            ],
          ),
          if (cubit.tab == 2)
            Expanded(
                child: SelectWorkView(
              cubitMA: cubit,
            )),
          if (cubit.tab == 1 || isBreakTime) BreakTimeResumeView(cubit: cubit),
          if (cubit.tab == 0 && !isBreakTime)
            Expanded(
              child: CheckOutMainView(
                cubit: cubit,
                cubitSW: BlocProvider.of<SelectWorkCubit>(context),
              ),
            ),
          SizedBox(height: ScaleUtils.scaleSize(9, context)),
          if (cubit.tab != 1 && !isBreakTime) ButtonCheckoutView(cubit: cubit),
          if (cubit.tab == 1 || isBreakTime)
            ButtonBreaktimeView(cubit: cubit, timeResume: cubit.timeResume)
        ]));
  }
}
