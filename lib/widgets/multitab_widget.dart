import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';

class MultitabWidget extends StatelessWidget {
  const MultitabWidget(
      {super.key,
      required this.tabs,
      required this.tabSelected,
      required this.selectTab,
      this.fontSize = 12});

  final List<String> tabs;
  final String tabSelected;
  final Function(String) selectTab;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: InvisibleScrollBarWidget(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              children: [
                ...tabs.map((item) => Row(
                      children: [
                        InkWell(
                          onTap: () {
                            selectTab(item);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: ScaleUtils.scaleSize(item == tabSelected ? 2 : 1, context),
                                        color: item == tabSelected
                                            ? ColorConfig.primary3
                                            : const Color(0xFFE9E9E9)))),
                            padding: EdgeInsets.only(
                                bottom: ScaleUtils.scaleSize(item == tabSelected ? 9 : 10, context)),
                            child: Text(
                              item,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(fontSize, context),
                                  fontWeight: FontWeight.w700,
                                  color: item == tabSelected
                                      ? ColorConfig.primary3
                                      : ColorConfig.textTertiary),
                            ),
                          ),
                        ),
                        Container(
                          width: ScaleUtils.scaleSize(40, context),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: ScaleUtils.scaleSize(1, context),
                                      color: const Color(0xFFE9E9E9)))),
                          padding: EdgeInsets.only(bottom: ScaleUtils.scaleSize(1, context)),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}
