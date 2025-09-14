import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/login/widgets/button_login.dart';
import 'package:whms/features/login/widgets/email_field.dart';
import 'package:whms/features/login/widgets/password_field.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/gradient_text.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controllerEmail = TextEditingController();
    final TextEditingController controllerPassword = TextEditingController();
    final FocusNode focusNode = FocusNode();
    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (controllerEmail.text.isEmpty ||
                controllerPassword.text.isEmpty) {
              DialogUtils.showResultDialog(
                  context,
                  AppText.titleLackOfInformation.text,
                  AppText.textFillForm.text,
                  mainColor: ColorConfig.error);
              return;
            }
            bool isLoginSuccess = false;
            await DialogUtils.handleDialog(
              context,
                  () async {
                ResponseModel<UserModel> responUser = await UserServices
                    .instance
                    .login(controllerEmail.text, controllerPassword.text);
                if (responUser.status == ResponseStatus.ok) {
                  isLoginSuccess = true;
                  final user = responUser.results;
                  if (context.mounted) {
                    await ConfigsCubit.fromContext(context)
                        .changUser(user!);
                    if (context.mounted) {
                      await BlocProvider.of<ConfigsCubit>(context)
                          .changRole(user.roles);
                    }
                  }
                }
                return responUser;
              },
                  () {},
              isShowDialogSuccess: false,
              successMessage: AppText.textLoginSuccessful.text,
              successTitle: AppText.textLoginSuccessful.text,
              failedMessage: AppText.textLoginFailed.text,
              failedTitle: AppText.titleFailed.text,
            );
            if (isLoginSuccess) {
              if (context.mounted) {
                ConfigsCubit
                    .fromContext(context)
                    .user
                    .roles <= 20
                    ? context.go(AppRoutes.managerHome)
                    : context.go(AppRoutes.home);
              }
            }
            // if(context.mounted) {
            //   FocusScope.of(context).unfocus();
            // }
          }
        }
      },
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        alignment: Alignment.center,
        color: Colors.white,
        padding:
        EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(40, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/images/logo/pls.png',
            //     height: ScaleUtils.scaleSize(250, context),
            //     width: ScaleUtils.scaleSize(300, context)),
            GradientText(text: 'ĐĂNG NHẬP',
              fontSize: 44,
              fontWeight: FontWeight.w800,
              gradient: ColorConfig.textGradient),
            SizedBox(height: ScaleUtils.scaleSize(20, context)),
            EmailField(controllerEmail: controllerEmail),
            SizedBox(height: ScaleUtils.scaleSize(15, context)),
            PasswordField(controller: controllerPassword),
            SizedBox(height: ScaleUtils.scaleSize(40, context)),
            ButtonLogin(
                title: AppText.btnLogin.text,
                onPressed: () async {
                  if (controllerEmail.text.isEmpty ||
                      controllerPassword.text.isEmpty) {
                    DialogUtils.showResultDialog(
                        context,
                        AppText.titleLackOfInformation.text,
                        AppText.textFillForm.text,
                        mainColor: ColorConfig.error);
                    return;
                  }
                  bool isLoginSuccess = false;
                  await DialogUtils.handleDialog(
                    context,
                        () async {
                      ResponseModel<UserModel> responUser = await UserServices
                          .instance
                          .login(controllerEmail.text, controllerPassword.text);
                      if (responUser.status == ResponseStatus.ok) {
                        isLoginSuccess = true;
                        final user = responUser.results;
                        if (context.mounted) {
                          await ConfigsCubit.fromContext(context)
                              .changUser(user!);
                          if (context.mounted) {
                            await BlocProvider.of<ConfigsCubit>(context)
                                .changRole(user.roles);
                          }
                        }
                      }
                      return responUser;
                    },
                        () {},
                    isShowDialogSuccess: false,
                    successMessage: AppText.textLoginSuccessful.text,
                    successTitle: AppText.textLoginSuccessful.text,
                    failedMessage: AppText.textLoginFailed.text,
                    failedTitle: AppText.titleFailed.text,
                  );
                  if (isLoginSuccess) {
                    if (context.mounted) {
                      final role = ConfigsCubit
                          .fromContext(context)
                          .user
                          .roles;
                      debugPrint("=====> login role: $role");
                      if (role == -229) {
                        context.go(AppRoutes.linktink);
                        return;
                      }
                      role <= 20
                          ? context.go(AppRoutes.managerHome)
                          : context.go(AppRoutes.home);
                    }
                  }
                }),
            SizedBox(
              height: ScaleUtils.scaleSize(50, context),
            )
          ],
        ),
      ),
    );
  }
}
