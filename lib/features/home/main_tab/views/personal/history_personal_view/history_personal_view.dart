import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/features/home/main_tab/views/personal/history_personal_view/header_history_table.dart';
import 'package:whms/features/home/main_tab/widgets/personal/history_card_task_widget.dart';
import 'package:whms/features/home/main_tab/widgets/personal/history_card_widget.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/shimmer_loading.dart';
import 'package:whms/widgets/z_space.dart';

class HistoryPersonalView extends StatelessWidget {
  const HistoryPersonalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        WorkHistoryCubit(ConfigsCubit.fromContext(context))
          ..initData(
              DateTimeUtils.getCurrentDate().subtract(const Duration(days: 2)),
              DateTimeUtils.getCurrentDate()),
        child: BlocListener<ConfigsCubit, ConfigsState>(
          listenWhen: (pre, cur) =>
          cur.updatedEvent == ConfigStateEvent.workShift,
          listener: (cc, ss) {
            final cubit = BlocProvider.of<WorkHistoryCubit>(cc);
            final cfC = ConfigsCubit.fromContext(context);
            if(ss.data is WorkShiftModel && ss.data.id.isNotEmpty) {
              if (ss.data.user == cfC.user.id) {
                cubit.updateWorkShift(ss.data);
              }
            }
          },
          child: BlocBuilder<WorkHistoryCubit, int>(
            builder: (c, s) {
              var cubit = BlocProvider.of<WorkHistoryCubit>(c);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                          "assets/images/icons/tab_bar/ic_tab_today.png",
                          height: ScaleUtils.scaleSize(20, context),
                          color: ColorConfig.primary2),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      Text(AppText.titleWorkHistory.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(18, context),
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      DropdownString(
                        onChanged: (v) {
                          cubit.changeTime(context, v!);
                        },
                        initItem: AppText.text3Days.text,
                        options: [
                          AppText.text3Days.text,
                          AppText.text10Days.text,
                          AppText.textLastWeek.text,
                          AppText.textThisWeek.text,
                          AppText.textLastMonth.text,
                          AppText.textThisMonth.text,
                        ],
                        radius: 8,
                        maxHeight: 25,
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      DropdownString(
                        onChanged: (v) {
                          cubit.changeMode(context, v!);
                        },
                        initItem: AppText.textByDay.text,
                        options: [
                          AppText.textByDay.text,
                          AppText.textSynthetic.text,
                        ],
                        radius: 8,
                        maxHeight: 25,
                      ),
                    ],
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(15, context)),
                  if (s == 0)
                  // SizedBox(
                  //   height: ScaleUtils.scaleSize(300, context),
                  //   width: double.infinity,
                  //   child: const LoadingWidget(),
                  // ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HeaderHistoryTable(mode: cubit.modeView),
                        const ZSpace(h: 8),
                        ...List.generate(
                            3,
                                (_) =>
                                Column(
                                  children: [
                                    ShimmerLoading(height: 50, radius: 8),
                                    const ZSpace(h: 9)
                                  ],
                                ))
                      ],
                    ),
                  if (s != 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderHistoryTable(
                          mode: cubit.modeView,
                        ),
                        SizedBox(height: ScaleUtils.scaleSize(8, context)),
                        if (cubit.modeView == AppText.textByDay.text)
                          ...cubit.listHistory.reversed.map((item) =>
                              Column(
                                children: [
                                  HistoryCardWidget(
                                    data: item,
                                    cubit: cubit,
                                  ),
                                  SizedBox(
                                      height: ScaleUtils.scaleSize(6, context)),
                                ],
                              )),
                        if (cubit.modeView == AppText.textSynthetic.text)
                          ...cubit.listWorkSyn.reversed.map((item) =>
                              Column(
                                children: [
                                  HistoryCardTaskWidget(
                                    data: item,
                                    cubit: cubit,
                                  ),
                                  SizedBox(
                                      height: ScaleUtils.scaleSize(6, context)),
                                ],
                              ))
                      ],
                    )
                ],
              );
            },
          ),
        ));
  }
}
