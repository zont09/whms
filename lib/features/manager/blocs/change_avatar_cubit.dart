import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:whms/untils/cache_utils.dart';

class ChangeAvatarCubit extends Cubit<int> {
  ChangeAvatarCubit() : super(0);

  Uint8List? avt;
  PlatformFile? fileSelected;

  bool isHover = false;

  initData(String url) async {
    if(url == "") {
      EMIT();
      return;
    }
    final file = await CacheUtils.instance.getFileGB(url);
    if(file != null) {
      avt = file.bytes;
      fileSelected = file;
    }
    EMIT();
  }

  selectAvatar() async {
    Uint8List? imgData = await ImagePickerWeb
        .getImageAsBytes();
    if (imgData != null) {
      avt = imgData;
    }
    EMIT();
  }

  changeHover(bool v) {
    isHover = v;
    EMIT();
  }

  // uploadAvatar() async {
  //   if (avt != null) {
  //     await UserServices.instance.changeAvatar(
  //         avt!, user!);
  //     if (configCubit.user.id == user!.id) {
  //       await configCubit.changUser(user!
  //           .copyWith(avt: infoCubit.avatar));
  //     }
  //   }
  // }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}