import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/repositories/scope_repository.dart';
import 'package:whms/repositories/user_repository.dart';

class ScopeService {
  ScopeService._privateConstructor();

  static ScopeService instance = ScopeService._privateConstructor();

  final ScopeRepository _scopeRepository = ScopeRepository.instance;
  final UserRepository _userRepository = UserRepository.instance;

  getListScope() {
    return _scopeRepository.getListScope();
  }

  getListScopeOKRs() {
    return _scopeRepository.getListScopeOKRs();
  }

  getScopeById(String id) {
    return _scopeRepository.getScopeById(id);
  }

  Future<List<ScopeModel>> getScopesByOkrsGroup(
      String okrsGroup, String userId) async {
    final response =
        await _scopeRepository.getScopesByOkrsGroup(okrsGroup, userId);
    if (response.status == ResponseStatus.ok &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return response.results!;
    }
    return [];
  }

  Future<List<ScopeModel>> getScopeByIdUser(String idU) async {
    final response = await _scopeRepository.getScopeByIdUser(idU);
    if (response.status == ResponseStatus.ok &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return response.results!;
    }
    return [];
  }

  Future<List<ScopeModel>> getScopeByIdManager(String idU) async {
    final response = await _scopeRepository.getScopeByIdManager(idU);
    if (response.status == ResponseStatus.ok &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return response.results!;
    }
    return [];
  }

  addNewScope(ScopeModel model) {
    return _scopeRepository.addNewScope(model);
  }

  getUsersForAddingScope(int roleId) {
    return _userRepository.getUsersForAddingScope(roleId);
  }

  getUserInfoById(String id) {
    return _userRepository.getUserById(id);
  }

  updateScope(ScopeModel scope) {
    return _scopeRepository.updateScope(scope);
  }
}
