import 'package:whms/defines/status_meeting_define.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_status_meeting.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropdownStatusMeeting extends StatefulWidget {
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

  const DropdownStatusMeeting(
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
  DropdownStatusMeetingState createState() => DropdownStatusMeetingState();
}

class DropdownStatusMeetingState extends State<DropdownStatusMeeting> {
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
          color: StatusMeetingExtension.convertToStatus(selectedItem).background,
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: widget.borderColor),
          boxShadow: const [ColorConfig.boxShadow2]),
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
                .map((item) => CardStatusMeeting(
              status: item,
              isSelected: true,
            ))
                .toList();
          },
          items: widget.options.map((item) {
            return DropdownMenuItem<String>(
              alignment: Alignment.centerRight,
              value: item,
              child: CardStatusMeeting(
                status: item,
                isSelected: false,
              )
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
