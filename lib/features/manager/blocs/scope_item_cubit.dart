import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/convert_utils.dart';

class ScopeItemCubit extends Cubit<int> {
  ScopeItemCubit(ScopeModel model) : super(0) {
    scope = model;
  }
  late ScopeModel scope;

  final ScopeService _scopeService = ScopeService.instance;
  final UserServices _userService = UserServices.instance;

  updateTitle(String txt) async {
    await _scopeService.updateScope(scope.copyWith(title: txt));
    scope.title = txt;
  }

  updateDescription(String txt) async {
    await _scopeService.updateScope(scope.copyWith(description: txt));
    scope.description = txt;
  }

  updateMembers(List<UserModel> users) async {
    List<String> members = ConvertUtils.convertUserModelToString(users);
    List<UserModel> tmp = ConvertUtils.convertStringToUserModel(scope.members);
    List<UserModel> enableMembers =
        tmp.fold([], (prev, e) => [...prev, if (e.enable) e]);
    List<String> enableString =
        ConvertUtils.convertUserModelToString(enableMembers);

    if (enableString.length > members.length) {
      List<String> removedItems = enableString
          .where((item) => !(members.toSet()).contains(item))
          .toList();
      var user = await _userService.getUserById(removedItems.first);
      if(user == null) return;
      var tmp1 = user.scopes;
      tmp1.removeWhere((e) => e == scope.id);
      await _userService.updateUser(user.copyWith(scopes: tmp1));
      var tmp2 = enableString;
      tmp2.removeWhere((e) => e == removedItems.first);
      await _scopeService.updateScope(scope.copyWith(members: tmp2));
    } else {
      await _scopeService.updateScope(scope.copyWith(members: members));
      enableString = members;

      for (var i in users) {
        print('=======> user ${i.name} -- ${i.id}');
        await _userService
            .updateUser(i.copyWith(scopes: {...i.scopes, scope.id}.toList()));
      }
    }

    buildUI();
  }

  updateManagers(List<UserModel> users) async {
    List<String> managers = ConvertUtils.convertUserModelToString(users);
    List<UserModel> tmp = ConvertUtils.convertStringToUserModel(scope.managers);
    List<UserModel> enableMembers =
    tmp.fold([], (prev, e) => [...prev, if (e.enable) e]);
    List<String> enableString =
    ConvertUtils.convertUserModelToString(enableMembers);

    if (enableString.length > managers.length) {
      List<String> removedItems = enableString
          .where((item) => !(managers.toSet()).contains(item))
          .toList();
      var tmp = enableString;
      tmp.removeWhere((e) => e == removedItems.first);
      await _scopeService.updateScope(scope.copyWith(managers: tmp));
    } else {
      await _scopeService.updateScope(scope.copyWith(managers: managers));
      enableString = managers;
    }

    buildUI();
  }

  remove() async {
    await _scopeService.updateScope(scope.copyWith(enable: false));
    buildUI();
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
