import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/widget/hr_side_bar_user_item.dart';
import 'package:whms/features/home/main_tab/widgets/menu_item.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HrSideBar extends StatelessWidget {
  const HrSideBar({super.key, required this.curTab, required this.cubit});

  final HrTabCubit cubit;
  final String curTab;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        color: Colors.transparent,
        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(9, context)),
        child: ListView(children: [
          ...cubit.listScope.map(
            (item) => MenuItem(
                icon: 'assets/images/icons/ic_scope.png',
                title: item.title,
                tab: item.id,
                curTab: curTab,
                onTap: () {
                  if (curTab != item.id) {
                    context.go('${AppRoutes.hr}/${item.id}');
                  }
                },
                isFirst: item.id == cubit.listScope.first.id,
                // onTap: () {},
                children: [
                  if (cubit.mapUserInScope.containsKey(item.id))
                    ...cubit.mapUserInScope[item.id]!.map((e) =>
                        HrSideBarUserItem(
                            onTap: () {
                              if(curTab != "${item.id}&${e.id}"); {
                                context.go('${AppRoutes.hr}/${item.id}&${e.id}');
                              }
                            },
                            isActive: curTab == "${item.id}&${e.id}",
                            avt: e.avt,
                            title: e.name,
                            ))
                ]),
          ),
          SizedBox(height: ScaleUtils.scaleSize(20, context)),
          // const IssueReportButton()
        ]));
  }
}
