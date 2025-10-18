import 'dart:ui';

import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/avatar_item.dart';

class HrSideBarUserItem extends StatelessWidget {
  final bool isActive;
  final String avt;
  final String title;
  final Function() onTap;
  final double iconSize;
  final double titleSize;
  final bool isShowIconDropdown;
  final bool isExpand;

  const HrSideBarUserItem(
      {required this.onTap,
        required this.isActive,
        required this.avt,
        this.iconSize = 24,
        this.titleSize = 16,
        required this.title,
        this.isShowIconDropdown = false,
        this.isExpand = false,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      InkWell(
          onTap: onTap,
          child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(7, context),
                  vertical:
                  ScaleUtils.scaleSize(iconSize > 22 ? 4 : 5, context)),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(1000),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                        blurStyle: BlurStyle.outer,
                        blurRadius: ScaleUtils.scaleSize(3, context),
                        color: Colors.black.withOpacity(0.5),
                        offset:
                        Offset(0, ScaleUtils.scaleSize(2, context)))
                  ]
                      : [],
                  border: Border.all(
                      color: isActive ? Colors.white : Colors.transparent)),
              child: Row(children: [
                AvatarItem(avt, size: iconSize,),
                SizedBox(width: ScaleUtils.scaleSize(6, context)),
                Text(title,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(titleSize, context),
                        fontWeight:
                        isActive ? FontWeight.w800 : FontWeight.w500,
                        fontFamily: 'Afacad',
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
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
                SizedBox(width: ScaleUtils.scaleSize(6, context)),
                if (isShowIconDropdown)
                  SizedBox(width: ScaleUtils.scaleSize(2, context)),
                if (isShowIconDropdown)
                  Icon(
                    isExpand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: ScaleUtils.scaleSize(20, context),
                    color: Colors.white,
                  ),
              ])))
    ]);
  }
}
