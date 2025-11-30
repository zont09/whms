import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/result_working_define.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class DropdownResultWorking extends StatefulWidget {
  final Function(ResultWorkingDefine?)? onChanged;
  final ResultWorkingDefine initItem;
  final List<ResultWorkingDefine> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;
  final bool centerItem;
  final String? icon;
  final bool isShowDropdownIcon;

  const DropdownResultWorking(
      {super.key,
      required this.onChanged,
      required this.initItem,
      required this.options,
      this.fontSize = 12,
      this.maxWidth = 110,
      this.maxHeight = 32,
      this.radius = 50,
      this.borderColor = ColorConfig.border7,
      this.textColor = ColorConfig.textColor,
      this.centerItem = false,
      this.icon,
      this.isShowDropdownIcon = true});

  @override
  DropdownResultWorkingState createState() => DropdownResultWorkingState();
}

class DropdownResultWorkingState extends State<DropdownResultWorking> {
  late ResultWorkingDefine selectedItem;
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
          color: selectedItem.background,
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: widget.borderColor),
          boxShadow: const [ColorConfig.boxShadow2]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) =>
            DropdownButtonFormField2<ResultWorkingDefine>(
          isExpanded: true,
          decoration: InputDecoration(
            constraints: BoxConstraints(
                maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context)),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(0, context)),
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
          // customButton: Row(
          //   children: [
          //     if (selectedItem == ResultWorkingDefine.none)
          //       Image.asset("assets/images/icons/ic_result.png",
          //           height: ScaleUtils.scaleSize(20, context)),
          //     if (selectedItem == ResultWorkingDefine.none) const ZSpace(w: 5),
          //     if (selectedItem == ResultWorkingDefine.none)
          //       Text(
          //         AppText.textResult.text,
          //         style: TextStyle(
          //             fontSize: ScaleUtils.scaleSize(14, context),
          //             fontWeight: FontWeight.w500,
          //             color: ColorConfig.textColor,
          //             letterSpacing: -0.02),
          //       ),
          //     if (selectedItem != ResultWorkingDefine.none)
          //       ResultWorkingCard(
          //         icon: widget.icon,
          //         item: selectedItem,
          //         fontSize: widget.fontSize,
          //         isSelected: true,
          //         radius: widget.radius,
          //         textColor: widget.textColor,
          //         isCenter: widget.centerItem,
          //         isShowDropdownIcon: widget.isShowDropdownIcon,
          //       )
          //   ],
          // ),
          selectedItemBuilder: (context) {
            return widget.options
                .map((item) => ResultWorkingCard(
                      icon: "assets/images/icons/ic_result.png",
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
            return DropdownMenuItem<ResultWorkingDefine>(
              alignment: Alignment.centerRight,
              value: item,
              child: ResultWorkingCard(
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
              horizontal: ScaleUtils.scaleSize(0, context),
            ),
          ),
        ),
      ),
    );
  }
}

class ResultWorkingCard extends StatelessWidget {
  const ResultWorkingCard(
      {super.key,
      required this.item,
      required this.fontSize,
      required this.isSelected,
      required this.radius,
      required this.textColor,
      required this.isCenter,
      required this.icon,
      required this.isShowDropdownIcon});

  final ResultWorkingDefine item;
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
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
            color: item.background,
            // boxShadow: [if (isSelected) ColorConfig.boxShadow],
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: isSelected ? Colors.transparent : ColorConfig.border7)),
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(6, context)),
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
                      Image.asset(
                        icon!,
                        height: ScaleUtils.scaleSize(fontSize, context),
                        color: Colors.white,
                      ),
                    if (icon != null) const ZSpace(w: 3),
                    Text(item.title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(fontSize, context),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.02,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
            if (isSelected && isShowDropdownIcon)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(6, context),
                color: Colors.white,
              )
          ],
        ),
      ),
    );
  }
}
