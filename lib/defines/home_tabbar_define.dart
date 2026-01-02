import 'package:whms/configs/config_cubit.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';

enum HomeTabBarDefine {
  home,
  overview,
  management,
  humanResource,
}

extension HomeTabbarDefineExtension on HomeTabBarDefine {
  String title() {
    switch (this) {
      case HomeTabBarDefine.home:
        return AppText.titleMainTab.text;
      case HomeTabBarDefine.overview:
        return AppText.titleOverview.text;
      case HomeTabBarDefine.management:
        return AppText.titleManager.text;
      case HomeTabBarDefine.humanResource:
        return AppText.titleHR.text;
    }
  }

  String icon() {
    switch (this) {
      case HomeTabBarDefine.home:
        return 'assets/images/icons/ic_main_tab.png';
      case HomeTabBarDefine.overview:
        return 'assets/images/icons/ic_overview.png';
      case HomeTabBarDefine.management:
        return 'assets/images/icons/ic_manager.png';
      case HomeTabBarDefine.humanResource:
        return 'assets/images/icons/ic_hr.png';
    }
  }

  String route() {
    switch (this) {
      case HomeTabBarDefine.home:
        return AppRoutes.mainTab;
      case HomeTabBarDefine.overview:
        return AppRoutes.overview;
      case HomeTabBarDefine.management:
        return '${AppRoutes.manager}/${ConfigsCubit.localScopeId.isEmpty ? '0' : ConfigsCubit.localScopeId}&001000000';
      case HomeTabBarDefine.humanResource:
        return AppRoutes.hr;
    }
  }
}
