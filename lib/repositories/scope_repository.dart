import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';

class ScopeRepository {
  ScopeRepository._privateConstructor();

  static ScopeRepository instance = ScopeRepository._privateConstructor();

  // FirebaseFirestore get fireStore => FirebaseFirestore.instance;

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  Future<ResponseModel<List<ScopeModel>>> getListScope() async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScope $e'),
      );
    }
  }

  Future<ResponseModel<List<ScopeModel>>> getListScopeOKRs() async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where('is_okrs', isEqualTo: true)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScopeOKRs $e'),
      );
    }
  }

  Future<ResponseModel<ScopeModel>> getScopeById(String id) async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScope $e'),
      );
    }
  }

  Future<ResponseModel<List<ScopeModel>>> getScopesByOkrsGroup(
      String okrsGroup, String userId) async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where('okrs_group', isEqualTo: okrsGroup)
          .where("members", arrayContains: userId)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getScopesByOkrsGroup $e'),
      );
    }
  }

  Future<ResponseModel<List<ScopeModel>>> getScopeByIdUser(String idU) async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where("members", arrayContains: idU)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScope $e'),
      );
    }
  }

  Future<ResponseModel<List<ScopeModel>>> getScopeByIdManager(
      String idU) async {
    try {
      final snapshot = await fireStore
          .collection("scopes")
          .where("managers", arrayContains: idU)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => ScopeModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScope $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewScope(ScopeModel model) async {
    try {
      await fireStore
          .collection('scopes')
          .doc("scopes_${model.id}")
          .set(model.toSnapshot());
      return ResponseModel(
        status: ResponseStatus.ok,
        results: null,
      );
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: e.toString()),
      );
    }
  }

  Future<ResponseModel<void>> updateScope(ScopeModel scope) async {
    try {
      await fireStore
          .collection('scopes')
          .doc("scopes_${scope.id}")
          .set(scope.toSnapshot());
      return ResponseModel(
        status: ResponseStatus.ok,
        results: null,
      );
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: e.toString()),
      );
    }
  }
}
