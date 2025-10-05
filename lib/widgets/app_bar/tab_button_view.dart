import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/home_tabbar_define.dart';
import 'package:whms/repositories/configs_repository.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/app_bar_item.dart';

class TabButtonView extends StatelessWidget {
  const TabButtonView({
    super.key,
    required this.tab,
  });

  final int tab;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...tabBar.map(
          (e) => Container(
            margin: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(3, context)),
            child: AppBarItem(
                key: Key('${e.index}'),
                // icon: e.icon(),
                title: e.title(),
                tab: tab,
                curTab: e.index + 1,
                onTap: ()  {
                  // if(e == HomeTabBarDefine.home)  {
                  //   ConfigsCubit.fromContext(context).getDataWorkingUnitNewest();
                  // }
                  final cfC = ConfigsCubit.fromContext(context);
                  String? url;
                  if(e == HomeTabBarDefine.home) {
                    url = cfC.getSaveTab(cfC.keySaveTabMainTab);
                  } else if(e == HomeTabBarDefine.overview) {
                    url = cfC.getSaveTab(cfC.keySaveTabOverview);
                  } if(e == HomeTabBarDefine.management) {
                    url = cfC.getSaveTab(cfC.keySaveTabManagement);
                  } if(e == HomeTabBarDefine.humanResource) {
                    url = cfC.getSaveTab(cfC.keySaveTabHr);
                  }  if(e == HomeTabBarDefine.issues) {
                    url = cfC.getSaveTab(cfC.keySaveTabIssue);
                  }
                  if(url != null) {
                    context.go(url);
                  } else {
                    context.go(e.route());
                  }
                }),
          ),
        )
      ],
    );
  }

  List<HomeTabBarDefine> get tabBar {
    final ConfigsRepository configsRepository = ConfigsRepository.instance;
    int roleId = configsRepository.user.roles;
    switch (roleId) {
      case 0: //admin
        return [];
      case 10: //manager
        return [];
      case 20: //sub manager
        return [];
      case 30: //handler
        return [...HomeTabBarDefine.values];
      default: //tasker
        return [
          HomeTabBarDefine.home,
          HomeTabBarDefine.management,
          HomeTabBarDefine.overview,
          HomeTabBarDefine.humanResource,
        ];
    }
  }
}
