import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class ReorderAbleWidget extends StatefulWidget {
  final List<Widget> children;
  final Function(int, int) changeOrder;
  final double iconSize;
  const ReorderAbleWidget(
      {required this.children, required this.changeOrder,
        this.iconSize = 16, super.key});

  @override
  State<ReorderAbleWidget> createState() => _ReorderAbleWidgetState();
}

class _ReorderAbleWidgetState extends State<ReorderAbleWidget> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = widget.children.removeAt(oldIndex);
          widget.children.insert(newIndex, item);
        });
        widget.changeOrder(oldIndex, newIndex);
      },
      children: [
        for (int i = 0; i < widget.children.length; i++)
          Row(
            key: ValueKey(widget.children[i]),
            children: [
              ReorderableDragStartListener(
                  index: i,
                  child: Icon(Icons.drag_indicator,
                      size: ScaleUtils.scaleSize(widget.iconSize, context))),
              Expanded(
                child: widget.children[i], // Nội dung item
              ),
            ],
          ),
      ],
    );
  }
}
