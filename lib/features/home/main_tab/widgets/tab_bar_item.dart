import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class TabBarItem extends StatelessWidget {
  const TabBarItem({
    super.key,
    required this.icon,
    required this.tab,
    required this.curTab,
    required this.title,
    required this.onTap,
    this.numQuest = -1,
  });

  final String icon;
  final int tab;
  final int curTab;
  final String title;
  final Function() onTap;
  final int numQuest;

  @override
  Widget build(BuildContext context) {
    return ZButton(
        title: title,
        icon: icon,
        colorTitle: tab == curTab ? ColorConfig.primary2 : Colors.white,
        colorIcon: tab == curTab ? ColorConfig.primary2 : Colors.white,
        colorBackground: tab == curTab ? Colors.white : Colors.transparent,
        colorBorder: tab == curTab ? Colors.white : Colors.transparent,
        shadowText: tab == curTab
            ? [
                BoxShadow(
                    blurRadius: 4,
                    color: ColorConfig.shadow,
                    offset: const Offset(0, 2))
              ]
            : [],
        suffix: numQuest >= 0
            ? Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tab == curTab ? ColorConfig.primary2 : Colors.white),
                padding: EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
                alignment: Alignment.center,
                child: Text(
                  "$numQuest",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(10, context),
                      fontWeight: FontWeight.w600,
                      color:tab == curTab ? Colors.white : ColorConfig.primary2),
                ),
              )
            : null,
        onPressed: () {
          onTap();
        });
  }
}
