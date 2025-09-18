import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class FilterTaskButton extends StatelessWidget {
  const FilterTaskButton(
      {super.key,
      required this.tab,
      required this.curTab,
      required this.onTap,
      required this.title});

  final int tab;
  final int curTab;
  final String title;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(tab),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: const Color(0xFF950606)),
            color: tab == curTab ? const Color(0xFF950606) : Colors.white),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(8, context),
            vertical: ScaleUtils.scaleSize(4, context)),
        child: Text(
          title,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(12, context),
              fontWeight: FontWeight.w500,
              color: tab == curTab ? Colors.white : const Color(0xFF950606)),
        ),
      ),
    );
  }
}
