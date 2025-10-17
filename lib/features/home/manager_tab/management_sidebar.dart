import 'package:whms/features/home/manager_tab/widget/manager_tab/create_assignment_button.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/list_scope_dropdown.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/management_closed_filter.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/management_sidebar_item.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/reload_cubit.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/widgets/shimmer_loading.dart';

class ManagementSidebar extends StatelessWidget {
  final ManagementCubit cubit;

  const ManagementSidebar(this.cubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReloadCubit, ReloadModel?>(
        listener: (c, s) {
          cubit.loadListWorkings();
        },
        child: Material(
            color: Colors.transparent,
            child: cubit.listScope.isEmpty
                ? Container()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            cubit.selectedScope == null
                                ? const CircularProgressIndicator()
                                : ListScopeDropdown(
                                    selector: cubit.selectedScope,
                                    items: cubit.listScope,
                                    onChanged: (v) {
                                      cubit.chooseScope(v!);
                                      context.go(
                                          '${AppRoutes.manager}/${cubit.selectedScope!.id}&001000000');
                                    }),
                            SizedBox(width: ScaleUtils.scaleSize(5, context)),
                            ManagementClosedFilter(
                              onChanged: (v) async {
                                await cubit.chooseFilter(v!);
                              },
                              items: cubit.filters,
                              selectedItem: cubit.selectedFilter!,
                            )
                          ],
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                                margin: EdgeInsets.only(
                                    bottom: ScaleUtils.scaleSize(30, context)),
                                height: ScaleUtils.scaleSize(1, context),
                                width: ScaleUtils.scaleSize(300, context),
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                      Colors.transparent,
                                      Color.fromRGBO(255, 255, 255, 0.25),
                                      Colors.white,
                                      Color.fromRGBO(255, 255, 255, 0.25),
                                      Colors.transparent
                                    ],
                                        stops: [
                                      0.0,
                                      0.2,
                                      0.5,
                                      0.8,
                                      1.0
                                    ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight)))),
                        if (cubit.state <= 0)
                          Expanded(
                            child: Column(
                              children: [
                                ...List.generate(
                                    3,
                                    (_) => Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: ScaleUtils.scaleSize(
                                                        6, context),
                                                    left: ScaleUtils.scaleSize(
                                                        5, context),
                                                    right: ScaleUtils.scaleSize(
                                                        12, context),
                                                    bottom:
                                                        ScaleUtils.scaleSize(
                                                            6, context)),
                                                child: ShimmerLoading(
                                                    height: 40, radius: 229)),
                                          ],
                                        ))
                              ],
                            ),
                          ),
                        if (cubit.state > 0)
                          Expanded(
                              child: SingleChildScrollView(
                            child: cubit.selectedWorking == null
                                ? Container()
                                : Column(children: [
                                    ...cubit.workings.map(
                                        (e) => ManagementSidebarItem(e, cubit)),
                                    SizedBox(
                                      height: ScaleUtils.scaleSize(5, context),
                                    ),
                                    CreateAssignmentButton(
                                        title: AppText.btnCreateWorkUnit.text,
                                        onTap: () async {
                                          // await configsCubit.getConfiguration();
                                          // if(configsCubit.isNewVersion){
                                          //   configsCubit.reloadVersion();
                                          // }
                                          await cubit.loadUsers();
                                          if (context.mounted) {
                                            DialogUtils.showAlertDialog(context,
                                                child: CreateAssignmentPopup(
                                                  typeAssignment: 1,
                                                  ancestries: cubit.ancestries,
                                                  scopes: [
                                                    cubit.selectedScope!.id
                                                  ],
                                                  userId: cubit.handlerUser.id,
                                                  selectedWorking:
                                                      WorkingUnitModel()
                                                          .copyWith(),
                                                  assignees: cubit
                                                      .selectedScope!.members,
                                                  reload: (v) async {
                                                    // await cubit
                                                    //     .addItemToTree(v);

                                                    // await cubit.loadListWorkings();
                                                    cubit.buildUI();
                                                  },
                                                ));
                                          }
                                        })
                                  ]),
                          ))
                      ])));
  }
}
