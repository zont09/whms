import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({super.key,
    required this.controllerText,
    this.fontSize = 14,
    this.textColor = ColorConfig.textSecondary,
    this.hintText = "",
    this.colorHint = ColorConfig.hintText,
    this.isMultiLine = false,
    this.isObscure = false,
    required this.title,
  required this.isEdit});

  final TextEditingController controllerText;
  final double fontSize;
  final Color textColor;
  final String title;
  final String hintText;
  final Color colorHint;
  final bool isMultiLine;
  final bool isObscure;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    String icon = "account";
    if(title == AppText.titleName.text) {
      icon = "account";
    } else if(title == AppText.titlePhone.text) {
      icon = "phone";
    } else if(title == AppText.titleAddress.text) {
      icon = "address";
    } else if(title == AppText.titleNote.text) {
      icon = "note";
    } else if(title == AppText.titlePrivateNote.text) {
      icon = "note_private";
    } else if(title == AppText.titleIdStaff.text) {
      icon = "code_user";
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/icons/profile_icon/ic_$icon.png',
                height: ScaleUtils.scaleSize(24, context), color: ColorConfig.primary1,),
            const ZSpace(w: 4),
            Text(
              title,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize + 1, context),
                  color: ColorConfig.textSecondary,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        SizedBox(
          height: ScaleUtils.scaleSize(5, context),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: textColor,
              selectionColor: textColor.withOpacity(0.3),
              selectionHandleColor: textColor,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      color: ColorConfig.shadow)
                ]),
            child: TextField(
              enabled: isEdit,
              maxLines: isMultiLine ? null : 1,
              obscureText: isObscure,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize, context),
                  color: textColor),
              controller: controllerText,
              cursorColor: textColor,
              cursorHeight: ScaleUtils.scaleSize(fontSize, context),
              // onChanged: (value) => onChanged(value),
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    vertical: ScaleUtils.scaleSize(15, context),
                    horizontal: ScaleUtils.scaleSize(12, context)),
                hintStyle: TextStyle(
                    fontSize: ScaleUtils.scaleSize(fontSize, context),
                    fontWeight: FontWeight.w300,
                    color: colorHint),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  borderSide: const BorderSide(color: Colors.transparent, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  borderSide: const BorderSide(color: Colors.transparent, width: 0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  borderSide: const BorderSide(color: Colors.transparent, width: 0),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
