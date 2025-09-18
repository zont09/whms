import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/text_field_custom.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controllerOldPass = TextEditingController();
    final TextEditingController controllerNewPass = TextEditingController();
    final TextEditingController controllerReEnterPass = TextEditingController();
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(  
          child: IntrinsicHeight(
            child: Container(
              width: ScaleUtils.scaleSize(400, context),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        color: ColorConfig.shadow)
                  ],
                  color: Colors.white),
              padding: EdgeInsets.all(
                   ScaleUtils.scaleSize(20, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppText.titleChangePassword.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(30, context),
                        fontWeight: FontWeight.w600,
                        color: ColorConfig.primary1),
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  TextFieldCustom(
                    isEdit: true,
                    controllerText: controllerOldPass,
                    title: AppText.titleOldPassword.text,
                    isObscure: true,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  TextFieldCustom(
                    isEdit: true,
                    controllerText: controllerNewPass,
                    title: AppText.titleNewPassword.text,
                    isObscure: true,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  TextFieldCustom(
                    isEdit: true,
                    controllerText: controllerReEnterPass,
                    title: AppText.titleReEnterPassword.text,
                    isObscure: true,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(30, context)),
                  ZButton(
                    paddingHor: 25,
                      title: AppText.btnChangPassword.text,
                      icon: "",
                      onPressed: () async {
                        bool isSuccess = false;
                        if (controllerOldPass.text.isEmpty ||
                            controllerNewPass.text.isEmpty ||
                            controllerReEnterPass.text.isEmpty) {
                          await DialogUtils.showResultDialog(
                              context,
                              AppText.titleLackOfInformation.text,
                              AppText.textLackOfInformation.text,
                              mainColor: ColorConfig.error);
                          return;
                        }
                        await DialogUtils.handleDialog(context, () async {
                          ResponseModel<bool> checkCurrentPassword =
                              await UserServices.instance
                                  .verifyCurrentPassword(controllerOldPass.text);
                          if (checkCurrentPassword.results == true) {
                            if(controllerNewPass.text != controllerReEnterPass.text) {
                              return ResponseModel(
                                  status: ResponseStatus.error,
                                  error: ErrorModel(
                                      text: AppText.textPasswordNotSame.text
                                  )
                              );
                            }
                            ResponseModel<String> resChangPassword =
                                await UserServices.instance
                                    .changePassword(controllerNewPass.text);

                            if (context.mounted) {
                              final userCurrent =
                                  ConfigsCubit.fromContext(context).user;
                              await UserServices.instance.updateUser(
                                  userCurrent.copyWith(mustChangePassword: false));
                            }
                            isSuccess = true;
                            return resChangPassword;
                          } else {
                            return ResponseModel(
                                status: ResponseStatus.error,
                                error: ErrorModel(
                                  text: AppText.textOldPasswordNotCorrect.text,
                                ));
                          }
                        }, () {},
                            successTitle: AppText.titleChangePasswordSuccess.text,
                            successMessage:
                                AppText.textChangePasswordSuccessful.text,
                            failedTitle: AppText.titleChangePasswordFailed.text,
                            failedMessage: AppText.textChangePasswordFailed.text);
                        if (isSuccess) {
                          if(context.mounted) {
                            await UserServices.instance.logout(context);
                            if(context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          }
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
