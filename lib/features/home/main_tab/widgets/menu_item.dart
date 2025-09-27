import 'package:whms/features/home/main_tab/widgets/main_sidebar_item.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  const MenuItem(
      {super.key,
      required this.icon,
      required this.title,
      required this.children,
      required this.tab,
      required this.curTab,
      required this.onTap,
      this.numQuest = -1,
      this.level = 1,
      this.fontSize = 16,
      this.iconSize = 24,
      this.isFirst = false,
      this.cntIssue,
      this.doneIssue});

  final String icon;
  final String title;
  final List<Widget> children;
  final String tab;
  final String curTab;
  final int numQuest;
  final Function() onTap;
  final int level;
  final double fontSize;
  final double iconSize;
  final int? cntIssue;
  final int? doneIssue;
  final bool isFirst;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final ExpansionTileController _controller = ExpansionTileController();
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent),
        child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                isExpand = expanded;
              });
              if (expanded) {
                widget.onTap();
              }
            },
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            trailing: const SizedBox.shrink(),
            initiallyExpanded: (widget.curTab.startsWith(widget.tab)) ||
                (widget.isFirst && widget.curTab == "1"),
            controller: _controller,
            title: Container(
              width: constraints.maxWidth,
              alignment: Alignment.centerLeft,
              child: MainSidebarItem(
                onTap: () {
                  widget.onTap();
                  if (_controller.isExpanded) {
                    _controller.collapse();
                  } else {
                    if (widget.curTab[0] == widget.tab[0] ||
                        (widget.isFirst && widget.curTab == "1")) {
                      _controller.expand();
                    }
                  }
                },
                isActive: widget.tab == widget.curTab ||
                    (widget.isFirst && widget.curTab == "1"),
                isExpand: isExpand,
                icon: widget.icon,
                title: widget.title,
                iconSize: widget.iconSize,
                titleSize: widget.fontSize,
                isShowIconDropdown: widget.children.isNotEmpty,
                numQuest: widget.numQuest,
                cntIssue: widget.cntIssue,
                doneIssue: widget.doneIssue,
              ),
            ),
            children: widget.children
                .map((child) => Container(
                    width: constraints.maxWidth,
                    margin: EdgeInsets.only(
                        top: ScaleUtils.scaleSize(2, context),
                        bottom: ScaleUtils.scaleSize(2, context),
                        left:
                            ScaleUtils.scaleSize(30.0 * widget.level, context)),
                    alignment: Alignment.centerLeft,
                    child: child))
                .toList()),
      );
    });
  }
}
