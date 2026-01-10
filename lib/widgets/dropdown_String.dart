import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class DropdownString extends StatefulWidget {
  final Function(String?)? onChanged;
  final String initItem;
  final List<String> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;
  final bool centerItem;
  final String? icon;
  final bool isShowDropdownIcon;
  final BoxShadow? shadow;

  const DropdownString(
      {super.key,
      required this.onChanged,
      required this.initItem,
      required this.options,
      this.fontSize = 12,
      this.maxWidth = 140,
      this.maxHeight = 32,
      this.radius = 50,
      this.borderColor = ColorConfig.border7,
      this.textColor = ColorConfig.textColor,
      this.centerItem = false,
      this.icon,
      this.isShowDropdownIcon = true,
      this.shadow = ColorConfig.boxShadow2});

  @override
  DropdownStringState createState() => DropdownStringState();
}

class DropdownStringState extends State<DropdownString> {
  late String selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initItem;
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
          boxShadow: [if (widget.shadow != null) widget.shadow!]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) => DropdownButtonFormField2<String>(
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
          value: selectedItem,
          selectedItemBuilder: (context) {
            return widget.options
                .map((item) => ItemDropdownStringWidget(
                      icon: widget.icon,
                      item: item,
                      fontSize: widget.fontSize,
                      isSelected: true,
                      radius: widget.radius,
                      textColor: widget.textColor,
                      isCenter: widget.centerItem,
                      isShowDropdownIcon: widget.isShowDropdownIcon,
                    ))
                .toList();
          },
          items: widget.options.map((item) {
            return DropdownMenuItem<String>(
              alignment: Alignment.centerRight,
              value: item,
              child: ItemDropdownStringWidget(
                icon: widget.icon,
                item: item,
                fontSize: widget.fontSize,
                isSelected: false,
                radius: widget.radius,
                textColor: widget.textColor,
                isCenter: widget.centerItem,
                isShowDropdownIcon: widget.isShowDropdownIcon,
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
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
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

class ItemDropdownStringWidget extends StatelessWidget {
  const ItemDropdownStringWidget(
      {super.key,
      required this.item,
      required this.fontSize,
      required this.isSelected,
      required this.radius,
      required this.textColor,
      required this.isCenter,
      required this.icon,
      required this.isShowDropdownIcon});

  final String item;
  final double fontSize;
  final bool isSelected;
  final double radius;
  final Color textColor;
  final bool isCenter;
  final String? icon;
  final bool isShowDropdownIcon;

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
                    color: ColorConfig.border7)),
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(4, context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: isSelected || isCenter
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Image.asset(icon!,
                          height: ScaleUtils.scaleSize(fontSize, context)),
                    if (icon != null) const ZSpace(w: 3),
                    Text(item,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(fontSize, context),
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                            letterSpacing: -0.02,
                            color: textColor,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
            if (isSelected && isShowDropdownIcon)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(4, context),
                color: textColor,
              )
          ],
        ),
      ),
    );
  }
}
