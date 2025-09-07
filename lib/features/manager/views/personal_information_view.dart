import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/dropdown_custom.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/date_field_custom.dart';
import 'package:whms/widgets/text_field_custom.dart';

class PersonalInformationView extends StatelessWidget {
  final TextEditingController controllerName;
  final TextEditingController controllerEmail;
  final TextEditingController controllerPhone;
  final TextEditingController controllerAddress;
  final TextEditingController controllerMajor;
  final TextEditingController controllerDate;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final bool isEdit;

  const PersonalInformationView({
    super.key,
    required this.controllerName,
    required this.controllerEmail,
    required this.controllerPhone,
    required this.controllerAddress,
    required this.controllerMajor,
    required this.controllerDate,
    required this.gender,
    required this.onGenderChanged,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: ColorConfig.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(ScaleUtils.scaleSize(30, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppText.textPersonalInformation.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(19, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textSecondary),
                ),
              ],
            ),
            SizedBox(height: ScaleUtils.scaleSize(18, context)),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                      isEdit: isEdit,
                        controllerText: controllerName,
                        title: AppText.titleName.text)),
                SizedBox(width: ScaleUtils.scaleSize(90, context)),
                Expanded(
                    flex: 1,
                    child: DropdownCustom(
                      isEdit: isEdit,
                      options: [
                        AppText.textMale.text,
                        AppText.textFemale.text,
                        AppText.textOther.text
                      ],
                      title: AppText.titleGender.text,
                      onChanged: (value) {
                        onGenderChanged(value!);
                      },
                      defaultValue: gender,
                    )),
              ],
            ),
            SizedBox(height: ScaleUtils.scaleSize(18, context)),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                        isEdit: isEdit,
                        controllerText: controllerPhone,
                        title: AppText.titlePhone.text)),
                SizedBox(width: ScaleUtils.scaleSize(90, context)),
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                        isEdit: isEdit,
                        controllerText: controllerAddress,
                        title: AppText.titleAddress.text)),
              ],
            ),
            SizedBox(height: ScaleUtils.scaleSize(18, context)),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: DateFieldCustom(
                      initialDate: DateTimeUtils.convertToDateTime(controllerDate.text),
                      isEdit: isEdit,
                      title: AppText.titleBirthDay.text,
                      controller: controllerDate,
                    )),
                SizedBox(width: ScaleUtils.scaleSize(90, context)),
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                        isEdit: isEdit,
                        controllerText: controllerMajor,
                        title: AppText.titleMajor.text),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
