
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/main.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';

class ConvertUtils {
  static convertStringToScope(WorkingUnitModel workUnit,
      List<ScopeModel> allScopes, List<ScopeModel> scopes) {
    scopes.clear();
    for (var i in workUnit.scopes) {
      for (var j in allScopes) {
        if (i == j.id) {
          scopes.add(j);
          break;
        }
      }
    }
    return scopes;
  }

  static convertUserModelToString(List<UserModel> users) {
    List<String> members = users.fold([], (prev, e) => [...prev, e.id]);
    return members;
  }

  static convertStringToUserModel(List<String> users) {
    final configs = getIt<ConfigsCubit>();
    List<UserModel> members = configs.usersMap.values
        .where((item) => users.contains(item.id))
        .toList();
    return members;
  }

  static convertScopeToString(List<ScopeModel> models) {
    List<String> okrs = models.fold([], (prev, e) => [...prev, e.id]);
    return okrs;
  }

  static convertStringToScopeOKRs(
      List<ScopeModel> allOKRs, List<String> models) {
    List<ScopeModel> okrs = [];
    for (var i in models) {
      for (var j in allOKRs) {
        if (i == j.id) {
          okrs.add(j);
          break;
        }
      }
    }
    return okrs;
  }
}
