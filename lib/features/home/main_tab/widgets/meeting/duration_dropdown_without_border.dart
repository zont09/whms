import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DurationDropdownWithoutBorder extends StatefulWidget {
  final Function(int)? onChanged;
  final int initItem;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;
  final bool centerItem;
  final String? icon;
  final bool isShowDropdownIcon;

  const DurationDropdownWithoutBorder(
      {super.key,
      required this.onChanged,
      required this.initItem,
      this.fontSize = 14,
      this.maxWidth = 110,
      this.maxHeight = 32,
      this.radius = 50,
      this.borderColor = ColorConfig.border7,
      this.textColor = ColorConfig.textColor,
      this.centerItem = false,
      this.icon,
      this.isShowDropdownIcon = true});

  @override
  DropdownStringState createState() => DropdownStringState();
}

class DropdownStringState extends State<DurationDropdownWithoutBorder> {
  late int selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  List<int> options = [
    0,
    5,
    10,
    15,
    20,
    30,
    40,
    50,
    60,
    90,
    120,
    150,
    180,
    210,
    240,
    270,
    300
  ];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(widget.maxWidth, context),
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(
      //         ScaleUtils.scaleSize(widget.radius, context)),
      //     color: Colors.white,
      //     boxShadow: const [ColorConfig.boxShadow2]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) => DropdownButtonFormField2<int>(
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
            return options
                .map((item) => DurationDropdownItem(
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
          items: options.map((item) {
            return DropdownMenuItem<int>(
              alignment: Alignment.centerRight,
              value: item,
              child: DurationDropdownItem(
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
            widget.onChanged?.call(newValue!);
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

class DurationDropdownItem extends StatelessWidget {
  const DurationDropdownItem(
      {super.key,
      required this.item,
      required this.fontSize,
      required this.isSelected,
      required this.radius,
      required this.textColor,
      required this.isCenter,
      required this.icon,
      required this.isShowDropdownIcon});

  final int item;
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
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(4, context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateTimeUtils.formatDuration(item),
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(fontSize, context),
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: -0.02,
                    color: textColor,
                    overflow: TextOverflow.ellipsis)),
            if (isSelected && isShowDropdownIcon)
            const ZSpace(w: 4),
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
