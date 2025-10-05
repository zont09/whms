import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart' as TextUtils;
import 'package:whms/models/user_model.dart';

class SelectUserCubit extends Cubit<int> {
  SelectUserCubit() : super(0);

  List<UserModel> listUsers = [];
  List<UserModel> listSelected = [];
  List<UserModel> listShow = [];

  final TextEditingController conSearch = TextEditingController();

  initData(List<UserModel> listUrs, List<UserModel> listSel) {
    listUsers.clear();
    listSelected.clear();
    listShow.clear();
    listUsers.addAll(listUrs);
    listSelected.addAll(listSel);
    listShow.addAll(listUrs);
    EMIT();
  }

  changeSearch() {
    if (conSearch.text.isEmpty) {
      listShow.clear();
      listShow.addAll(listUsers);
    } else {
      listShow.clear();
      listShow.addAll(listUsers.where((e) =>
          TextUtils.normalizeString(e.name).contains(
              TextUtils.normalizeString(conSearch.text))).toList());
    }
    EMIT();
  }

  selectScope(UserModel usr) {
    listSelected.add(usr);
    EMIT();
  }

  removeScope(UserModel usr) {
    listSelected.remove(usr);
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}