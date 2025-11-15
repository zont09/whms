import 'package:whms/features/home/main_tab/widgets/menu_item.dart';
import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OverviewSideBar extends StatelessWidget {
  const OverviewSideBar({super.key, required this.curTab, required this.cubit});

  final String curTab;
  final OverviewTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        color: Colors.transparent,
        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(9, context)),
        child: ListView(children: [
          ...cubit.listScopeUser.map(
            (scope) => MenuItem(
                icon: 'assets/images/icons/ic_scope.png',
                title: scope.title,
                tab: scope.id,
                curTab: curTab,
                onTap: () {
                  if (curTab != scope.id) {
                    context.go('${AppRoutes.overview}/${scope.id}');
                  }
                },
                isFirst: scope.id == cubit.listScopeUser.first.id,
                // onTap: () {},
                children: [
                  if (cubit.epicOfScope[scope.id] != null)
                    ...cubit.epicOfScope[scope.id]!.map((epic) => MenuItem(
                          icon: 'assets/images/icons/ic_epic.png',
                          title: epic.title,
                          tab: "${scope.id}&${epic.id}",
                          curTab: curTab,
                          onTap: () {
                            if (curTab != "${scope.id}&${epic.id}") {
                              context.go(
                                  '${AppRoutes.overview}/${scope.id}&${epic.id}');
                            }
                          },
                          children: [
                            if (cubit.sprintOfEpic[epic.id] != null)
                              ...cubit.sprintOfEpic[epic.id]!
                                  .map((sprint) => MenuItem(
                                        icon:
                                            'assets/images/icons/ic_sprint.png',
                                        title: sprint.title,
                                        tab:
                                            "${scope.id}&${epic.id}&${sprint.id}",
                                        curTab: curTab,
                                        onTap: () {
                                          if (curTab !=
                                              "${scope.id}&${epic.id}${sprint.id}") {
                                            context.go(
                                                '${AppRoutes.overview}/${scope.id}&${epic.id}&${sprint.id}');
                                          }
                                        },
                                        children: [],
                                      )),
                          ],
                        )),
                ]),
          ),
          SizedBox(height: ScaleUtils.scaleSize(20, context)),
          // const IssueReportButton()
        ]));
  }
}
