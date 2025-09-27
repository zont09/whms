import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';

class DragTaskWidget extends StatefulWidget {
  const DragTaskWidget(
      {super.key,
      required this.children,
      required this.changeOrder,
      required this.position,
      this.scrollController,
      this.isShowScroll = false});

  final List<Widget> children;
  final Function(int, int) changeOrder;
  final DragIconPosition position;
  final ScrollController? scrollController;
  final bool isShowScroll;

  @override
  State<DragTaskWidget> createState() => _DragTaskWidgetState();
}

class _DragTaskWidgetState extends State<DragTaskWidget> {
  late List<DragAndDropList> _contents;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    _contents = List.generate(1, (index) {
      return DragAndDropList(
        children: <DragAndDropItem>[
          ...widget.children.map(
            (child) => DragAndDropItem(child: child),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isShowScroll) {
      return DragAndDropLists(
        children: _contents,
        scrollController: widget.scrollController,
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        itemDragHandle: DragHandle(
          verticalAlignment: widget.position == DragIconPosition.left
              ? DragHandleVerticalAlignment.center
              : DragHandleVerticalAlignment.top,
          onLeft: widget.position != DragIconPosition.topRight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 5
                              : (widget.position == DragIconPosition.left
                              ? 4
                              : 0),
                          context),
                      bottom: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft ? 8 : 0,
                          context),
                      right: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 0
                              : (widget.position == DragIconPosition.left
                              ? 0
                              : 15),
                          context),
                      top: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 10
                              : (widget.position == DragIconPosition.left
                              ? 0
                              : 10),
                          context)),
                  child: Image.asset(
                    'assets/images/icons/ic_${widget.position == DragIconPosition.topLeft ? "drag2" : (widget.position == DragIconPosition.left ? "drag" : "expand_task")}.png',
                    height: ScaleUtils.scaleSize(12, context),
                    color: Color(0xFFA7A7A7),
                  )),
            ],
          ),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: InvisibleScrollBarWidget(),
      child: DragAndDropLists(
        children: _contents,
        scrollController: widget.scrollController,
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        itemDragHandle: DragHandle(
          verticalAlignment: widget.position == DragIconPosition.left
              ? DragHandleVerticalAlignment.center
              : DragHandleVerticalAlignment.top,
          onLeft: widget.position != DragIconPosition.topRight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 5
                              : (widget.position == DragIconPosition.left
                                  ? 4
                                  : 0),
                          context),
                      bottom: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft ? 8 : 0,
                          context),
                      right: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 0
                              : (widget.position == DragIconPosition.left
                                  ? 0
                                  : 15),
                          context),
                      top: ScaleUtils.scaleSize(
                          widget.position == DragIconPosition.topLeft
                              ? 10
                              : (widget.position == DragIconPosition.left
                                  ? 0
                                  : 10),
                          context)),
                  child: Image.asset(
                    'assets/images/icons/ic_${widget.position == DragIconPosition.topLeft ? "drag2" : (widget.position == DragIconPosition.left ? "drag" : "expand_task")}.png',
                    height: ScaleUtils.scaleSize(12, context),
                    color: Color(0xFFA7A7A7),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
      widget.changeOrder(oldItemIndex, newItemIndex);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }
}

enum DragIconPosition { topLeft, topRight, left }
