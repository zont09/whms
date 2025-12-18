import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/dropdown_custom.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/text_field_custom.dart';

class AccountInformationView extends StatelessWidget {
  final TextEditingController controllerEmail;
  final TextEditingController controllerPassword;
  final String role;
  final ValueChanged<String> onRoleChanged;
  final bool isEdit;
  final bool isShowPassword;
  final bool isCreate;

  const AccountInformationView({
    super.key,
    required this.controllerEmail,
    required this.controllerPassword,
    required this.role,
    required this.onRoleChanged,
    required this.isEdit,
    required this.isShowPassword,
    required this.isCreate,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> listRole = [
      AppText.textTasker.text,
      AppText.textHandler.text,
      AppText.textManager.text,
      // if (roleSystem != 0 && roleSystem <= 20) AppText.textTasker.text,
      // if (roleSystem != 0 && roleSystem <= 20) AppText.textHandler.text,
      // if (roleSystem != 0 && roleSystem <= 10) AppText.textSubManager.text,
      // if (roleSystem == 0) AppText.textManager.text,
    ];

    return Material(
        child: Container(
            key: ValueKey(listRole),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: ColorConfig.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(30, context)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppText.titleInternalAccount.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(19, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textSecondary)),
              SizedBox(height: ScaleUtils.scaleSize(18, context)),
              Row(children: [
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                        isEdit: isEdit && isCreate,
                        textColor: ColorConfig.primary2,
                        colorHint: ColorConfig.primary2.withOpacity(0.5),
                        controllerText: controllerEmail,
                        title: AppText.titleEmailLogin.text)),
                // if(isCreate)
                SizedBox(width: ScaleUtils.scaleSize(90, context)),
                // if(isCreate)
                Expanded(
                    flex: 1,
                    child: DropdownCustom(
                      isEdit: isEdit,
                      options: listRole,
                      title: AppText.titleRole.text,
                      onChanged: (value) {
                        onRoleChanged(value!);
                      },
                      textColor: ColorConfig.primary2,
                      defaultValue: role,
                    )),
              ]),
              SizedBox(height: ScaleUtils.scaleSize(18, context)),
              if (isShowPassword)
                Row(children: [
                  Expanded(
                      child: TextFieldCustom(
                          isEdit: isEdit,
                          controllerText: controllerPassword,
                          title: AppText.titlePassword.text,
                          isObscure: true,
                          textColor: ColorConfig.primary2,
                          colorHint: ColorConfig.primary2.withOpacity(0.5))),
                  SizedBox(width: ScaleUtils.scaleSize(90, context)),
                  Expanded(child: Container())
                ])
            ])));
  }
}
