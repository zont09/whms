import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart' as TextUtils;
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/scope_service.dart';

class ListScopeCubit extends Cubit<int> {
  ListScopeCubit() : super(0);

  List<ScopeModel>? listInit;
  List<ScopeModel> scopes = [];
  List<ScopeModel> scopeParent = [];
  List<ScopeModel> scopeChild = [];
  List<FullScopeEntry> listFull = [];
  List<FullScopeEntry> listShow = [];
  List<UserModel>? listMember;
  final TextEditingController conSearch = TextEditingController();

  final ScopeService _scopeService = ScopeService.instance;

  int currentPage = 1;
  int itemPerPage = 5;
  int maxPage = 0;

  load() async {
    if (listInit != null) {
      emit(0);
      listInit!.clear();
      scopes.clear();
      scopeChild.clear();
      scopeParent.clear();
      listFull.clear();
    }

    ResponseModel response = await _scopeService.getListScope();

    if (response.status == ResponseStatus.ok) {
      listInit = response.results ?? [];
    }

    if (listMember == null) {
      await loadUsers();
    }

    scopeParent = listInit!
        .fold([], (prev, e) => [...prev, if (e.parentScope == '-1') e]);
    scopeChild = listInit!
        .fold([], (prev, e) => [...prev, if (e.parentScope != '-1') e]);

    for (var p in scopeParent) {
      List<ScopeModel> tmp = [];
      for (var c in scopeChild) {
        if (p.id == c.parentScope) {
          tmp.add(c);
        }
      }
      listFull.add(FullScopeEntry(model: p, list: tmp));
    }

    listShow.addAll(listFull);
    currentPage = 1;
    maxPage = (listShow.length / itemPerPage).ceil();

    emit(state + 1);
  }

  onChangeSearch() {
    if (conSearch.text.isEmpty) {
      listShow = [...listFull];
      emit(state + 1);
    }
    listShow = listFull
        .where((e) => TextUtils.normalizeString(e.model.title)
            .contains(TextUtils.normalizeString(conSearch.text)))
        .toList();
    currentPage = 1;
    maxPage = (listShow.length / itemPerPage).ceil();
    emit(state + 1);
  }

  changePage(int v) {
    if(v == currentPage) return;
    currentPage = v;
    emit(state + 1);
  }

  loadUsers() async {
    ResponseModel response = await _scopeService.getUsersForAddingScope(0);
    if (response.status == ResponseStatus.ok) {
      listMember = response.results ?? [];
      final userMap = {for (var user in listMember!) user.id: user};

      for (var scope in listInit!) {
        scope.selectedMembers.addAll(
          scope.members.where(userMap.containsKey).map((id) => userMap[id]!),
        );
        scope.selectedManagers.addAll(
          scope.managers.where(userMap.containsKey).map((id) => userMap[id]!),
        );
      }
    }
  }
}
