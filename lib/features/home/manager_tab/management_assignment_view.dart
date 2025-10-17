import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/detail_assignment_view.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/manager_tab/header_path.dart';
import 'package:whms/features/home/manager_tab/list_assignment_view.dart';
import 'package:whms/features/home/manager_tab/list_document_view.dart';
import 'package:whms/features/home/manager_tab/no_wu_view.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagementAssignmentView extends StatelessWidget {
  final ManagementCubit managementCubit;

  const ManagementAssignmentView({super.key, required this.managementCubit});

  @override
  Widget build(BuildContext context) {
    var configs = BlocProvider.of<ConfigsCubit>(context);
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, ScaleUtils.scaleSize(4, context)),
                      blurRadius: ScaleUtils.scaleSize(2, context),
                      color: Colors.black.withOpacity(0.2))
                ],
                border: Border.all(
                    color: ColorConfig.primary2,
                    width: ScaleUtils.scaleSize(1, context))),
            child: Row(children: [
              Expanded(
                  flex: 800,
                  child: managementCubit.listWorkings == null ||
                          managementCubit.selectedWorking == null
                      ? const LoadingWidget()
                      : managementCubit.listWorkings!.isEmpty &&
                              managementCubit.listScope.isEmpty
                          ? const Center(
                              child:
                                  Text('Vui lòng liên hệ manager để tạo scope'))
                          : managementCubit.listWorkings!.isEmpty ||
                                  managementCubit.workings.isEmpty
                              ? NoWuView(managementCubit)
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: SingleChildScrollView(
                                      child: Column(children: [
                                    HeaderPath(managementCubit
                                            .selectedWorking!.owner ==
                                        managementCubit.handlerUser.id),
                                    DetailAssignmentView(
                                        userCf: configs.user,
                                        cfC: configs,
                                        managementCubit.selectedWorking!,
                                        managementCubit.assignees,
                                        configs.allScopes,
                                        endEvent: () async {
                                          await managementCubit
                                              .loadListWorkings();
                                        },
                                        call: (v) =>
                                            managementCubit.updateTitle(v),
                                        edited: (v) async {
                                          await managementCubit.updateWU(v);
                                        },
                                        reload: (v) async {
                                          // managementCubit.addItemToTree(v);
                                          managementCubit.buildUI();
                                        }),
                                    ListAssignmentView()
                                  ])))),
              const Expanded(flex: 350, child: ListDocumentView())
            ])));
  }
}
