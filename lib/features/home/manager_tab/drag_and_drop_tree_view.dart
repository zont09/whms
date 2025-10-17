import 'package:whms/features/home/manager_tab/drag_and_drop_tree_tile.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/manager_tab/bloc/choose_parent_popup_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:whms/untils/toast_utils.dart';

class DragAndDropTreeView extends StatefulWidget {
  final ChooseParentPopupCubit cubit;
  const DragAndDropTreeView(this.cubit, {super.key});

  @override
  State<DragAndDropTreeView> createState() => _DragAndDropTreeViewState();
}

class _DragAndDropTreeViewState extends State<DragAndDropTreeView> {
  late final WorkingUnitModel root;
  late final TreeController<WorkingUnitModel> treeController;

  @override
  void initState() {
    super.initState();
    root = widget.cubit.wus.first;
    treeController = TreeController<WorkingUnitModel>(
      roots: widget.cubit.wus.where((e) => e.level == 1),
      childrenProvider: (WorkingUnitModel node) => node.children,
      parentProvider: (WorkingUnitModel node) => node.family,
    );

    _expandInitialNodes();
  }
  void _expandInitialNodes() {
    void expandToNodeWithoutChildren(WorkingUnitModel node) {
      treeController.setExpansionState(node, true);

      var parent = node.family;
      while (parent != null) {
        treeController.setExpansionState(parent, true);
        parent = parent.family;
      }

      for (var child in node.children) {
        treeController.setExpansionState(child, false);
      }
    }

    for (var rootNode in treeController.roots) {
      WorkingUnitModel? foundNode = _findNodeById(rootNode, widget.cubit.wu.id);
      if (foundNode != null) {
        expandToNodeWithoutChildren(foundNode);
        break;
      }
    }
  }

  WorkingUnitModel? _findNodeById(WorkingUnitModel node, String id) {
    if (node.id == id) return node;

    for (var child in node.children) {
      var foundNode = _findNodeById(child, id);
      if (foundNode != null) return foundNode;
    }

    return null;
  }

  // void _expandInitialNodes() {
  //   for (var node in treeController.roots) {
  //     if (node.isOpen) {
  //       treeController.setExpansionState(node, true);
  //       _expandChildNodes(node);
  //     }
  //   }
  // }
  //
  // void _expandChildNodes(WorkingUnitModel node) {
  //   for (var child in node.children) {
  //     treeController.setExpansionState(child, true);
  //     if(widget.cubit.wu.level == 3){
  //       _expandChildNodes(child);
  //     }
  //     if(widget.cubit.wu.level == 1){}
  //   }
  // }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  onNodeAccepted(TreeDragAndDropDetails<WorkingUnitModel> details) {
    WorkingUnitModel? newParent;
    int newIndex = 0;
    bool isSuccess = false;
    details.mapDropPosition(
      whenAbove: () {
        isSuccess = false;
        ToastUtils.showBottomToast(
            context, AppText.toastInstructionDropTree.text);
      },
      whenInside: () {
        isSuccess = true;
        newParent = details.targetNode;
        newIndex = details.targetNode.children.length;

        treeController.setExpansionState(details.targetNode, true);
        widget.cubit.newParent = newParent;
      },
      whenBelow: () {
        isSuccess = false;
        ToastUtils.showBottomToast(
            context, AppText.toastInstructionDropTree.text);
      },
    );
    if (isSuccess) {
      (newParent ?? root).insertChild(newIndex, details.draggedNode);
      treeController.rebuild();
    }
  }

  Duration? longPressDelay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    longPressDelay = switch (Theme.of(context).platform) {
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS =>
        Durations.long2,
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows =>
        null
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTreeView<WorkingUnitModel>(
        treeController: treeController,
        nodeBuilder: (BuildContext context, TreeEntry<WorkingUnitModel> entry) {
          return DragAndDropTreeTile(
              entry: entry,
              isSelected: widget.cubit.wu.id == entry.node.id,
              longPressDelay: longPressDelay,
              onNodeAccepted: (v) async {
                widget.cubit.wu.id == v.draggedNode.id
                    ? onNodeAccepted(v)
                    : ToastUtils.showBottomToast(
                        context,
                        AppText.toastNoPermissionChangeParent.text
                            .replaceAll('@', widget.cubit.wu.title));
              },
              onFolderPressed: () =>
                  treeController.toggleExpansion(entry.node));
        },
        duration: const Duration(milliseconds: 300));
  }
}
