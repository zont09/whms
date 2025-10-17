import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/parent_tile.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class DragAndDropTreeTile extends StatelessWidget {
  const DragAndDropTreeTile(
      {super.key,
      required this.entry,
      required this.onNodeAccepted,
      required this.isSelected,
      this.longPressDelay,
      this.onFolderPressed});

  final TreeEntry<WorkingUnitModel> entry;
  final TreeDragTargetNodeAccepted<WorkingUnitModel> onNodeAccepted;
  final Duration? longPressDelay;
  final VoidCallback? onFolderPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: ScaleUtils.scaleSize(15, context)),
        child: TreeDragTarget<WorkingUnitModel>(
            node: entry.node,
            onNodeAccepted: onNodeAccepted,
            builder: (BuildContext context,
                TreeDragAndDropDetails<WorkingUnitModel>? details) {
              Decoration? decoration;
              if (details != null) {
                decoration = BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScaleUtils.scaleSize(5, context)),
                    border: details.mapDropPosition(
                        whenAbove: () => Border(
                            top: BorderSide(
                                color: ColorConfig.border2,
                                width: ScaleUtils.scaleSize(1, context))),
                        whenInside: () => Border.fromBorderSide(BorderSide(
                            color: ColorConfig.primary3,
                            width: ScaleUtils.scaleSize(1, context))),
                        whenBelow: () => Border(
                            bottom: BorderSide(
                                color: ColorConfig.border2,
                                width: ScaleUtils.scaleSize(1, context)))));
              }
              return TreeDraggable<WorkingUnitModel>(
                  node: entry.node,
                  longPressDelay: longPressDelay,
                  childWhenDragging: Opacity(
                      opacity: .5,
                      child: IgnorePointer(
                          child: ParentTile(
                              entry: entry, isSelected: isSelected))),
                  feedback: IntrinsicWidth(
                      child: Material(
                          elevation: 4,
                          child: ParentTile(
                              entry: entry,
                              showIndentation: false,
                              isSelected: isSelected,
                              onFolderPressed: () {}))),
                  child: ParentTile(
                      entry: entry,
                      onFolderPressed:
                          entry.node.isLeaf ? null : onFolderPressed,
                      isSelected: isSelected,
                      decoration: decoration));
            }));
  }
}

extension DropPosition on TreeDragAndDropDetails<WorkingUnitModel> {
  /// Splits the target node's height in three and checks the vertical offset
  /// of the dragging node, applying the appropriate callback.
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}
