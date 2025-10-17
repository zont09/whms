import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ListAssignmentDropdown extends StatelessWidget {
  ListAssignmentDropdown(
      {super.key,
      required this.selector,
      required this.items,
      required this.onChanged});

  final List<TypeAssignmentDefine> items;
  final TypeAssignmentDefine selector;
  final Function(TypeAssignmentDefine?)? onChanged;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScaleUtils.scaleSize(150, context),
        margin: EdgeInsets.only(left: ScaleUtils.scaleSize(10, context)),
        decoration: BoxDecoration(
            border: Border.all(color: ColorConfig.primary3),
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(1000, context))),
        child: ValueListenableBuilder<bool>(
            valueListenable: isOpen,
            builder: (context, value, child) => DropdownButtonFormField2<TypeAssignmentDefine>(
                isExpanded: true,
                decoration: InputDecoration(
                    constraints: BoxConstraints(
                        maxHeight: ScaleUtils.scaleSize(28, context)),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ScaleUtils.scaleSize(5, context)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1000),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(1000),
                        borderSide:
                            const BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(1000), borderSide: const BorderSide(color: Colors.transparent, width: 0))),
                value: selector,
                items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.title, style: TextStyle(color: ColorConfig.primary3, fontSize: ScaleUtils.scaleSize(12, context), fontWeight: FontWeight.w500)))).toList(),
                onChanged: onChanged,
                onMenuStateChange: (v) => isOpen.value = v,
                buttonStyleData: ButtonStyleData(padding: EdgeInsets.only(right: ScaleUtils.scaleSize(8, context))),
                iconStyleData: IconStyleData(icon: Icon(!isOpen.value ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: ColorConfig.primary3), iconSize: ScaleUtils.scaleSize(24, context)),
                dropdownStyleData: DropdownStyleData(maxHeight: ScaleUtils.scaleSize(200, context), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(12, context)))),
                menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(28, context), padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(16, context))))));
  }
}
