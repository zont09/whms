import 'package:flutter/material.dart';
import 'package:whms/features/manager/views/scope_tab.dart';
import 'package:whms/features/manager/views/user_tab.dart';
import 'package:whms/features/manager/widgets/appbar_manager.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/scale_utils.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key, required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    Widget view = Container();
    int curTab = 0;
    switch (tab) {
      case AppRoutes.managerPersonnel: view = const UserTab(); curTab = 1; break;
      case AppRoutes.managerScope: view =  ScopeTab(); curTab = 2; break;
    }
    return Scaffold(
        appBar: AppbarManager(
            height: ScaleUtils.scaleSize(60, context), tab: curTab,),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: view,
        ));
  }
}
