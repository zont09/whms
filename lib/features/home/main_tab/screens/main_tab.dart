import 'package:whms/configs/color_config.dart';
import 'package:whms/features/chat/view/floating_chat_box.dart';
import 'package:whms/features/home/main_tab/views/meeting/meeting_main_view.dart';
import 'package:whms/features/home/main_tab/views/personal/personal_master_view.dart';
import 'package:whms/features/home/main_tab/views/task/task_main_view.dart';
import 'package:whms/features/home/main_tab/widgets/main_sidebar.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/widgets/app_bar/new_app_bar.dart';
import 'package:whms/widgets/invalid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key, required this.tab});

  final String tab;

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    final user = ConfigsCubit.fromContext(context).user;
    return Material(
      child: BlocProvider(
        create: (context) => MainTabCubit(cfC)
          ..initDataDefault(
            context,
            cfC.allWorkingUnit,
            cfC.mapWorkingUnit,
            cfC.mapWorkChild,
          ),
        child: BlocListener<ConfigsCubit, ConfigsState>(
          listenWhen: (previous, current) =>
              current.updatedEvent == ConfigStateEvent.task ||
              current.updatedEvent == ConfigStateEvent.workShift ||
              current.updatedEvent == ConfigStateEvent.workField,
          listener: (cc, ss) {
            var cubitMT = BlocProvider.of<MainTabCubit>(cc);
            if (ss.updatedEvent == ConfigStateEvent.task &&
                ss.data is List<WorkingUnitModel>) {
              for (var e in ss.data) {
                cubitMT.updateWorkingUnit(e, isEmit: false);
              }
              cubitMT.EMIT();
            } else if (ss.updatedEvent == ConfigStateEvent.task &&
                ss.data is WorkingUnitModel &&
                ss.data.id.isNotEmpty) {
              cubitMT.updateWorkingUnit(ss.data);
            }
            if (ss.updatedEvent == ConfigStateEvent.workShift &&
                ss.data != null &&
                ss.data.id.isNotEmpty) {
              cubitMT.updateWorkShift(ss.data);
            }
            if (ss.updatedEvent == ConfigStateEvent.workField) {
              if (ss.data is List<WorkFieldModel>) {
                for (var e in ss.data) {
                  cubitMT.updateWorkField(e);
                }
              } else if (ss.data is WorkFieldModel) {
                cubitMT.updateWorkField(ss.data);
              }
            }
          },
          child: BlocBuilder<MainTabCubit, int>(
            builder: (c, s) {
              var cubit = BlocProvider.of<MainTabCubit>(c);
              // if (s == 0) {
              //   return const SplashScreen();
              // }
              // if (s != 0) {
              //   if (user.avt.isEmpty) {
              //     checkChangeAvatar(context, user.id);
              //   }
              // }
              return Stack(
                children: [
                  Column(
                    children: [
                      const NewAppBar(isHome: true, tab: 1),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          height: double.infinity,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Material(
                                  color: ColorConfig.primary3,
                                  child: MainSidebar(
                                    curTab: widget.tab,
                                    cubit: cubit,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: (widget.tab[0] == "2")
                                    ? (s ==
                                              0 //|| cfC.loadingWorkingUnit > 0
                                          ? TaskMainView(
                                              tab: widget.tab,
                                              cubitTM: cubit,
                                            )
                                          : TaskMainView(
                                              tab: widget.tab,
                                              cubitTM: cubit,
                                            ))
                                    : getTabMainScreen(
                                        widget.tab,
                                        user,
                                        cubit.listUserScope,
                                        cubit.listProject,
                                        cubit,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget getTabMainScreen(
  String tab,
  UserModel user,
  List<ScopeModel> listScp,
  List<WorkingUnitModel> listPrj,
  MainTabCubit cubit,
) {
  String mainTab = tab[0];
  final tabViews = {
    "1": PersonalMasterView(cubit: cubit),
    "4": MeetingMainView(tab: tab),
  };
  return tabViews[mainTab] ?? const Center(child: InvalidWidget());
}
