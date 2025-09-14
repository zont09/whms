import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/user_model.dart';

class ChooseMembersCubit extends Cubit<int> {
  ChooseMembersCubit(this.users, this.selectedUsers) : super(0) {
    load();
  }

  List<UserModel> users;
  List<UserModel> selectedUsers;

  List<UserModel> listUsers = [];

  load() async {
    for (var u in users) {
      u.isSelected = false;
      for (var s in selectedUsers) {
        if (u.id == s.id) {
          u.isSelected = true;
          break;
        }
      }
    }

    listUsers = users;
    buildUI();
  }

  chooseMember(UserModel user) {
    user.isSelected = !user.isSelected;
    if (user.isSelected) {
      selectedUsers.add(user);
    } else {
      selectedUsers.removeWhere((e) => e.id == user.id);
    }
    buildUI();
  }

  search(String value) {
    if (value.isEmpty) {
      listUsers = users;
    } else {
      listUsers = users
          .where(
              (user) => user.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }

    buildUI();
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
