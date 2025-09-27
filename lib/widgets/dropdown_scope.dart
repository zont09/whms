import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class DropdownScope extends StatefulWidget {
  final Function(ScopeModel?)? onChanged;
  final ScopeModel? initTime;
  final List<ScopeModel> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;

  // TO DO
  const DropdownScope(
      {super.key,
      required this.onChanged,
      required this.initTime,
      required this.options,
      this.fontSize = 16,
      this.maxWidth = 80,
      this.maxHeight = 20,
      this.radius = 12,
      this.borderColor = ColorConfig.primary3});

  @override
  DropdownScopeState createState() => DropdownScopeState();
}

class DropdownScopeState extends State<DropdownScope> {
  late ScopeModel? selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(widget.maxWidth, context),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(widget.radius, context)),
          color: Colors.white,
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: widget.borderColor),
          boxShadow: const [ColorConfig.boxShadow]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) =>
            DropdownButtonFormField2<ScopeModel>(
          isExpanded: true,
          decoration: InputDecoration(
            constraints: BoxConstraints(
                maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context)),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(2, context)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
          ),
          hint: Center(
            child: Text(
              AppText.textPleaseChooseScope.text,
              style: TextStyle(
                fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          value: selectedItem,
          selectedItemBuilder: (context) {
            return widget.options
                .map((item) => ItemScopeWidget(
                      item: item,
                      fontSize: widget.fontSize,
                      isSelected: true,
                      radius: widget.radius,
                    ))
                .toList();
          },
          items: widget.options.map((item) {
            return DropdownMenuItem<ScopeModel>(
              alignment: Alignment.centerRight,
              value: item,
              child: ItemScopeWidget(
                item: item,
                fontSize: widget.fontSize,
                isSelected: false,
                radius: widget.radius,
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedItem = newValue!;
            });
            widget.onChanged?.call(newValue);
          },
          onMenuStateChange: (v) => isOpen.value = v,
          iconStyleData: const IconStyleData(
            icon: SizedBox.shrink(),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: ScaleUtils.scaleSize(200, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  ScaleUtils.scaleSize(widget.radius, context)),
            ),
            scrollbarTheme: ScrollbarThemeData(
              trackVisibility: WidgetStateProperty.all(false),
              thickness: WidgetStateProperty.all(0),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: ScaleUtils.scaleSize(32, context),
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(4, context),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemScopeWidget extends StatelessWidget {
  const ItemScopeWidget(
      {super.key,
      required this.item,
      required this.fontSize,
      required this.radius,
      required this.isSelected});

  final ScopeModel item;
  final double fontSize;
  final bool isSelected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: isSelected
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(
                    ScaleUtils.scaleSize(radius, context)),
                color: Colors.white,
                border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.primary3)),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(6, context),
            vertical: ScaleUtils.scaleSize(0, context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.id == AppText.idPersonalIssue.text ||
                        item.id == AppText.idUndeterminedIssue.text)
                      Image.asset(
                          'assets/images/icons/ic_${item.id == AppText.idPersonalIssue.text ? "issue_personal" : "undetermined"}.png',
                          height: ScaleUtils.scaleSize(20, context), color: ColorConfig.primary3,),
                    if (item.id == AppText.idPersonalIssue.text ||
                        item.id == AppText.idUndeterminedIssue.text)
                      SizedBox(width: ScaleUtils.scaleSize(3, context)),
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(fontSize, context),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.41,
                              color: ColorConfig.primary3,
                              shadows: const [ColorConfig.textShadow],
                              overflow: TextOverflow.ellipsis),
                      textAlign: TextAlign.center,),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(6, context),
                color: ColorConfig.primary3,
              )
          ],
        ),
      ),
    );
  }
}
