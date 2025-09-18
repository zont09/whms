import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/button_bottom_view.dart';
import 'package:whms/features/home/checkin/views/check_in_main_view.dart';
import 'package:whms/features/home/checkin/views/select_work_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/loading_widget.dart';

class CheckInView extends StatelessWidget {
  const CheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    return BlocProvider(
      create: (context) => CheckInCubit()..initData(context, checkIn),
      child: BlocBuilder<CheckInCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CheckInCubit>(c);
          return BlocProvider(
            create: (context) => SelectWorkCubit(ConfigsCubit.fromContext(context))
              ..initData(cubit.listWorkAvailable, cubit.listScope,
                  cubit.mapWorkParent),
            child: BlocListener<CheckInCubit, int>(
              listener: (ccc, sss) {
                final selectWorkCubit = BlocProvider.of<SelectWorkCubit>(ccc);
                selectWorkCubit.initData(cubit.listWorkAvailable,
                    cubit.listScope, cubit.mapWorkParent);
              },
              child: Builder(builder: (cc) {
                return Container(
                  height: MediaQuery.of(context).size.height - 50,
                  width: ScaleUtils.scaleSize(900, context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        ScaleUtils.scaleSize(12, context)),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(50, context),
                            vertical: ScaleUtils.scaleSize(26, context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cubit.tab == 0
                                  ? AppText.titleCheckIn2.text
                                  : AppText.titleAddTaskToCheckIn.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(24, context),
                                  fontWeight: FontWeight.w500,
                                  shadows: const [ColorConfig.textShadow]),
                            ),
                            Text(
                              cubit.tab == 0
                                  ? AppText.titleSetUpStatusCheckIn.text
                                  : AppText.textAddTaskToCheckIn.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(16, context),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA6A6A6)),
                            ),
                            Expanded(
                                child: s == 0
                                    ? const LoadingWidget()
                                    : (cubit.tab == 0
                                        ? CheckInMainView(
                                            cubit: cubit,
                                            cubitSW: BlocProvider.of<
                                                SelectWorkCubit>(cc),
                                          )
                                        : SelectWorkView(
                                            cubitMA: cubit,
                                            onTapTitle: () {
                                              cubit.changeSortTitle();
                                            },
                                          ))),
                            SizedBox(
                              height: ScaleUtils.scaleSize(9, context),
                            ),
                            ButtonBottomView(cubit: cubit)
                          ],
                        ),
                      ),
                      if (cubit.tab == 0)
                        Positioned(
                          top: ScaleUtils.scaleSize(20, context),
                          right: ScaleUtils.scaleSize(20, context),
                          child: InkWell(
                            onTap: () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Image.asset(
                                'assets/images/icons/ic_close_check_in.png',
                                height: ScaleUtils.scaleSize(16, context)),
                          ),
                        )
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
