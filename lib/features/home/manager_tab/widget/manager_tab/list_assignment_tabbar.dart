import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class ListAssignmentTabBar extends StatelessWidget {
  final ManagementCubit managementCubit;
  final List<String> tabs;
  const ListAssignmentTabBar(
      {required this.tabs, required this.managementCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ElevatedButton(
          style: const ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              elevation: WidgetStatePropertyAll(0)),
          onPressed: null,
          child: Container(
              width: double.maxFinite,
              padding:
                  EdgeInsets.only(bottom: ScaleUtils.scaleSize(3, context)),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE9E9E9)))),
              child: Opacity(
                  opacity: 0,
                  child: Text('oooo',
                      style: TextStyle(
                          letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                          fontSize: ScaleUtils.scaleSize(12, context),
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w500))))),
      Row(children: [
        ...tabs.map((e) => ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                elevation: WidgetStatePropertyAll(0)),
            onPressed: () =>
                managementCubit.changeTab(managementCubit.listTabs.indexOf(e)),
            child: Container(
                padding:
                    EdgeInsets.only(bottom: ScaleUtils.scaleSize(3, context)),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: ScaleUtils.scaleSize(1, context),
                            color: e ==
                                    managementCubit
                                        .listTabs[managementCubit.tab]
                                ? ColorConfig.primary3
                                : Colors.transparent))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e,
                        style: TextStyle(
                            letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                            fontSize: ScaleUtils.scaleSize(12, context),
                            color: e ==
                                    managementCubit
                                        .listTabs[managementCubit.tab]
                                ? ColorConfig.primary3
                                : ColorConfig.textTertiary,
                            fontWeight: e ==
                                    managementCubit
                                        .listTabs[managementCubit.tab]
                                ? FontWeight.w700
                                : FontWeight.w500)),
                    SizedBox(width: ScaleUtils.scaleSize(2, context)),
                    CircleAvatar(
                      radius: ScaleUtils.scaleSize(7, context),
                      backgroundColor: ColorConfig.primary3,
                      child: Text(
                          '${[
                            managementCubit.tabX,
                            managementCubit.tabY,
                            managementCubit.tabZ
                          ][managementCubit.listTabs.indexOf(e)].length}',
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(9, context),
                              color: Colors.white)),
                    )
                  ],
                ))))
      ])
    ]);
  }
}
