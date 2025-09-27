import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/sorted_model.dart';

class SortedRepository {
  SortedRepository._privateConstructor();

  static SortedRepository instance = SortedRepository._privateConstructor();

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  FirebaseStorage get fireStorage {
    return FirebaseStorage.instance;
  }

  Future<ResponseModel<SortedModel>> getSortedByUserAndListName(String idUser, String listName) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_sorted")
          .where("user", isEqualTo: idUser)
          .where("list_name", isEqualTo: listName)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => SortedModel.fromSnapshot(e)).firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get sorted by iduser & listName: $idUser $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewSorted(SortedModel model) async {
    try {
      await fireStore
          .collection('whms_pls_sorted')
          .doc("whms_pls_sorted_${model.id}")
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

  Future<ResponseModel<void>> updateSorted(SortedModel model) async {
    try {
      await fireStore
          .collection('whms_pls_sorted')
          .doc("whms_pls_sorted_${model.id}")
          .update(model.toSnapshot());
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
