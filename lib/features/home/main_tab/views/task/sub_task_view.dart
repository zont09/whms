import 'package:whms/features/home/main_tab/blocs/sub_task_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/create_sub_task.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/drag_task_widget.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/shimmer_loading.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/task/sub_task_widget.dart';

class SubTaskView extends StatefulWidget {
  const SubTaskView(
      {super.key,
      required this.work,
      required this.tab,
      required this.cubitMV,
      required this.user,
      required this.mapWorkChild,
      required this.mapWorkField,
      required this.cntUpdate,
      this.onUpdateWF,
      this.isTaskToday = false});

  final WorkingUnitModel work;
  final String tab;
  final bool isTaskToday;
  final TaskMainViewCubit cubitMV;
  final UserModel user;
  final Map<String, List<WorkingUnitModel>> mapWorkChild;
  final Map<String, WorkFieldModel> mapWorkField;
  final int cntUpdate;
  final Function(WorkFieldModel)? onUpdateWF;

  @override
  State<SubTaskView> createState() => _SubTaskViewState();
}

class _SubTaskViewState extends State<SubTaskView> {
  late ScrollController _scrollController = ScrollController();
  double? _savedScrollPosition;
  late SubTaskCubit cubit;
  bool isChangeTask = false;

  @override
  void initState() {
    cubit = SubTaskCubit();
    cubit.initData(widget.work, widget.isTaskToday, context, widget.user,
        widget.mapWorkChild[widget.work.id] ?? []);
    super.initState();
  }

  @override
  void didUpdateWidget(SubTaskView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.work.id != widget.work.id ||
        oldWidget.cntUpdate != widget.cntUpdate) {
      cubit.initData(widget.work, widget.isTaskToday, context, widget.user,
          widget.mapWorkChild[widget.work.id] ?? []);
      _savedScrollPosition = _scrollController.position.pixels;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_savedScrollPosition != null && _scrollController.hasClients) {
          // _scrollController = ScrollController(initialScrollOffset: _savedScrollPosition!);
          _scrollController.jumpTo(_savedScrollPosition!);
          // _scrollController.position
          //     .setPixels(_savedScrollPosition!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubitMT = BlocProvider.of<MainTabCubit>(context);
    widget.mapWorkField.forEach((k, v) {});
    return BlocBuilder<SubTaskCubit, int>(
      bloc: cubit,
      builder: (c, s) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppText.txtSubTask.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(14, context),
                            fontWeight: FontWeight.w600,
                            color: ColorConfig.textColor)),
                    Row(children: [
                      Text(AppText.titleCreateSubtask.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(14, context),
                              fontWeight: FontWeight.w600,
                              color: ColorConfig.textTertiary)),
                      SizedBox(width: ScaleUtils.scaleSize(4, context)),
                      InkWell(
                          onTap: () {
                            if (!cubit.canCreateSubtask) {
                              ToastUtils.showBottomToast(
                                  context, AppText.textCannotCreateSubtask.text,
                                  duration: 5);
                              return;
                            }
                            DialogUtils.showAlertDialog(context,
                                child: CreateSubTask(
                                  isToday: widget.tab == "201",
                                  isTaskToday: widget.isTaskToday,
                                  updateWF: (v) {
                                    if (widget.onUpdateWF != null) {
                                      widget.onUpdateWF!(v);
                                      widget.cubitMV.cntUpdateTask++;
                                      widget.cubitMV.EMIT();
                                    }
                                  },
                                  address: [
                                    ...cubitMT.mapAddress[widget.work.id]!,
                                    widget.work
                                  ],
                                  work: widget.work,
                                  canEditDefaultTask: false,
                                  // initData: (a, b, c, d) {
                                  //   // cubit.initData(a, b, c, d);
                                  // },
                                  updateSubtask: (v) {
                                    final task = cubitMT.updateSubtask(v);
                                    if (task != null) {
                                      widget.cubitMV.updateTask(task);
                                    }
                                  },
                                  addSubtask: (v) {
                                    cubitMT.addSubtask(v);
                                    final task = cubitMT.updateSubtask(v);
                                    if (task != null) {
                                      widget.cubitMV.updateTask(task);
                                    }
                                    cubit.addSubtask(v);
                                  },
                                ));
                          },
                          child: Image.asset(
                              'assets/images/icons/ic_add_task_2.png',
                              height: ScaleUtils.scaleSize(17, context)))
                    ])
                  ]),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: InvisibleScrollBarWidget(),
                child: s == 0 || isChangeTask
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(
                              3,
                              (_) => Column(
                                    children: [
                                      ShimmerLoading(
                                        height: 80,
                                        radius: 8,
                                      ),
                                      const ZSpace(h: 9)
                                    ],
                                  ))
                        ],
                      )
                    : Padding(
                        padding:
                            EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
                        child: DragTaskWidget(
                            scrollController: _scrollController,
                            key: ValueKey(
                                "sub_task_${cubit.listSubtask.length}_${widget.work.id}_${widget.cntUpdate}"),
                            changeOrder: (a, b) {
                              cubit.changeOrder(a, b);
                            },
                            position: DragIconPosition.topLeft,
                            children: cubit.listSubtask
                                .map((item) => Padding(
                                      padding: EdgeInsets.all(
                                          ScaleUtils.scaleSize(3, context)),
                                      child: SubTaskWidget(
                                        tab: widget.tab,
                                        isToday: widget.isTaskToday,
                                        isDefaultTask:
                                            item.id == cubit.subtaskDF?.id,
                                        workUnit: item,
                                        workField: widget.mapWorkField[item.id],
                                        updateWF: (v) {
                                          if (widget.onUpdateWF != null) {
                                            widget.onUpdateWF!(v as WorkFieldModel);
                                            widget.cubitMV.cntUpdateTask++;
                                            widget.cubitMV.EMIT();
                                          }
                                        },
                                        onSelected: (value) {
                                          cubit.selectedSubtask(value);
                                        },
                                        showMenu:
                                            item.id == cubit.subtaskSelected,
                                        address: cubitMT
                                                .mapAddress[widget.work.id] ??
                                            [widget.work],
                                        work: widget.work,
                                        canEditDefaultTask:
                                            cubit.canEditDefaultTask,
                                        initData: (a, b, c, d) {
                                          // cubit.initData(a, b, c, d);
                                        },
                                        updateSubtask: (v) {
                                          final task = cubitMT.updateSubtask(v);
                                          if (task != null) {
                                            widget.cubitMV.updateTask(task);
                                          }
                                        },
                                        removeSubtask: (v) {
                                          cubitMT.removeSubtask(v);
                                          final task = cubitMT.updateSubtask(v);
                                          if (task != null) {
                                            widget.cubitMV.updateTask(task);
                                          }
                                          cubit.removeSubtask(v);
                                        },
                                      ),
                                    ))
                                .toList())),
              ),
            ),
          ],
        );
      },
    );
  }
}
