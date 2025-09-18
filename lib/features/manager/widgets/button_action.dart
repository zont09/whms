import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/manager/screens/profile_screens.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

import '../../../models/response_model.dart';

class ButtonAction extends StatelessWidget {
  const ButtonAction({
    super.key,
    required this.cubit,
    required this.user,
  });

  final ProfileCubit cubit;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final currentUser = ConfigsCubit.fromContext(context).user;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(150, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentUser.id == user?.id)
            ZButton(
                title: AppText.btnLogout.text,
                icon: "",
                paddingHor: 18,
                sizeTitle: 18,
                onPressed: () async {
                  bool isLogout = await DialogUtils.showConfirmDialog(context,
                      AppText.btnLogout.text, AppText.textConfirmLogout.text);
                  if (isLogout == false) return;
                  if (context.mounted) {
                    DialogUtils.showLoadingDialog(context);
                  }
                  if (context.mounted) {
                    await UserServices.instance.logout(context);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                }),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZButton(
                title: AppText.btnResetPassword.text,
                icon: "",
                colorBackground: Colors.white,
                colorTitle: ColorConfig.primary2,
                onPressed: () async {
                  bool isConfirm = await DialogUtils.showConfirmDialog(
                      context,
                      AppText.titleConfirm.text,
                      AppText.textConfirmResetPassword.text);
                  if (isConfirm && context.mounted) {
                    await DialogUtils.handleDialog(context, () async {
                      try {
                        if (user == null) {
                          return ResponseModel(
                              status: ResponseStatus.error,
                              error: ErrorModel(
                                  text: AppText.textNotFoundAccount.text));
                        }
                        ResponseModel<String> respon = await UserServices
                            .instance
                            .resetPassword(user!.email);
                        return respon;
                      } catch (e) {
                        return ResponseModel(
                            status: ResponseStatus.error,
                            error: ErrorModel(text: ". Lỗi: $e"));
                      }
                    }, () {},
                        successMessage:
                            AppText.textResetPasswordSuccess.text + user!.email,
                        successTitle: AppText.titleSuccess.text,
                        failedMessage: AppText.textResetPasswordFailed.text,
                        failedTitle: AppText.titleFailed.text);
                  }
                },
                paddingHor: 18,
                sizeTitle: 18,
              ),
              SizedBox(
                width: ScaleUtils.scaleSize(25, context),
              ),
              ZButton(
                title: AppText.btnEditInformation.text,
                icon: "",
                colorBackground: Colors.white,
                colorTitle: ColorConfig.primary2,
                onPressed: () {
                  cubit.changeEdit(true);
                },
                paddingHor: 18,
                sizeTitle: 18,
              ),
              if (currentUser.roles <= 20)
                SizedBox(
                  width: ScaleUtils.scaleSize(25, context),
                ),
              if (currentUser.roles <= 20)
                ZButton(
                  title: AppText.btnDeleteAccount.text,
                  icon: "",
                  onPressed: () async {
                    bool isConfirm = await DialogUtils.showConfirmDialog(
                        context,
                        AppText.titleConfirmDelete.text,
                        AppText.textConfirmDelete.text);
                    if (isConfirm && context.mounted) {
                      await DialogUtils.handleDialog(context, () async {
                        try {
                          await UserServices.instance
                              .updateUser(user!.copyWith(enable: false));
                          if (context.mounted) {
                            context.go(AppRoutes.managerHome);
                          }
                          return ResponseModel(
                            status: ResponseStatus.ok,
                            results: "",
                          );
                        } catch (e) {
                          return ResponseModel(
                              status: ResponseStatus.error,
                              error: ErrorModel(text: ". Lỗi: $e"));
                        }
                      }, () {},
                          successMessage: AppText.textDeleteSuccess.text,
                          successTitle: AppText.titleDeleteSuccess.text,
                          failedMessage: AppText.textDeleteFailed.text,
                          failedTitle: AppText.titleDeleteFailed.text);
                    }
                  },
                  colorBackground: ColorConfig.error,
                  colorBorder: ColorConfig.error,
                  paddingHor: 18,
                  sizeTitle: 18,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
