import 'package:whms/configs/color_config.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ParentTile extends StatelessWidget {
  const ParentTile({
    super.key,
    required this.entry,
    required this.isSelected,
    this.onFolderPressed,
    this.decoration,
    this.showIndentation = true,
  });

  final TreeEntry<WorkingUnitModel> entry;
  final VoidCallback? onFolderPressed;
  final Decoration? decoration;
  final bool showIndentation;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    double size = entry.node.sizeIconParent;
    Widget content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFolderPressed,
        child: Padding(
          padding: EdgeInsets.only(right: ScaleUtils.scaleSize(10, context)),
          child: Row(
            children: [
              IconButton(
                onPressed: null,
                icon: Image.asset(entry.node.iconParent,
                    color: isSelected ? null : ColorConfig.border2,
                    width: ScaleUtils.scaleSize(size, context),
                    height: ScaleUtils.scaleSize(size, context)),
              ),
              Expanded(
                  child: Text(entry.node.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color:
                              isSelected ? ColorConfig.primary3 : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: ScaleUtils.scaleSize(15, context)))),
              if (entry.node.children.isNotEmpty)
                FolderButton(
                    isOpen: entry.node.isLeaf ? null : entry.isExpanded,
                    onPressed: null,
                    icon: Icon(
                      entry.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade500,
                      size: ScaleUtils.scaleSize(20, context),
                    ),
                    closedIcon: Icon(
                      entry.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade500,
                      size: ScaleUtils.scaleSize(20, context),
                    ),
                    openedIcon: Icon(
                      entry.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade500,
                      size: ScaleUtils.scaleSize(20, context),
                    )),
            ],
          ),
        ),
      ),
    );

    if (decoration != null) {
      content = DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }

    if (showIndentation) {
      return TreeIndentation(
        entry: entry,
        child: content,
      );
    }

    return content;
  }
}
