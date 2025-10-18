import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/hr/views/hr_main_view.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/widgets/multitab_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:flutter/material.dart';

class OptionHrView extends StatelessWidget {
  const OptionHrView({
    super.key,
    required this.widget,
  });

  final HrMainView widget;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    final isHandler =
        (cfC.usersMap[widget.cubit.userSelected] ?? UserModel()).owner ==
            cfC.user.id;
    final isShowFilterScopeOrFull = !isHandler ||
        widget.cubit.modeViewUser == AppText.titleWorkHistory.text ||
        widget.cubit.modeViewUser == AppText.textTaskAssign.text ||
        widget.cubit.modeViewUser == AppText.textTaskPersonal.text ||
        widget.cubit.modeViewUser == AppText.titleToday.text ||
        widget.cubit.modeViewUser == AppText.titleDoing.text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.cubit.userSelected.isNotEmpty)
          Expanded(
              child: MultitabWidget(
                  tabs: [
                    AppText.titleWorkHistory.text,
                    AppText.textTaskAssign.text,
                    AppText.textTaskPersonal.text,
                    AppText.titleToday.text,
                    AppText.titleDoing.text,
                  ],
                  tabSelected: widget.cubit.modeViewUser,
                  selectTab: (v) {
                    if (widget.cubit.modeViewUser == v) return;
                    widget.cubit.changeModeViewUser(v);
                  })),
        if (widget.cubit.userSelected.isEmpty)
          Expanded(
              child: MultitabWidget(
                  fontSize: 14,
                  tabs: [
                    AppText.titleOverview.text,
                    AppText.titleTask.text,
                  ],
                  tabSelected: !widget.cubit.isInTaskHr
                      ? AppText.titleOverview.text
                      : AppText.titleTask.text,
                  selectTab: (v) {
                    widget.cubit.changeHrTaskView(!widget.cubit.isInTaskHr);
                  })),
        // if (widget.cubit.userSelected.isEmpty)
        //   Expanded(
        //       child: Row(
        //     children: [
        //       CustomButton(
        //         title: AppText.titleTask.text,
        //         icon: "",
        //         onPressed: () {
        //           widget.cubit.changeHrTaskView(true);
        //         },
        //         paddingHor: 8,
        //         paddingVer: 4,
        //       ),
        //     ],
        //   )),
        const ZSpace(w: 20),
        Row(
          children: [
            if (widget.cubit.userSelected.isNotEmpty &&
                widget.cubit.modeViewUser == AppText.textTaskAssign.text)
              DropdownString(
                onChanged: (v) {
                  widget.cubit.changeFilterStatusTaskAssign(v!);
                },
                initItem: widget.cubit.filterStatusTaskAssign,
                options: [
                  AppText.textByUnFinished.text,
                  AppText.textByFinished.text,
                  AppText.textByFull.text,
                  AppText.titleDoing.text,
                  AppText.textThisWeek.text,
                  AppText.textLastWeek.text
                ],
                radius: 8,
                textColor: const Color(0xFF191919),
                fontSize: 14,
                maxWidth: 160,
                centerItem: true,
              ),
            const ZSpace(w: 9),
            if (widget.cubit.userSelected.isNotEmpty && isShowFilterScopeOrFull)
              DropdownString(
                onChanged: (v) {
                  widget.cubit.changeUserViewMode(v!);
                },
                initItem: widget.cubit.userViewMode,
                options: [
                  AppText.textByScope.text,
                  AppText.textByFull.text,
                ],
                radius: 8,
                textColor: const Color(0xFF191919),
                fontSize: 14,
                maxWidth: 160,
                centerItem: true,
              ),
            const ZSpace(w: 9),
            if (widget.cubit.userSelected.isEmpty ||
                widget.cubit.modeViewUser == AppText.titleWorkHistory.text)
              DropdownString(
                // key: ValueKey(widget.cubit.),
                onChanged: (v) {
                  widget.cubit.changeTimeView(v!);
                },
                initItem: AppText.text5Days.text,
                options: [
                  AppText.text5Days.text,
                  AppText.text10Days.text,
                  AppText.textLastWeek.text,
                  AppText.textThisWeek.text,
                  AppText.textLastMonth.text,
                  AppText.textThisMonth.text,
                ],
                radius: 8,
                textColor: ColorConfig.primary3,
                fontSize: 14,
                maxWidth: 200,
                centerItem: true,
              ),
          ],
        )
      ],
    );
  }
}
