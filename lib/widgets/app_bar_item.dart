import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class AppBarItem extends StatelessWidget {
  const AppBarItem(
      {super.key, this.icon,
      required this.title,
      required this.tab,
      required this.curTab,
      required this.onTap});

  final String? icon;
  final String title;
  final int tab;
  final int curTab;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: ScaleUtils.scaleSize(36, context),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(16, context)),
            decoration: BoxDecoration(
                color: tab == curTab ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: tab == curTab
                    ? [
                  BoxShadow(
                      blurRadius: ScaleUtils.scaleSize(3, context),
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                ]
                    : []
            ),
            child: Row(children: [
              Stack(alignment: Alignment.center, children: [
                !(tab == curTab) && icon != null && icon!.isNotEmpty
                    ? Container(
                    margin: EdgeInsets.only(
                        top: ScaleUtils.scaleSize(3, context),
                        left: ScaleUtils.scaleSize(3, context)),
                    child: Image.asset(icon!,
                        color: Colors.black.withOpacity(0.3),
                        fit: BoxFit.cover,
                        height: ScaleUtils.scaleSize(24, context)))
                    : Container(),
                if(icon != null && icon!.isNotEmpty)
                Image.asset(icon!,
                    height: ScaleUtils.scaleSize(24, context),
                    color: tab == curTab ? ColorConfig.primary1 : Colors.white,
                    fit: BoxFit.cover)
              ]),
              if(icon != null && icon!.isNotEmpty)
              SizedBox(width: ScaleUtils.scaleSize(6, context)),
              Text(title,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(14, context),
                      fontWeight:
                      tab == curTab ? FontWeight.w700 : FontWeight.w400,
                      fontFamily: 'Afacad',
                      color:
                      tab == curTab ? ColorConfig.primary1 : Colors.white,
                      shadows: !(tab == curTab)
                          ? [
                        BoxShadow(
                            blurRadius: ScaleUtils.scaleSize(2, context),
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(
                                0, ScaleUtils.scaleSize(2, context)))
                      ]
                          : [])),
            ])),
        Positioned.fill(child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(1000),
            onTap: onTap,
          ),
        ))
      ],
    );
  }
}
