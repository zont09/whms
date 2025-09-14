import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/convert_utils.dart';
import 'package:whms/untils/dialog_utils.dart';

class ScopeFormCubit extends Cubit<int> {
  ScopeFormCubit() : super(0) {
    init();
  }

  List<ScopeModel> scopes = [];
  List<UserModel> listMember = [];

  final ScopeService _scopeService = ScopeService.instance;
  final UserServices _userService = UserServices.instance;

  init() async {
    addScope(ScopeModel.initial());
    await loadAllUsers();
    buildUI();
  }

  addScope(ScopeModel model) {
    model.memberList.addAll(listMember);
    scopes.add(model);
  }

  updateMembers(ScopeModel model, {bool isCreate = false}) async {
    List<String> members =
        ConvertUtils.convertUserModelToString(model.selectedMembers);

    if (!isCreate) {
      await _scopeService.updateScope(model.copyWith(members: members));
      for (var i in model.members) {
        for (var j in listMember) {
          if (i == j.id) {}
        }
      }
    } else {
      model.members = members;
    }
    // wu.assignees = members;
    buildUI();
  }

  updateManagers(ScopeModel model, {bool isCreate = false}) async {
    List<String> managers =
        ConvertUtils.convertUserModelToString(model.selectedManagers);

    if (!isCreate) {
      await _scopeService.updateScope(model.copyWith(managers: managers));
      for (var i in model.managers) {
        for (var j in listMember) {
          if (i == j.id) {}
        }
      }
    } else {
      model.managers = managers;
    }
    buildUI();
  }

  loadAllUsers() async {
    ResponseModel response = await _scopeService.getUsersForAddingScope(0);

    if (response.status == ResponseStatus.ok) {
      listMember = response.results ?? [];
    }
  }

  createScopes(context) async {
    DialogUtils.showLoadingDialog(context);

    for (var s in scopes) {
      List<String> list =
          s.selectedMembers.fold([], (prev, e) => [...prev, e.id]);
      List<String> listManagers =
          s.selectedManagers.fold([], (prev, e) => [...prev, e.id]);
      s.copyWith(managers: listManagers, members: list);
      await _scopeService.addNewScope(s);
    }
    for (var i in scopes.first.members) {
      for (var j in listMember) {
        if (i == j.id) {
          await _userService
              .updateUser(j.copyWith(scopes: [...j.scopes, scopes.first.id]));
          break;
        }
      }
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
