import 'package:whms/features/home/hr/views/history_view.dart';
import 'package:whms/features/home/hr/views/option_hr_view.dart';
import 'package:whms/features/home/hr/views/personal_hr_view.dart';
import 'package:whms/features/home/hr/views/task_in_hr_main_view.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_personal_task_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/no_data_available_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HrMainView extends StatefulWidget {
  const HrMainView({super.key, required this.tab, required this.cubit});

  final String tab;
  final HrTabCubit cubit;

  @override
  State<HrMainView> createState() => _HrMainViewState();
}

class _HrMainViewState extends State<HrMainView> {
  final List<int> weight = [6, 4, 4, 4, 4, 2, 4, 4, 2];
  final List<int> weight2 = [8, 3, 3, 3, 3, 1];

  @override
  void initState() {
    super.initState();
    if (widget.tab == "1") {
      if (widget.cubit.listScope.isNotEmpty) {
        widget.cubit.changeScopeAndUser(widget.cubit.listScope.first.id, "");
      }
    }
  }

  @override
  void didUpdateWidget(HrMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      final parts = widget.tab.split("&");
      if (widget.tab == "1") {
        if (widget.cubit.listScope.isNotEmpty) {
          widget.cubit.changeScopeAndUser(widget.cubit.listScope.first.id, "");
        }
      } else {
        widget.cubit
            .changeScopeAndUser(parts[0], parts.length > 1 ? parts[1] : "");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShowPersonal = (widget.cubit.userSelected.isNotEmpty &&
        widget.cubit.modeViewUser != AppText.titleWorkHistory.text);
    bool isEvaluationTab =
        widget.cubit.modeViewUser == AppText.titleEvaluation.text ||
            widget.cubit.modeViewUser == AppText.titleCheckList.text ||
            widget.cubit.modeViewUser == AppText.titleProcedure.text;
    final configCubit = ConfigsCubit.fromContext(context);
    if (widget.cubit.isInTaskHr) {
      return TaskInHrMainView(
          key: ValueKey(widget.cubit.scopeSelected), cubit: widget.cubit);
    }
    if (widget.cubit.modeViewUser == AppText.titleProcedure.text &&
        widget.cubit.userSelected.isNotEmpty) {
      return Padding(
        padding:
            EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(20, context)),
                child: OptionHrView(widget: widget)),
          ],
        ),
      );
    }
    return ScrollConfiguration(
        // key: ValueKey(widget.cubit.scopeSelected),
        behavior: InvisibleScrollBarWidget(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptionHrView(widget: widget),
                const ZSpace(h: 9),
                if (!isShowPersonal)
                  HistoryView(
                    widget: widget,
                    weight: widget.cubit.timeMode == AppText.textSynthetic.text
                        ? weight2
                        : weight,
                    cubit: widget.cubit,
                  ),
                if (isShowPersonal && widget.cubit.loading > 0)
                  const Column(
                    children: [
                      ZSpace(h: 50),
                      Center(
                          child: CircularProgressIndicator(
                              color: ColorConfig.primary3))
                    ],
                  ),
                if (isShowPersonal &&
                    widget.cubit.loading == 0 &&
                    !isEvaluationTab)
                  Column(
                    children: widget.cubit.listDataWorkOfUser.isNotEmpty
                        ? [
                            const HeaderPersonalTaskWidget(
                              isInHrTab: true,
                            ),
                            const ZSpace(h: 9),
                            Column(
                              children: [
                                ...widget.cubit.mapDataWorkOfUserGroup.entries
                                    .map((item) => PersonalHrView(
                                          item: item,
                                          cubit: widget.cubit,
                                          isShowAssignees: false,
                                        ))
                              ],
                            ),
                          ]
                        : [const ZSpace(h: 20), const NoDataAvailableWidget()],
                  )
              ],
            ),
          ),
        ));
  }
}

// DropdownString(
//   key: ValueKey(widget.cubit.state),
//   onChanged: (v) {
//     widget.cubit.changeQuarter(v!);
//   },
//   initItem: widget.cubit.listQuarter.last,
//   options: widget.cubit.listQuarter.reversed.toList(),
//   radius: 8,
//   textColor: ColorConfig.primary3,
//   fontSize: 14,
//   maxWidth: 200,
//   centerItem: true,
// )
