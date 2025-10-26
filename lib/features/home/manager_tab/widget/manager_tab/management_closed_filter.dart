import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ManagementClosedFilter extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String?)? onChanged;
  const ManagementClosedFilter(
      {required this.onChanged,
      required this.items,
      required this.selectedItem,
      super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2(
            buttonStyleData: const ButtonStyleData(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
            customButton: Container(
              width: ScaleUtils.scaleSize(35, context),
              height: ScaleUtils.scaleSize(35, context),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: Image.asset(
                'assets/images/icons/ic_filter.png',
                color: ColorConfig.primary3,
                scale: 3,
              ),
              // child: Icon(Icons.filter_alt_rounded,
              //     size: ScaleUtils.scaleSize(20, context),
              //     color: ColorConfig.primary3)
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                  value: item,
                  alignment: Alignment.centerRight,
                  child: Text(item,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: selectedItem == item
                              ? ColorConfig.primary3
                              : ColorConfig.textColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.02 * 14, context),
                          overflow: TextOverflow.ellipsis,
                          height: 1,
                          fontSize: ScaleUtils.scaleSize(14, context))));
            }).toList(),
            onChanged: onChanged,
            dropdownStyleData: DropdownStyleData(
                width: ScaleUtils.scaleSize(100, context),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(10, context)),
                  color: Colors.white,
                ),
                offset: Offset(-ScaleUtils.scaleSize(100 - 35, context),
                    -ScaleUtils.scaleSize(5, context))),
            menuItemStyleData: MenuItemStyleData(
                height: ScaleUtils.scaleSize(35, context),
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(16, context)))));
  }
}
