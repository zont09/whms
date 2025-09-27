import 'dart:ui';

import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/progress_circle.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class MainSidebarItem extends StatelessWidget {
  final bool isActive;
  final String icon;
  final String title;
  final int numQuest;
  final Function() onTap;
  final double iconSize;
  final double titleSize;
  final bool isShowIconDropdown;
  final int? cntIssue;
  final int? doneIssue;
  final bool isExpand;

  const MainSidebarItem(
      {required this.onTap,
      required this.isActive,
      required this.icon,
      this.iconSize = 24,
      this.titleSize = 16,
      required this.title,
      required this.numQuest,
      this.isShowIconDropdown = false,
      this.cntIssue,
      this.doneIssue,
      this.isExpand = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(7, context),
                vertical: ScaleUtils.scaleSize(iconSize > 22 ? 4 : 5, context)),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            blurStyle: BlurStyle.outer,
                            blurRadius: ScaleUtils.scaleSize(3, context),
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                      ]
                    : [],
                border: Border.all(
                    color: isActive ? Colors.white : Colors.transparent)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Center(
                  child: Stack(alignment: Alignment.center, children: [
                if (!isActive)
                  Container(
                      margin: EdgeInsets.only(
                          top: ScaleUtils.scaleSize(3, context),
                          left: ScaleUtils.scaleSize(3, context)),
                      child: Image.asset(icon,
                          color: Colors.black.withOpacity(0.3),
                          fit: BoxFit.cover,
                          height: ScaleUtils.scaleSize(iconSize, context))),
                Image.asset(icon,
                    height: ScaleUtils.scaleSize(iconSize, context),
                    color: Colors.white,
                    fit: BoxFit.cover)
              ])),
              SizedBox(width: ScaleUtils.scaleSize(6, context)),
              Flexible(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(titleSize, context),
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w500,
                        fontFamily: 'Afacad',
                        color: Colors.white,
                        shadows: !isActive
                            ? [
                                BoxShadow(
                                    blurRadius:
                                        ScaleUtils.scaleSize(3, context),
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(
                                        0, ScaleUtils.scaleSize(2, context)))
                              ]
                            : [])),
              ),
              if (numQuest >= 0) ...[
                SizedBox(width: ScaleUtils.scaleSize(6, context)),
                Container(
                    width: ScaleUtils.scaleSize(20, context),
                    height: ScaleUtils.scaleSize(20, context),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: !isActive
                            ? [
                                BoxShadow(
                                    blurRadius:
                                        ScaleUtils.scaleSize(3, context),
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(
                                        0, ScaleUtils.scaleSize(2, context)))
                              ]
                            : [],
                        color: Colors.white),
                    alignment: Alignment.center,
                    child: Text("$numQuest",
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(10, context),
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: ColorConfig.primary2)))
              ],
              if (cntIssue != null)
                const ZSpace(w: 8),
              if (cntIssue != null)
                ProgressCircle(
                  done: doneIssue!,
                  cnt: cntIssue!,
                  size: 20,
                  fontSize: 12,
                  strokeWidth: 2,
                  textColor: Colors.white,
                ),
              if (cntIssue != null)
                const ZSpace(w: 4),
              if (isShowIconDropdown) ...[
                SizedBox(width: ScaleUtils.scaleSize(2, context)),
                Icon(
                  isExpand
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: ScaleUtils.scaleSize(20, context),
                  color: Colors.white,
                )
              ],

            ])));
  }
}
