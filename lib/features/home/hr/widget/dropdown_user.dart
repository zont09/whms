import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class DropdownUser extends StatefulWidget {
  final Function(UserModel?)? onChanged;
  final UserModel initItem;
  final List<UserModel> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;

  const DropdownUser({
    super.key,
    required this.onChanged,
    required this.initItem,
    required this.options,
    this.fontSize = 12,
    this.maxWidth = 110,
    this.maxHeight = 32,
    this.radius = 50,
    this.borderColor = ColorConfig.border7,
    this.textColor = ColorConfig.textColor
  });

  @override
  DropdownUserState createState() => DropdownUserState();
}

class DropdownUserState extends State<DropdownUser> {
  late UserModel selectedItem;
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
              color: ColorConfig.border7),
          boxShadow: const [ColorConfig.boxShadow2]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) =>
            DropdownButtonFormField2<UserModel>(
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
                    .map((item) => ItemWidget(
                  item: item,
                  fontSize: widget.fontSize,
                  isSelected: true,
                  radius: widget.radius,
                  textColor: widget.textColor,
                ))
                    .toList();
              },
              items: widget.options.map((item) {
                return DropdownMenuItem<UserModel>(
                  alignment: Alignment.centerRight,
                  value: item,
                  child: ItemWidget(
                    item: item,
                    fontSize: widget.fontSize,
                    isSelected: false,
                    radius: widget.radius,
                    textColor: widget.textColor,
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
                      ScaleUtils.scaleSize(12, context)),
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

class ItemWidget extends StatelessWidget {
  const ItemWidget(
      {super.key,
        required this.item,
        required this.fontSize,
        required this.isSelected,
        required this.radius,
        required this.textColor});

  final UserModel item;
  final double fontSize;
  final bool isSelected;
  final double radius;
  final Color textColor;

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
        padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(4, context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(item.id.isNotEmpty)
            AvatarItem(item.avt, size: 16),
            if(item.id.isNotEmpty)
            SizedBox(width: ScaleUtils.scaleSize(3, context)),
            Expanded(
              child: Container(
                alignment: isSelected ? Alignment.center : Alignment.centerLeft,
                child: Text(item.name,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(fontSize, context),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        letterSpacing: -0.02,
                        color: textColor,
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            if (isSelected)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(4, context),
                color: ColorConfig.textColor,
              )
          ],
        ),
      ),
    );
  }
}
