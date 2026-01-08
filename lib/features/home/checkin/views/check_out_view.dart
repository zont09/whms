import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/check_out_core_view.dart';
import 'package:whms/untils/scale_utils.dart';

class CheckOutView extends StatelessWidget {
  const CheckOutView({super.key});

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    return BlocProvider(
      create: (context) => CheckOutCubit(ConfigsCubit.fromContext(context))..initData(context),
      child: BlocBuilder<CheckOutCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CheckOutCubit>(c);
          if (s == 0) {
            return Container(
              height: cubit.tab == 0 && checkIn != StatusCheckInDefine.breakTime
                  ? MediaQuery.of(context).size.height - 50
                  : ScaleUtils.scaleSize(300, context),
              width: ScaleUtils.scaleSize(950, context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: ColorConfig.primary2,
                ),
              ),
            );
          }
          return BlocProvider(
            create: (context) => SelectWorkCubit(ConfigsCubit.fromContext(context))
              ..initData(cubit.listWorkAvailable, cubit.listScope, cubit.mapWorkParent),
            child: BlocListener<CheckOutCubit, int>(
              listener: (cc, ss) {
                final selectWorkCubit = BlocProvider.of<SelectWorkCubit>(cc);
                selectWorkCubit.initData(
                    cubit.listWorkAvailable, cubit.listScope, cubit.mapWorkParent);
              },
              child: Builder(builder: (ccc) {
                return Stack(
                  children: [
                    IntrinsicHeight(
                      child: Container(
                          height: cubit.tab != 1 && checkIn != StatusCheckInDefine.breakTime
                              ? MediaQuery.of(context).size.height - 50
                              : null,
                          width: ScaleUtils.scaleSize(1000, context),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                ScaleUtils.scaleSize(12, context)),
                          ),
                          child:
                              CheckOutCoreView(cubit: cubit, checkIn: checkIn)),
                    ),
                    if (cubit.tab != 2)
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
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
