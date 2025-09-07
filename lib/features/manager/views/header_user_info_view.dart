import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/user_info_cubit.dart';
import 'package:whms/features/manager/views/change_avatar_popup.dart';
import 'package:whms/features/manager/views/user_tab.dart';
import 'package:whms/features/manager/widgets/mode_line.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class HeaderUserInfoView extends StatelessWidget {
  const HeaderUserInfoView({
    super.key,
    required this.user,
    required this.isEdit,
    required this.cubit,
  });

  final UserModel? user;
  final bool isEdit;
  final UserTabCubit? cubit;

  @override
  Widget build(BuildContext context) {
    var infoCubit = BlocProvider.of<UserInfoCubit>(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ScaleUtils.scaleSize(50, context)),
      ModeLine(
          isShowIcon: user != null ? false : true,
          title: user != null
              ? (isEdit
                  ? AppText.btnEditInformation.text
                  : AppText.titleUserInformation.text)
              : AppText.textInAddUserMode.text,
          onTap: () => cubit?.changeMode(0)),
      SizedBox(height: ScaleUtils.scaleSize(18, context)),
      BlocProvider(
        create: (context) => AvatarCubit(),
        child: BlocBuilder<AvatarCubit, int>(
          builder: (c, s) {
            var cubitAvt = BlocProvider.of<AvatarCubit>(c);
            return SizedBox(
                width: ScaleUtils.scaleSize(320, context),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: user == null
                        ? [
                            Image.asset('assets/images/icons/ic_add_avatar.png',
                                height: ScaleUtils.scaleSize(86, context)),
                            SizedBox(width: ScaleUtils.scaleSize(9, context)),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Text(AppText.textUploadAvatar.text,
                                      style: TextStyle(
                                          fontSize:
                                              ScaleUtils.scaleSize(18, context),
                                          color: ColorConfig.textSecondary,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                      height: ScaleUtils.scaleSize(5, context)),
                                  Text(AppText.textUploadAvatarDescription.text,
                                      style: TextStyle(
                                          fontSize:
                                              ScaleUtils.scaleSize(12, context),
                                          color: ColorConfig.textTertiary,
                                          fontWeight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2)
                                ]))
                          ]
                        : [
                            MouseRegion(
                              onEnter: (_) {
                                cubitAvt.changeHover(true);
                              },
                              onExit: (_) {
                                cubitAvt.changeHover(false);
                              },
                              child: GestureDetector(
                                  child: Stack(
                                    children: [
                                      AvatarItem(infoCubit.avatar, size: 86),
                                      if (cubitAvt.isHover)
                                        Container(
                                          height:
                                              ScaleUtils.scaleSize(88, context),
                                          width:
                                              ScaleUtils.scaleSize(88, context),
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
                                  onTap: () async {
                                    if (true) {
                                      DialogUtils.showAlertDialog(context,
                                          child: ChangeAvatarPopup());
                                      // Uint8List? imgData = await ImagePickerWeb
                                      //     .getImageAsBytes();
                                      // if (imgData != null) {
                                      //   await infoCubit.changeAvatar(
                                      //       imgData, user!);
                                      //   if (configCubit.user.id == user!.id) {
                                      //     await configCubit.changUser(user!
                                      //         .copyWith(avt: infoCubit.avatar));
                                      //   }
                                      // }
                                    }
                                  }),
                            ),
                            SizedBox(width: ScaleUtils.scaleSize(18, context)),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Text(user!.name,
                                      style: TextStyle(
                                          fontSize:
                                              ScaleUtils.scaleSize(18, context),
                                          color: ColorConfig.textSecondary,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                      height: ScaleUtils.scaleSize(2, context)),
                                  Text(user!.email,
                                      style: TextStyle(
                                          fontSize:
                                              ScaleUtils.scaleSize(15, context),
                                          color: ColorConfig.primary2,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2)
                                ]))
                          ]));
          },
        ),
      ),
      SizedBox(height: ScaleUtils.scaleSize(18, context)),
    ]);
  }
}

class AvatarCubit extends Cubit<int> {
  AvatarCubit() : super(0);

  bool isHover = false;

  changeHover(bool value) {
    isHover = value;
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
