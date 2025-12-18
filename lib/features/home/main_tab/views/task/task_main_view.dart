import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/views/no_task_view.dart';
import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/features/home/main_tab/screens/task_done_today_view.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/detail_task_view.dart';
import 'package:whms/features/home/main_tab/views/task/header_list_task_view.dart';
import 'package:whms/features/home/main_tab/views/task/loading_task_main_view.dart';
import 'package:whms/features/home/main_tab/views/task/task_main_page.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list_task_view.dart';

class TaskMainView extends StatefulWidget {
  const TaskMainView({super.key, required this.tab, required this.cubitTM});

  final String tab;
  final MainTabCubit cubitTM;

  @override
  State<TaskMainView> createState() => _TaskMainViewState();
}

class _TaskMainViewState extends State<TaskMainView> {
  late final TaskMainViewCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = TaskMainViewCubit();
    _initData();
  }

  @override
  void didUpdateWidget(TaskMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _initData();
    } else if (widget.tab == '201' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listToday, oldWidget.cubitTM.listToday)) {
      cubit.updateListWork(widget.cubitTM.listToday);
    } else if (widget.tab == '206' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listDoing, oldWidget.cubitTM.listDoing)) {
      cubit.updateListWork(widget.cubitTM.listDoing);
    } else if (widget.tab == '202' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listTop, oldWidget.cubitTM.listTop)) {
      cubit.updateListWork(widget.cubitTM.listTop);
    } else if (widget.tab == '203' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listPersonal, oldWidget.cubitTM.listPersonal)) {
      cubit.updateListWork(widget.cubitTM.listPersonal);
    } else if (widget.tab == '204' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listAssign, oldWidget.cubitTM.listAssign)) {
      cubit.updateListWork(widget.cubitTM.listAssign);
    } else if (widget.tab == '205' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listUrgent, oldWidget.cubitTM.listUrgent)) {
      cubit.updateListWork(widget.cubitTM.listUrgent);
    } else if (widget.tab == '207' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listFollowing, oldWidget.cubitTM.listFollowing)) {
      cubit.updateListWork(widget.cubitTM.listFollowing);
    } else if (widget.tab == '2' &&
        FunctionUtils.isEqualList(
            widget.cubitTM.listFullTask, oldWidget.cubitTM.listFullTask)) {
      cubit.updateListWork(widget.cubitTM.listFullTask);
    }
  }

  Future<void> _initData() async {
    List<WorkingUnitModel> listData = [];
    switch (widget.tab) {
      case "2":
        listData = widget.cubitTM.listFullTask;
        break;
      case "201":
        listData = widget.cubitTM.listToday;
        break;
      case "202":
        listData = widget.cubitTM.listTop;
        break;
      case "203":
        listData = widget.cubitTM.listPersonal;
        break;
      case "204":
        listData = widget.cubitTM.listAssign;
        break;
      case "205":
        listData = widget.cubitTM.listUrgent;
        break;
      case "206":
        listData = widget.cubitTM.listDoing;
        break;
      case "207":
        listData = widget.cubitTM.listFollowing;
        break;
    }
    // if (widget.cubitTM.state > 0) {
      await cubit.initData(
          context, listData, widget.cubitTM.listScope, widget.tab);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    final cfC = ConfigsCubit.fromContext(context);
    return BlocListener<ConfigsCubit, ConfigsState>(
      listenWhen: (pre, cur) =>
          cur.updatedEvent == ConfigStateEvent.task && cur.data != null,
      listener: (cc, ss) {
        if (ss.data != null &&
            ss.data is WorkingUnitModel &&
            ss.data.id.isNotEmpty) {
          cubit.updateWorkingUnit(ss.data);
        }
      },
      child: BlocBuilder<TaskMainViewCubit, int>(
          bloc: cubit,
          builder: (c, s) {
            final isNoTask = cubit.listWork
                .where((item) =>
                    (cubit.selectedScope == AppText.textPrivateKey.text ||
                        item.scopes.contains(cubit.selectedScope)))
                .isEmpty;
            // if (s == 0) {
            //   return Container(
            //       color: Colors.white,
            //       height: double.infinity,
            //       width: double.infinity,
            //       child: const LoadingWidget());
            // }
            if (s == 0 || cfC.loadingWorkingUnit > 0 || (widget.tab == "201" && cfC.loadingWorkShift > 0)) {
              return LoadingTaskMainView(
                  s: s, widget: widget, cfC: cfC, cubit: cubit);
            }
            if (cubit.listWork.isEmpty) {
              if (checkIn == StatusCheckInDefine.checkOut &&
                  widget.tab == "201") {
                return const TaskDoneToDayView();
              }
              return NoTaskView(tab: widget.tab);
            }
            if (widget.tab == "2") {
              return TaskMainPage(
                cubitMT: widget.cubitTM,
                getDataWorkChild: (v) {
                  widget.cubitTM.getDataTaskChildAndUser(v);
                },
                listWork: cubit.listWork,
                sorted: widget.cubitTM.sortedFullTask,
                listScope: widget.cubitTM.listScope,
                mapAddress: widget.cubitTM.mapAddress,
                mapScope: widget.cubitTM.mapScope,
                mapWorkChild: widget.cubitTM.mapWorkChild,
                numberOfSubtask: widget.cubitTM.mapNumberSubTask,
                updateListTask: (v) {
                  widget.cubitTM.updateTaskListFullTask(v);
                },
              );
            }

            return Container(
                color: ColorConfig.whiteBackground,
                height: double.infinity,
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: ScaleUtils.scaleSize(20, context),
                    left: ScaleUtils.scaleSize(20, context),
                    bottom: ScaleUtils.scaleSize(20, context),
                    right: ScaleUtils.scaleSize(20, context)),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        HeaderListTaskView(
                          cubit: cubit,
                          tab: widget.tab,
                          cubitMT: widget.cubitTM,
                        ),
                        SizedBox(height: ScaleUtils.scaleSize(12, context)),
                        Expanded(
                            child: ListTaskView(
                          cntUpdate: cubit.cntUpdateTask,
                          listWork: cubit.listWork,
                          changeOrder: (a, b) {
                            cubit.changeOrder(a, b);
                          },
                          onChangeTask: (v) {
                            cubit.changeTask(v);
                          },
                          taskSelected: cubit.selectedTask,
                          cubitMT: widget.cubitTM,
                        ))
                      ])),
                  SizedBox(width: ScaleUtils.scaleSize(20, context)),
                  if (isNoTask)
                    const Expanded(flex: 3, child: NoTaskView(tab: "-229")),
                  if (!isNoTask)
                    Expanded(
                        flex: 3,
                        child: DetailTaskView(
                            cubitMT: widget.cubitTM,
                            tab: widget.tab,
                            work: cubit.mapWorkId[cubit.selectedTask] ??
                                WorkingUnitModel(),
                            cubit: cubit))
                ]));
          }),
    );
  }
}
