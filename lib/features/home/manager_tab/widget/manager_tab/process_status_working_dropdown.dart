import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ProcessStatusWorkingDropdown extends StatefulWidget {
  final int selector;
  final bool isDetail;
  final double size;
  final double height;
  final double paddingHor;
  final double paddingVer;
  final double iconSize;
  final Color colorBackground;
  final Function(int?)? onChanged;

  const ProcessStatusWorkingDropdown(
      {super.key,
      required this.selector,
      this.isDetail = false,
      this.size = 8,
      this.height = 25,
      this.paddingHor = 0,
      this.paddingVer = 3,
      this.iconSize = 24,
      required this.colorBackground,
      required this.onChanged});

  @override
  ProcessStatusWorkingDropdownState createState() =>
      ProcessStatusWorkingDropdownState();
}

class ProcessStatusWorkingDropdownState
    extends State<ProcessStatusWorkingDropdown> {
  late int _selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  List<int> items = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selector;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScaleUtils.scaleSize(25, context),
        decoration: const BoxDecoration(
            color: Colors.transparent, shape: BoxShape.circle),
        child: ValueListenableBuilder<bool>(
            valueListenable: isOpen,
            builder: (context, value, child) => DropdownButtonFormField2<int>(
                isExpanded: true,
                decoration: InputDecoration(
                    constraints: BoxConstraints(
                        maxWidth: ScaleUtils.scaleSize(45, context),
                        maxHeight:
                            ScaleUtils.scaleSize(widget.height, context)),
                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            ScaleUtils.scaleSize(widget.paddingVer, context)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(4, context)),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(4, context)),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(4, context)),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0))),
                value: _selectedItem,
                selectedItemBuilder: (context) {
                  return items.map((item) {
                    return Container(
                      // width: ScaleUtils.scaleSize(20, context),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(
                          //     ScaleUtils.scaleSize(12, context)),
                          color: widget.colorBackground),
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              ScaleUtils.scaleSize(widget.paddingHor, context),
                          vertical:
                              ScaleUtils.scaleSize(widget.paddingVer, context)),
                      child: Text(
                        "$item",
                        style: TextStyle(
                            fontSize:
                                ScaleUtils.scaleSize(widget.size, context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    );
                  }).toList();
                },
                items: items
                    .map((item) => DropdownMenuItem(
                        value: item,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(
                              //     ScaleUtils.scaleSize(12, context)),
                              color: widget.colorBackground),
                          margin: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(4, context),
                              vertical: ScaleUtils.scaleSize(2, context)),
                          child: Text(
                            "$item",
                            style: TextStyle(
                                fontSize:
                                    ScaleUtils.scaleSize(widget.size, context),
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        )))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedItem = newValue!;
                  });
                  widget.onChanged?.call(newValue);
                },
                onMenuStateChange: (v) => isOpen.value = v,
                buttonStyleData:
                    ButtonStyleData(padding: EdgeInsets.only(right: ScaleUtils.scaleSize(0, context))),
                iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
                dropdownStyleData: DropdownStyleData(maxHeight: ScaleUtils.scaleSize(200, context), decoration: BoxDecoration(borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(4, context))), scrollbarTheme: ScrollbarThemeData(thumbVisibility: WidgetStateProperty.all(false))),
                menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(widget.height * 3 / 2, context), padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(widget.paddingHor, context))))));
  }
}
