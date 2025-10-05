import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart' as TextUtils;
import 'package:whms/models/scope_model.dart';

class SelectScopeCubit extends Cubit<int> {
  SelectScopeCubit() : super(0);

  List<ScopeModel> listScope = [];
  List<ScopeModel> listSelected = [];
  List<ScopeModel> listShow = [];

  final TextEditingController conSearch = TextEditingController();

  initData(List<ScopeModel> listScp, List<ScopeModel> listSel) {
    listScope.clear();
    listSelected.clear();
    listShow.clear();
    listScope.addAll(listScp);
    listSelected.addAll(listSel);
    listShow.addAll(listScp);
    EMIT();
  }

  changeSearch() {
    if (conSearch.text.isEmpty) {
      listShow.clear();
      listShow.addAll(listScope);
    } else {
      listShow.clear();
      listShow.addAll(listScope.where((e) =>
          TextUtils.normalizeString(e.title).contains(
              TextUtils.normalizeString(conSearch.text))).toList());
    }
    EMIT();
  }

  selectScope(ScopeModel scp) {
    listSelected.add(scp);
    EMIT();
  }

  removeScope(ScopeModel scp) {
    listSelected.remove(scp);
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}