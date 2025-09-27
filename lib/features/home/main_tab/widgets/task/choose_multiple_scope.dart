import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class ChooseMultipleScope extends StatelessWidget {
  final List<ScopeModel> items;
  final List<ScopeModel> selectedItems;
  final Function() onTap;
  final TextEditingController textEditingController;
  final double height;
  final String title;

  ChooseMultipleScope(
      {required this.items,
      required this.selectedItems,
      required this.onTap,
      this.height = 36,
      required this.title,
      super.key})
      : textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<ScopeModel>> dropdownItems = items
        .map((item) => DropdownMenuItem<ScopeModel>(
            value: item,
            child: DropdownMenuItem(
                value: item,
                enabled: false,
                child: StatefulBuilder(builder: (context, menuSetState) {
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                      onTap: () {
                        isSelected
                            ? selectedItems.remove(item)
                            : selectedItems.add(item);
                        menuSetState(() {});
                        onTap();
                      },
                      child: Container(
                          height: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(16, context)),
                          child: Row(children: [
                            Icon(isSelected
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank),
                            SizedBox(width: ScaleUtils.scaleSize(16, context)),
                            Expanded(
                                child: Text(item.title,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(14, context))))
                          ])));
                }))))
        .toList();
    return SizedBox(
        height: ScaleUtils.scaleSize(height, context),
        child: DropdownButtonHideUnderline(
            child: DropdownButton2<ScopeModel>(
                isExpanded: true,
                iconStyleData: IconStyleData(icon: Container()),
                hint: hintButton(context, title, isHint: true),
                dropdownSearchData: DropdownSearchData(
                    searchController: textEditingController,
                    searchInnerWidgetHeight: ScaleUtils.scaleSize(50, context),
                    searchInnerWidget: Container(
                        height: ScaleUtils.scaleSize(50, context),
                        padding:
                            EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                        child: TextFormField(
                            expands: true,
                            maxLines: null,
                            controller: textEditingController,
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                hintText: AppText.titleSearch.text,
                                hintStyle: TextStyle(
                                    fontSize:
                                        ScaleUtils.scaleSize(12, context)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        ScaleUtils.scaleSize(8, context)))))),
                    searchMatchFn: (item, searchValue) => item.value!.title.toLowerCase().contains(searchValue.toLowerCase())),
                dropdownStyleData: DropdownStyleData(width: ScaleUtils.scaleSize(200, context), maxHeight: ScaleUtils.scaleSize(500, context)),
                items: dropdownItems,
                value: selectedItems.isEmpty ? null : selectedItems.last,
                onChanged: (value) {},
                selectedItemBuilder: (context) => items.map((item) => hintButton(context, title)).toList(),
                buttonStyleData: ButtonStyleData(height: ScaleUtils.scaleSize(36, context)),
                menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(36, context), padding: EdgeInsets.zero))));
  }

  Widget hintButton(context, String title, {bool isHint = false}) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isHint ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(14, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textColor)),
          SizedBox(width: ScaleUtils.scaleSize(10, context)),
          Card(
              margin: EdgeInsets.zero,
              elevation: ScaleUtils.scaleSize(3, context),
              child: CircleAvatar(
                  backgroundColor: ColorConfig.primary3,
                  radius: ScaleUtils.scaleSize(10, context),
                  child: Icon(Icons.add,
                      color: Colors.white,
                      size: ScaleUtils.scaleSize(16, context))))
        ]);
  }
}
