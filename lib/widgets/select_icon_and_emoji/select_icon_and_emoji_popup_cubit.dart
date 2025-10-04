import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/untils/file_utils.dart';

class SelectIconAndEmojiPopupCubit extends Cubit<int> {
  SelectIconAndEmojiPopupCubit() : super(0);

  List<String> pathIcon = [];
  List<String> pathEmoji = [];

  initData(BuildContext context) async {
    pathIcon.clear();
    pathEmoji.clear();
    final tmp = await FileUtils.getImages(context, "assets/images/icons/task_icon/icon");
    for(var e in tmp) {
      pathIcon.add(e);
    }
    pathEmoji = await FileUtils.getImages(context, "assets/images/icons/task_icon/emoji");
    EMIT();
  }


  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}