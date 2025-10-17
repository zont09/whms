import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ListScopeDropdown extends StatelessWidget {
  ListScopeDropdown({
    super.key,
    required this.selector,
    required this.items,
    required this.onChanged,
  });

  final List<ScopeModel> items;
  final ScopeModel? selector;
  final Function(ScopeModel?)? onChanged;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(
          vertical: ScaleUtils.scaleSize(20, context),
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1000),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: ScaleUtils.scaleSize(4, context),
                  offset: Offset(0, ScaleUtils.scaleSize(2, context)))
            ]),
        width: ScaleUtils.scaleSize(200, context),
        child: ValueListenableBuilder<bool>(
            valueListenable: isOpen,
            builder: (context, value, child) {
              return DropdownButtonFormField2<ScopeModel>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      constraints: BoxConstraints(
                          maxHeight: ScaleUtils.scaleSize(35, context)),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: ScaleUtils.scaleSize(5, context)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0))),
                  value: selector,
                  items: items.map((item) {
                    return DropdownMenuItem<ScopeModel>(
                        value: item,
                        child: Text(item.title,
                            maxLines: 1,
                            style: TextStyle(
                                color: ColorConfig.primary3,
                                fontWeight: FontWeight.w500,
                                letterSpacing:
                                    ScaleUtils.scaleSize(-0.02 * 16, context),
                                overflow: TextOverflow.ellipsis,
                                height: 1,
                                fontSize: ScaleUtils.scaleSize(16, context))));
                  }).toList(),
                  onChanged: onChanged,
                  onMenuStateChange: (v) => isOpen.value = v,
                  buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.only(
                          right: ScaleUtils.scaleSize(8, context))),
                  iconStyleData: IconStyleData(
                      icon: selector == null
                          ? Container()
                          : Icon(
                              isOpen.value
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: ColorConfig.primary3),
                      iconSize: ScaleUtils.scaleSize(24, context)),
                  dropdownStyleData: DropdownStyleData(
                      maxHeight: ScaleUtils.scaleSize(
                          (40 * items.length).toDouble(), context),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: ColorConfig.primary2.withOpacity(0.5),
                                blurRadius: ScaleUtils.scaleSize(2, context),
                                offset:
                                    Offset(0, ScaleUtils.scaleSize(1, context)))
                          ],
                          borderRadius: BorderRadius.circular(
                              ScaleUtils.scaleSize(12, context)))),
                  menuItemStyleData: MenuItemStyleData(
                      height: ScaleUtils.scaleSize(35, context),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(16, context))));
            }));
  }
}
