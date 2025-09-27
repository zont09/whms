import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';

class ListPriorityDropdown extends StatefulWidget {
  const ListPriorityDropdown(
      {super.key,
      required this.selector,
      this.isEdit = true,
      required this.onChanged});

  final bool isEdit;
  final PriorityLevelDefine selector;
  final Function(PriorityLevelDefine?)? onChanged;

  @override
  State<ListPriorityDropdown> createState() => _ListPriorityDropdownState();
}

class _ListPriorityDropdownState extends State<ListPriorityDropdown> {
  late PriorityLevelDefine _selected;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selected = widget.selector;
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
          width: ScaleUtils.scaleSize(130, context),
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  offset: Offset(1, 1),
                  blurRadius: 5.9,
                  spreadRadius: 0,
                ),
              ],
              color: _selected.background,
              borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(1000, context))),
          child: ValueListenableBuilder<bool>(
              valueListenable: isOpen,
              builder: (context, value, child) => DropdownButtonFormField2<
                  PriorityLevelDefine>(
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
                  value: widget.selector,
                  customButton: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(5, context)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/icons/ic_priority.png',
                                  color: _selected.color,
                                  width: ScaleUtils.scaleSize(17, context),
                                  height: ScaleUtils.scaleSize(17, context)),
                              SizedBox(width: ScaleUtils.scaleSize(5, context)),
                              Text(_selected.title,
                                  style: TextStyle(
                                      color: _selected.color,
                                      fontSize: ScaleUtils.scaleSize(12, context),
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                  !isOpen.value
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  color: _selected.color,
                                  size: ScaleUtils.scaleSize(20, context)),
                            ],
                          )
                        ]),
                  ),
                  items: PriorityLevelDefine.values
                      .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.title,
                          style:
                          TextStyle(color: item.color, fontSize: ScaleUtils.scaleSize(12, context), fontWeight: FontWeight.w500))))
                      .toList(),
                  onChanged: widget.isEdit
                      ? (newValue) {
                    setState(() {
                      _selected = newValue!;
                    });
                    widget.onChanged?.call(newValue);
                  }
                      : null,
                  onMenuStateChange: (v) => isOpen.value = v,
                  buttonStyleData: ButtonStyleData(padding: EdgeInsets.only(right: ScaleUtils.scaleSize(4, context))),
                  iconStyleData: IconStyleData(icon: Icon(!isOpen.value ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: _selected.color), iconSize: ScaleUtils.scaleSize(20, context)),
                  dropdownStyleData: DropdownStyleData(maxHeight: ScaleUtils.scaleSize(200, context), decoration: BoxDecoration(borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(12, context)))),
                  menuItemStyleData: MenuItemStyleData(height: ScaleUtils.scaleSize(30, context), padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(16, context)))))),
    );
  }
}
