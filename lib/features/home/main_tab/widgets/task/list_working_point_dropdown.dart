import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';

class ListWorkingPointDropdown extends StatefulWidget {
  const ListWorkingPointDropdown(
      {super.key,
      required this.selector,
      this.isEdit = true,
      required this.onChanged});

  final int selector;
  final bool isEdit;
  final Function(int?)? onChanged;

  @override
  State<ListWorkingPointDropdown> createState() =>
      _ListWorkingPointDropdownState();
}

class _ListWorkingPointDropdownState extends State<ListWorkingPointDropdown> {
  late int _selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  List<int> items = [...List.generate(100, (index) => index + 1)];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selector;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(!widget.isEdit){
          ToastUtils.showBottomToast(context, AppText.toastNotCreator.text);
        }
      },
      child: Container(
          width: ScaleUtils.scaleSize(_selectedItem < 0 ? 140 : 140, context),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
              horizontal:
              ScaleUtils.scaleSize(_selectedItem < 0 ? 10 : 4, context)),
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(0xFFD7D7D7),
                  width: ScaleUtils.scaleSize(1, context)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(1, 1),
                    blurRadius: 5.9,
                    spreadRadius: 0)
              ],
              color: _selectedItem < 0 ? Colors.white : const Color(0xFFE1EAFF),
              borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(1000, context))),
          child: ValueListenableBuilder<bool>(
              valueListenable: isOpen,
              builder: (context, value, child) => DropdownButtonFormField2<int>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      constraints: BoxConstraints(
                          maxHeight: ScaleUtils.scaleSize(30, context)),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: ScaleUtils.scaleSize(5, context)),
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
                  customButton: Row(children: [
                    _selectedItem < 0
                        ? Image.asset('assets/images/icons/ic_working_unit.png',
                        scale: 4)
                        : CircleAvatar(
                        backgroundColor: const Color(0xFF0F3A9D),
                        radius: ScaleUtils.scaleSize(12, context),
                        child: Text('$_selectedItem',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing:
                                ScaleUtils.scaleSize(-0.02 * 12, context),
                                fontSize: ScaleUtils.scaleSize(12, context),
                                fontWeight: FontWeight.w500))),
                    SizedBox(width: ScaleUtils.scaleSize(5, context)),
                    Expanded(
                      child: Text(
                          _selectedItem < 0
                              ? AppText.txtWorkingPoint.text
                              : AppText.txtPoint.text,
                          style: TextStyle(
                              color: _selectedItem < 0
                                  ? ColorConfig.textColor
                                  : const Color(0xFF0F3A9D),
                              letterSpacing:
                              ScaleUtils.scaleSize(-0.02 * 12, context),
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w500)),
                    ),
                    if (_selectedItem < 0)
                      Icon(
                          !isOpen.value
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          color: ColorConfig.textColor,
                          size: ScaleUtils.scaleSize(20, context))
                  ]),
                  items: items
                      .map((item) => DropdownMenuItem(
                      value: item,
                      child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(16, context),
                              vertical: ScaleUtils.scaleSize(3, context)),
                          padding: EdgeInsets.all(
                              ScaleUtils.scaleSize(5, context)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: const Color(0xFFE1EAFF)),
                          child: Text('$item ${AppText.txtPoint.text}',
                              style: TextStyle(
                                  color: const Color(0xFF0F3A9D),
                                  letterSpacing: ScaleUtils.scaleSize(-0.02 * 12, context),
                                  fontSize: ScaleUtils.scaleSize(10, context),
                                  fontWeight: FontWeight.w500)))))
                      .toList(),
                  onChanged: widget.isEdit
                      ? (newValue) {
                    setState(() {
                      _selectedItem = newValue!;
                    });
                    widget.onChanged?.call(newValue);
                  }
                      : null,
                  onMenuStateChange: (v) => isOpen.value = v,
                  buttonStyleData: ButtonStyleData(padding: EdgeInsets.only(right: ScaleUtils.scaleSize(8, context))),
                  iconStyleData: IconStyleData(icon: Icon(!isOpen.value ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: const Color(0xFF0F3A9D)), iconSize: ScaleUtils.scaleSize(20, context)),
                  dropdownStyleData: DropdownStyleData(maxHeight: ScaleUtils.scaleSize(200, context), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(12, context)))),
                  menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(30, context), padding: EdgeInsets.zero)))),
    );
  }
}
