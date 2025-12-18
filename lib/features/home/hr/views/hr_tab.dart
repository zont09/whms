import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/views/hr_main_view.dart';
import 'package:whms/features/home/hr/widget/hr_side_bar.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/widgets/app_bar/new_app_bar.dart';
import 'package:whms/widgets/loading_widget.dart';

class HRTab extends StatelessWidget {
  const HRTab({super.key, required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    final parts = tab.split("&");
    return Material(
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            color: ColorConfig.primary1,
          ),
          BlocProvider(
            create: (context) => HrTabCubit(ConfigsCubit.fromContext(context))
              ..initData(
                  context,
                  DateTimeUtils.getCurrentDate()
                      .subtract(const Duration(days: 4)),
                  DateTimeUtils.getCurrentDate(),
                  parts.length > 1 ? parts[1] : "")
              ..changeScopeAndUser(parts[0], parts.length > 1 ? parts[1] : "",
                  isLoad: false),
            child: BlocListener<ConfigsCubit, ConfigsState>(
              listenWhen: (pre, current) =>
                  current.updatedEvent == ConfigStateEvent.task ||
                  current.updatedEvent == ConfigStateEvent.workShift ||
                  current.updatedEvent == ConfigStateEvent.workField,
              listener: (cc, ss) {
                final cubit = BlocProvider.of<HrTabCubit>(cc);
                if (ss.updatedEvent == ConfigStateEvent.workShift &&
                    ss.data is WorkShiftModel &&
                    ss.data.id.isNotEmpty) {
                  cubit.updateWorkShift(ss.data);
                } else if (ss.updatedEvent == ConfigStateEvent.workField) {
                  if (ss.data is List<WorkFieldModel>) {
                    for (var e in ss.data) {
                      cubit.updateWorkField(e);
                    }
                  } else if (ss.data is WorkFieldModel &&
                      ss.data.id.isNotEmpty) {
                    cubit.updateWorkField(ss.data);
                  }
                } else if (ss.updatedEvent == ConfigStateEvent.task) {
                  if (ss.data is List<WorkingUnitModel>) {
                    for (var e in ss.data) {
                      cubit.updateWorkingUnit(e);
                    }
                  } else if (ss.data is WorkingUnitModel &&
                      ss.data.id.isNotEmpty) {
                    cubit.updateWorkingUnit(ss.data);
                  }
                }
              },
              child: BlocBuilder<HrTabCubit, int>(
                builder: (c, s) {
                  var cubit = BlocProvider.of<HrTabCubit>(c);
                  return Column(
                    children: [
                      const NewAppBar(isHome: true, tab: 4),
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: HrSideBar(curTab: tab, cubit: cubit)),
                          Expanded(
                              flex: 4,
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: ColorConfig.whiteBackground,
                                child: s == 0
                                    ? const LoadingWidget()
                                    : HrMainView(tab: tab, cubit: cubit),
                              )),
                        ],
                      ))
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
