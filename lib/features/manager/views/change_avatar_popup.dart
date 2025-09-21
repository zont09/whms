import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/manager/blocs/change_avatar_cubit.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/z_space.dart';

class ChangeAvatarPopup extends StatelessWidget {
  const ChangeAvatarPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    final configCubit = ConfigsCubit.fromContext(context);
    return BlocProvider(
      create: (context) => ChangeAvatarCubit()..initData(user.avt),
      child: BlocBuilder<ChangeAvatarCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<ChangeAvatarCubit>(c);
          return Container(
            width: ScaleUtils.scaleSize(500, context),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppText.titleChangeAvatar.text.toUpperCase(),
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(24, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textColor6,
                      letterSpacing: -0.41,
                      shadows: const [ColorConfig.textShadow]),
                ),
                // const ZSpace(h: 5),
                Text(AppText.textDescriptionChangeAvatar.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(16, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textColor7,
                        letterSpacing: -0.41,
                        height: 1.5)),
                const ZSpace(h: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          ),
                      child: MouseRegion(
                        onEnter: (_) {
                          cubit.changeHover(true);
                        },
                        onExit: (_) {
                          cubit.changeHover(false);
                        },
                        child: GestureDetector(
                          onTap: () {
                            cubit.selectAvatar();
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: ScaleUtils.scaleSize(1.5, context),
                                        color: ColorConfig.border4)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(229),
                                  child: cubit.avt != null
                                      ? Image.memory(
                                          Uint8List.fromList(cubit.avt!),
                                          height: ScaleUtils.scaleSize(300, context),
                                          width: ScaleUtils.scaleSize(300, context),
                                        )
                                      : Image.asset(
                                          "assets/images/default_avatar.png",
                                          height: ScaleUtils.scaleSize(300, context),
                                          width: ScaleUtils.scaleSize(300, context),
                                          // fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              if (cubit.isHover)
                                Container(
                                  height:
                                  ScaleUtils.scaleSize(302, context),
                                  width:
                                  ScaleUtils.scaleSize(302, context),
                                  decoration: BoxDecoration(
                                      color:
                                      Colors.grey.withOpacity(0.4),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.grey[820],
                                      size: ScaleUtils.scaleSize(
                                          40, context),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const ZSpace(h: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ZButton(
                        title: AppText.btnCancel.text,
                        paddingVer: 4,
                        paddingHor: 12,
                        colorBorder: Colors.white,
                        colorBackground: Colors.white,
                        colorTitle: ColorConfig.primary3,
                        colorIcon: Colors.white,
                        icon: "",
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    const ZSpace(w: 12),
                    ZButton(
                        title: AppText.btnConfirm.text,
                        paddingVer: 4,
                        paddingHor: 12,
                        colorBorder: ColorConfig.primary3,
                        colorBackground: ColorConfig.primary3,
                        colorTitle: Colors.white,
                        colorIcon: Colors.white,
                        icon: "",
                        onPressed: () async {
                          DialogUtils.showLoadingDialog(context);
                          if (cubit.avt != null) {
                            final linkAvt = await UserServices.instance
                                .changeAvatar(cubit.avt!);
                            // debugPrint("====> Link avatar: ${linkAvt}");
                            if (configCubit.user.id == user.id) {
                              configCubit
                                  .changUser(user.copyWith(avt: linkAvt));
                              UserServices.instance.updateUser(user.copyWith(avt: linkAvt));
                            }
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
