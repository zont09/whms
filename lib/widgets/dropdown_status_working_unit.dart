import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/untils/scale_utils.dart';

class DropdownStatusWorkingUnit extends StatefulWidget {
  final Function(int) onChanged;
  final int initItem;
  final int typeOption;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;

  const DropdownStatusWorkingUnit(
      {super.key,
      required this.onChanged,
      required this.initItem,
      required this.typeOption,
      this.fontSize = 12,
      this.maxWidth = 110,
      this.maxHeight = 32,
      this.radius = 50,
      this.borderColor = ColorConfig.border7,
      this.textColor = ColorConfig.textColor});

  @override
  DropdownStatusWorkingUnitState createState() =>
      DropdownStatusWorkingUnitState();
}

class DropdownStatusWorkingUnitState extends State<DropdownStatusWorkingUnit> {
  late int selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  List<int> options = [];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initItem;
    if (widget.typeOption == 0) {
      options.addAll([-1, 0, 1, 2, 3, 4, 5, 6]);
      for (int i = 1; i <= 3; i++) {
        for (int j = 0; j <= 90; j += 10) {
          options.add(i * 100 + j);
        }
      }
    }
    if (widget.typeOption == 1) {
      options.addAll([-1, 0, 4, 5]);
      for (int i = 1; i <= 1; i++) {
        for (int j = 0; j <= 90; j += 10) {
          options.add(i * 100 + j);
        }
      }
    }
    if (widget.typeOption == 2) {
      options.addAll([-1, 0, 4, 5]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(widget.maxWidth, context),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(ScaleUtils.scaleSize(widget.radius, context)),
        color: StatusWorkingExtension.fromValue(selectedItem).colorBackground,
        // border: Border.all(
        //     width: ScaleUtils.scaleSize(1, context),
        //     color: ColorConfig.border7),
        // boxShadow: const [ColorConfig.boxShadow2]
      ),
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
                .map((item) => StatusCardWU(
                      status: item,
                      fontSize: widget.fontSize,
                      isSelected: true,
                      radius: widget.radius,
                    ))
                .toList();
          },
          items: options.map((item) {
            return DropdownMenuItem<int>(
              alignment: Alignment.centerRight,
              value: item,
              child: StatusCardWU(
                status: item,
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
            widget.onChanged.call(newValue!);
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

class StatusCardWU extends StatelessWidget {
  const StatusCardWU(
      {super.key,
      required this.status,
      required this.fontSize,
      required this.isSelected,
      required this.radius});

  final int status;
  final double fontSize;
  final bool isSelected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    StatusWorkingDefine statusDf = StatusWorkingExtension.fromValue(status);
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
          color: statusDf.colorBackground,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(4, context),
            vertical: ScaleUtils.scaleSize(isSelected ? 0 : 4, context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(statusDf.description,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(fontSize, context),
                        fontWeight: FontWeight.w500,
                        color: statusDf.colorTitle)),
                if (status >= 100 && status < 400)
                  SizedBox(width: ScaleUtils.scaleSize(4, context)),
                if (status >= 100 && status < 400)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(229),
                        color: statusDf.colorTitle),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(4, context),
                        vertical: ScaleUtils.scaleSize(2, context)),
                    child: Text(
                      "${status % 100}%",
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(fontSize - 2, context),
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                // if(isDropdown)
                //   SizedBox(width: ScaleUtils.scaleSize(5, context),),
                // if(isDropdown)
                //   Icon(Icons.arrow_drop_down, size: ScaleUtils.scaleSize(10, context), color: Colors.black,),
              ],
            )),
            if (isSelected)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(4, context),
                color: statusDf.colorTitle,
              )
          ],
        ),
      ),
    );
  }
}
