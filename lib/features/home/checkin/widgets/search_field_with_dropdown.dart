import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class SearchFieldWithDropdown extends StatelessWidget {
  const SearchFieldWithDropdown(
      {super.key,
      required this.dropdown,
      required this.controller,
      required this.onChangedTextField,});

  final Widget dropdown;
  final TextEditingController controller;
  final Function(String) onChangedTextField;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(8, context),
            vertical: ScaleUtils.scaleSize(4, context)),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(229, context)),
            border: Border.all(
                color: ColorConfig.border4,
                width: ScaleUtils.scaleSize(1, context)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 4,
                  color: ColorConfig.shadow,
                  offset: const Offset(0, 2))
            ]),
        child: Row(
          children: [
            Image.asset('assets/images/icons/ic_search.png',
                height: ScaleUtils.scaleSize(16, context),
                color: ColorConfig.primary3), // Icon tìm kiếm
            SizedBox(width: ScaleUtils.scaleSize(8, context)),
            Expanded(
              child: TextField(
                cursorColor: Colors.black,
                cursorHeight: ScaleUtils.scaleSize(14, context),
                onChanged: (value) {
                  onChangedTextField(value);
                },
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(14, context),
                    fontFamily: 'Afacad',
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                    isDense: true,
                    hintText: AppText.titleSearch.text,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                        color: ColorConfig.hintText, fontFamily: 'Afacad')),
              ),
            ),
            SizedBox(width: ScaleUtils.scaleSize(8, context)),
            dropdown
          ],
        ),
      ),
    );
  }
}
