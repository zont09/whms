import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/drag_task_widget.dart';
import 'package:flutter/material.dart';

import '../../widgets/task/task_widget.dart';

class ListTaskView extends StatefulWidget {
  const ListTaskView(
      {super.key,
      required this.listWork,
      required this.onChangeTask,
      required this.taskSelected,
      required this.cubitMT,
      required this.changeOrder,
      required this.cntUpdate});

  final List<WorkingUnitModel> listWork;
  final Function(String) onChangeTask;
  final String taskSelected;
  final MainTabCubit cubitMT;
  final Function(int, int) changeOrder;
  final int cntUpdate;

  @override
  State<ListTaskView> createState() => _ListTaskViewState();
}

class _ListTaskViewState extends State<ListTaskView> {
  late ScrollController _scrollController = ScrollController();
  double? _savedScrollPosition;

  @override
  void didUpdateWidget(ListTaskView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskSelected != widget.taskSelected ||
        oldWidget.cntUpdate != widget.cntUpdate) {
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
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(8, context),
          vertical: ScaleUtils.scaleSize(6, context)),
      child: DragTaskWidget(
        isShowScroll: true,
          key: ValueKey(
              "lít_task_view_${widget.taskSelected}_${widget.cntUpdate}_${widget.listWork.length}"),
          scrollController: _scrollController,
          position: DragIconPosition.topRight,
          changeOrder: (a, b) {
            widget.changeOrder(a, b);
          },
          children: widget.listWork
              .map((item) => Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
                    child: TaskWidget(
                        isToday: widget.cubitMT.listToday
                            .any((e) => e.id == item.id),
                        work: item,
                        isSelected: widget.taskSelected == item.id,
                        onTap: (v) {
                          widget.onChangeTask(v);
                        },
                        mapAddress: widget.cubitMT.mapAddress),
                  ))
              .toList()),
    );
  }
}
