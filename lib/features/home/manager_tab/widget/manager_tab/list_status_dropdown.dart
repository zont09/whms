import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ListStatusDropdown extends StatefulWidget {
  final int selector;
  final double size;
  final double height;
  final double paddingHor;
  final double paddingVer;
  final double iconSize;
  final double maxWidth;
  final int typeOption; // 1 = phrase 1, 2 = default task, 0 = all
  final Function(int?)? onChanged;
  final bool isPermission;
  final bool isShadow;

  const ListStatusDropdown(
      {super.key,
      required this.selector,
      this.size = 10,
      this.height = 30,
      this.paddingHor = 12,
      this.paddingVer = 5,
      this.iconSize = 24,
      this.maxWidth = 120,
      this.typeOption = 0,
      this.isPermission = false,
      this.isShadow = true,
      required this.onChanged});

  @override
  ListStatusDropdownState createState() => ListStatusDropdownState();
}

class ListStatusDropdownState extends State<ListStatusDropdown> {
  late int _selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  final List<int> items = [];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selector;

    if (widget.typeOption == 0) {
      items.addAll([-1, 0, 1, 2, 3, 4, 5, 6]);
      for (int i = 1; i <= 3; i++) {
        for (int j = 0; j <= 90; j += 10) {
          items.add(i * 100 + j);
        }
      }
    }
    if (widget.typeOption == 1) {
      items.addAll([-1, 0, 4, 5]);
      for (int i = 1; i <= 1; i++) {
        for (int j = 0; j <= 90; j += 10) {
          items.add(i * 100 + j);
        }
      }
    }
    if (widget.typeOption == 2) {
      items.addAll([-1, 0, 4, 5]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.isPermission) {
          ToastUtils.showBottomToast(context, AppText.toastNotEditStatus.text);
        }
      },
      child: Container(
          width: ScaleUtils.scaleSize(widget.maxWidth, context),
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedItem < 0
                      ? const Color(0xFFD7D7D7)
                      : Colors.transparent,
                  width: ScaleUtils.scaleSize(1, context)),
              boxShadow: [
                if(widget.isShadow)
                BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(1, 1),
                    blurRadius: 5.9,
                    spreadRadius: 0)
              ],
              color: _selectedItem < 0
                  ? Colors.white
                  : StatusWorkingExtension.fromValue(_selectedItem)
                      .colorBackground,
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(1000, context))),
          child: ValueListenableBuilder<bool>(
              valueListenable: isOpen,
              builder: (context, value, child) => DropdownButtonFormField2<int>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      constraints: BoxConstraints(
                          maxHeight:
                              ScaleUtils.scaleSize(widget.height, context)),
                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              ScaleUtils.scaleSize(widget.paddingVer, context)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1000),
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 0))),
                  value: items.contains(_selectedItem) ? _selectedItem : null,
                  customButton: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: ScaleUtils.scaleSize(10, context)),
                        if (_selectedItem < -1)
                          Image.asset('assets/images/icons/ic_status.png',
                              scale: 4),
                        if (_selectedItem < -1)
                          SizedBox(width: ScaleUtils.scaleSize(5, context)),
                        Text(
                            _selectedItem < -1
                                ? AppText.titleStatus.text
                                : StatusWorkingExtension.fromValue(
                                        _selectedItem)
                                    .description,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(10, context),
                                fontWeight: FontWeight.w500,
                                color: _selectedItem < 0
                                    ? ColorConfig.textColor
                                    : StatusWorkingExtension.fromValue(
                                            _selectedItem)
                                        .colorTitle)),
                        if (_selectedItem >= 100 && _selectedItem < 400)
                          SizedBox(width: ScaleUtils.scaleSize(4, context)),
                        if (_selectedItem >= 100 && _selectedItem < 400)
                          IntrinsicHeight(
                            child: Container(
                              alignment: Alignment.center,
                              // width: ScaleUtils.scaleSize(15, context),
                              // height: ScaleUtils.scaleSize(15, context),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(229),
                                  color: StatusWorkingExtension.fromValue(
                                          _selectedItem)
                                      .colorTitle),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScaleUtils.scaleSize(4, context),
                                  vertical: ScaleUtils.scaleSize(2, context)),
                              child: Text(
                                "${_selectedItem % 100}%",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(7, context),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                            !isOpen.value
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            color: _selectedItem < 0
                                ? ColorConfig.textColor
                                : StatusWorkingExtension.fromValue(
                                        _selectedItem)
                                    .colorTitle,
                            size: ScaleUtils.scaleSize(20, context)),
                        SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      ]),
                  items: items
                      .map((item) => DropdownMenuItem(
                          value: item,
                          child: StatusCard(
                            status: item,
                            fontSize: widget.size,
                          )))
                      .toList(),
                  onChanged: widget.isPermission
                      ? (newValue) {
                          setState(() {
                            _selectedItem = newValue!;
                          });
                          widget.onChanged?.call(newValue);
                        }
                      : null,
                  onMenuStateChange: (v) => isOpen.value = v,
                  buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.only(
                          right: ScaleUtils.scaleSize(8, context))),
                  iconStyleData: IconStyleData(
                      icon: Icon(!isOpen.value ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                          color: StatusWorkingExtension.fromValue(_selectedItem)
                              .colorTitle),
                      iconSize: ScaleUtils.scaleSize(widget.iconSize, context)),
                  dropdownStyleData: DropdownStyleData(maxHeight: ScaleUtils.scaleSize(200, context), decoration: BoxDecoration(borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(12, context)))),
                  menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(widget.height * 3 / 2, context), padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(widget.paddingHor, context)))))),
    );
  }
}
