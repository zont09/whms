import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/scope_service.dart';

class ChooseScopePopupCubit extends Cubit<int>{
  ChooseScopePopupCubit(this.selectedScopes) : super(0){
    loadAllScope();
  }

  final ScopeService _scopeService = ScopeService.instance;

  late WorkingUnitModel wu;

  List<ScopeModel> scopes = [];
  List<ScopeModel> listScopes = [];
  List<ScopeModel> selectedScopes;

  loadAllScope() async {
    ResponseModel response = await _scopeService.getListScope();
    if (response.status == ResponseStatus.ok) {
      scopes = response.results ?? [];
    }

    for(var scope in scopes){
      for(var s in selectedScopes){
        if(scope.id == s.id){
          scope.isSelected = true;
          break;
        }
      }
    }

    listScopes = scopes;

    buildUI();
  }

  chooseScope(ScopeModel scope) async{
    scope.isSelected = !scope.isSelected;
    if (scope.isSelected) {
      selectedScopes.add(scope);
    } else {
      selectedScopes.removeWhere((e) => e.id == scope.id);
    }
    buildUI();
  }

  search(String value) {
    if(value.isEmpty){
      listScopes = scopes;
    }
    else {
      listScopes = scopes
          .where((scope) => scope.title.toLowerCase().contains(value.toLowerCase()))
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