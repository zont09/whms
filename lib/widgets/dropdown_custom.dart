import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class DropdownGeneric<T> extends StatefulWidget {
  final Function(T)? onChanged;
  final T initItem;
  final List<T> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final double itemHeight;
  final Color borderColor;
  final Color textColor;
  final bool centerItem;
  final String? icon;
  final bool isShowDropdownIcon;
  final FocusNode? focusNode;
  final Widget Function(T item, bool isSelected) itemBuilder;

  const DropdownGeneric({
    super.key,
    required this.onChanged,
    required this.initItem,
    required this.options,
    required this.itemBuilder,
    this.fontSize = 12,
    this.maxWidth = 110,
    this.maxHeight = 32,
    this.itemHeight = 32,
    this.radius = 50,
    this.borderColor = ColorConfig.border7,
    this.textColor = ColorConfig.textColor,
    this.centerItem = false,
    this.icon,
    this.isShowDropdownIcon = true,
    this.focusNode
  });

  @override
  DropdownGenericState<T> createState() => DropdownGenericState<T>();
}

class DropdownGenericState<T> extends State<DropdownGeneric<T>> {
  late T selectedItem;
  // ValueNotifier<bool> isOpen = ValueNotifier(false);

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
      //   borderRadius: BorderRadius.circular(
      //     ScaleUtils.scaleSize(widget.radius, context),
      //   ),
      // color: Colors.amber,
      //   border: Border.all(
      //     width: ScaleUtils.scaleSize(1, context),
      //     color: widget.borderColor,
      //   ),
      //   boxShadow: const [ColorConfig.boxShadow2],
      // ),
      child: DropdownButtonFormField2<T>(
        isExpanded: true,
        focusNode: widget.focusNode ?? FocusNode(),
        decoration: InputDecoration(
          constraints: BoxConstraints(
            maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context),
          ),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius / 2),
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius / 2),
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius / 2),
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          height: ScaleUtils.scaleSize(widget.maxHeight, context), // Điều khiển chiều cao khung chứa itemSelected
          padding: EdgeInsets.zero,
        ),
        value: selectedItem,
        selectedItemBuilder: (context) {
          return widget.options
              .map((item) => Container(
              height: ScaleUtils.scaleSize(widget.maxHeight, context),
              child: widget.itemBuilder(item, true)))
              .toList();
        },
        items: widget.options.map((item) {
          return DropdownMenuItem<T>(
            alignment: Alignment.centerRight,
            value: item,
            child: widget.itemBuilder(item, false),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedItem = newValue as T;
          });
          widget.onChanged?.call(newValue as T);
        },
        // onMenuStateChange: (v) => isOpen.value = v,
        iconStyleData: const IconStyleData(
          icon: SizedBox.shrink(),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: ScaleUtils.scaleSize(200, context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ScaleUtils.scaleSize(12, context),
            ),
          ),
          scrollbarTheme: ScrollbarThemeData(
            trackVisibility: WidgetStateProperty.all(false),
            thickness: WidgetStateProperty.all(0),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: ScaleUtils.scaleSize(widget.itemHeight, context),
          padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(4, context),
          ),
        ),
      ),
    );
  }
}
