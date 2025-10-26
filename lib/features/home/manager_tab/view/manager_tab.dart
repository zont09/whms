import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/manager_tab/management_assignment_view.dart';
import 'package:whms/features/home/manager_tab/management_sidebar.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/widgets/app_bar/new_app_bar.dart';

class ManagerTab extends StatelessWidget {
  const ManagerTab({super.key, required this.scope, required this.tab});

  final String scope;
  final String tab;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(children: [
      Container(
        height: double.infinity,
        width: double.infinity,
        color: ColorConfig.primary3,
      ),
      BlocProvider(
          create: (context) =>
              ManagementCubit(scope, tab, ConfigsCubit.fromContext(context)),
          child: BlocListener<ConfigsCubit, ConfigsState>(
            listenWhen: (previous, current) =>
                current.updatedEvent == ConfigStateEvent.task,
            listener: (cc, ss) {
              final cubit = BlocProvider.of<ManagementCubit>(cc);
              if (cubit.listWorkings == null || cubit.selectedWorking == null) {
                return;
              }
              if (ss.updatedEvent == ConfigStateEvent.task &&
                  ss.data is List<WorkingUnitModel>) {
                bool isEmit = false;
                for (var e in ss.data) {
                  if (e.scopes.contains(cubit.selectedScope?.id)) {
                    bool ok = cubit.updateWorkingUnit(e, isEmit: false);
                    if(ok) isEmit = true;
                  }
                }
                if(isEmit) {
                  cubit.buildUI();
                }
              } else if (ss.updatedEvent == ConfigStateEvent.task &&
                  ss.data is WorkingUnitModel &&
                  ss.data.id.isNotEmpty) {
                if (ss.data.scopes.contains(cubit.selectedScope?.id)) {
                  int index = (cubit.listWorkings ?? []).indexWhere((e) => e.id == ss.data.id);
                  if(index != -1) {
                    cubit.updateWorkingUnit(ss.data);
                  } else {
                    cubit.addItemToTree(ss.data);
                  }
                }
              }
            },
            child: BlocBuilder<ManagementCubit, int>(builder: (c, s) {
              var cubit = BlocProvider.of<ManagementCubit>(c);
              return Column(children: [
                const NewAppBar(isHome: true, tab: 3),
                Expanded(
                    child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        height: double.infinity,
                        child: Row(children: [
                          Expanded(flex: 1, child: ManagementSidebar(cubit)),
                          Expanded(
                              flex: 4,
                              child: ManagementAssignmentView(
                                  managementCubit: cubit))
                        ])))
              ]);
            }),
          ))
    ]));
  }
}
