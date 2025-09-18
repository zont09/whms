import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';

class WorkingRepository {
  WorkingRepository._privateConstructor();

  static WorkingRepository instance = WorkingRepository._privateConstructor();

  FirebaseStorage get fireStorage {
    return FirebaseStorage.instance;
  }

  FirebaseFirestore get db {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  FirebaseStorage get storage => FirebaseStorage.instance;

  // ========= WORKING UNIT =========

  Future<QuerySnapshot<Map<String, dynamic>>> getAllWorkingUnit() async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getAllWorkingUnitIgnoreEnable() async {
    final snapshot = await db.collection("daily_pls_working_unit").get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getAllWorkingUnitIgnoreClosed() async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllTaskInScopeIgnoreClosed(
      String scp) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("type", isEqualTo: TypeAssignmentDefine.task.title)
        .where("scope", arrayContains: scp)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<ResponseModel<List<WorkingUnitModel>>>
  getAllWorkingUnitInScopeByTypeIgnoreClosedUpdated(DateTime date, String scp, String type) async {
    try {
      var query1 = await db
          .collection("daily_pls_working_unit")
          .where("type", isEqualTo: type)
          .where("scope", arrayContains: scp)
          .where("enable", isEqualTo: true)
          .where("updateAt", isGreaterThan: date)
          .get();

      var query2 = await db
          .collection("daily_pls_working_unit")
          .where("type", isEqualTo: type)
          .where("scope", arrayContains: scp)
          .where("enable", isEqualTo: true)
          .where("updateAt", isGreaterThan: date)
          .where("createAt", isGreaterThanOrEqualTo: date)
          .get();
      var combinedDocs = {...query1.docs, ...query2.docs}.toList();

      if (combinedDocs.isEmpty) {
        return ResponseModel(
            status: ResponseStatus.ok,
            results: combinedDocs
                .map((e) => WorkingUnitModel.fromSnapshot(e))
                .toList());
      }
      return ResponseModel(
          status: ResponseStatus.ok,
          results: combinedDocs
              .map((e) => WorkingUnitModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      debugPrint("===> error: ${e}");
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error $e'),
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllEpicInScopeIgnoreClosed(
      String scp) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("type", isEqualTo: TypeAssignmentDefine.epic.title)
        .where("scope", arrayContains: scp)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllTaskFollowing(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("followers", arrayContains: id)
        .where("closed", isEqualTo: false)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  // Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitAfterDate(
  //     DateTime date) async {
  //   final snapshot = await db
  //       .collection("daily_pls_working_unit")
  //       .where("createAt", isGreaterThan: date)
  //       .where("closed", isEqualTo: false)
  //       .where("enable", isEqualTo: true)
  //       .get();
  //   return snapshot;
  // }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitAfterDate(
      DateTime date) async {
    final dateSnapshot = await db
        .collection("daily_pls_working_unit")
        .where("createAt", isGreaterThan: Timestamp.fromDate(date))
        .get();

    if (dateSnapshot.docs.isEmpty) {
      return dateSnapshot;
    }

    final snapshot = dateSnapshot;
    // db
    //     .collection("daily_pls_working_unit")
    //     .where(FieldPath.documentId, whereIn: limitedIds)
    //     .where("enable", isEqualTo: true)
    //     .where("closed", isEqualTo: false)
    //     .get();

    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllWorkingUnitOfUserByClosed(
      String idUser) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("assignees", arrayContains: idUser)
        .where("type", isEqualTo: TypeAssignmentDefine.task.title)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<ResponseModel<List<WorkingUnitModel>>>
      getWorkingUnitClosedForUserUpdated(DateTime date, String idU) async {
    try {
      var query1 = await db
          .collection("daily_pls_working_unit")
          .where('enable', isEqualTo: true)
          .where('closed', isEqualTo: true)
          .where(Filter.or(
              Filter('announces', arrayContains: idU),
              Filter("assignees", arrayContains: idU),
              Filter("followers", arrayContains: idU)))
          .where("updateAt", isGreaterThan: date)
          .get();

      var query2 = await db
          .collection("daily_pls_working_unit")
          .where('enable', isEqualTo: true)
          .where('closed', isEqualTo: true)
          .where(Filter.or(
              Filter('announces', arrayContains: idU),
              Filter("assignees", arrayContains: idU),
              Filter("followers", arrayContains: idU)))
          .where("createAt", isGreaterThanOrEqualTo: date)
          .get();
      var combinedDocs = {...query1.docs, ...query2.docs}.toList();

      if (combinedDocs.isEmpty) {
        return ResponseModel(
            status: ResponseStatus.ok,
            results: combinedDocs
                .map((e) => WorkingUnitModel.fromSnapshot(e))
                .toList());
      }
      return ResponseModel(
          status: ResponseStatus.ok,
          results: combinedDocs
              .map((e) => WorkingUnitModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      debugPrint("===> error: ${e}");
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error $e'),
      );
    }
  }

  Future<ResponseModel<List<WorkingUnitModel>>> getWorkingUnitForUserUpdated(
      DateTime date, String idU) async {
    try {
      // var query3 = await db
      //     .collection("daily_pls_working_unit")
      //     .where('enable', isEqualTo: true)
      //     .where('closed', isEqualTo: false)
      //     .where(Filter.or(
      //         Filter('announces', arrayContains: idU),
      //         Filter("assignees", arrayContains: idU),
      //         Filter("followers", arrayContains: idU)))
      //     .where(Filter.or(Filter("createAt", isGreaterThanOrEqualTo: date),
      //         Filter("updateAt", isGreaterThanOrEqualTo: date)))
      //     .get();

      // var query2 = await db
      //     .collection("daily_pls_working_unit")
      //     .where('enable', isEqualTo: true)
      //     .where('closed', isEqualTo: false)
      // .where(Filter.or(
      //     Filter('announces', arrayContains: idU),
      //     Filter("assignees", arrayContains: idU),
      //     Filter("followers", arrayContains: idU)))
      //     // .where(Filter.or(Filter("createAt", isGreaterThan: date),
      //     // Filter("updateAt", isGreaterThan: date)))
      //     .get();

      var query1 = await db
          .collection("daily_pls_working_unit")
          .where('enable', isEqualTo: true)
          .where('closed', isEqualTo: false)
          .where(Filter.or(
              Filter('announces', arrayContains: idU),
              Filter("assignees", arrayContains: idU),
              Filter("followers", arrayContains: idU)))
          .where("updateAt", isGreaterThan: date)
          .get();

      var query2 = await db
          .collection("daily_pls_working_unit")
          .where('enable', isEqualTo: true)
          .where('closed', isEqualTo: false)
          .where(Filter.or(
              Filter('announces', arrayContains: idU),
              Filter("assignees", arrayContains: idU),
              Filter("followers", arrayContains: idU)))
          .where("createAt", isGreaterThanOrEqualTo: date)
          .get();
      var combinedDocs = {...query1.docs, ...query2.docs}.toList();

      if (combinedDocs.isEmpty) {
        return ResponseModel(
            status: ResponseStatus.ok,
            results: combinedDocs
                .map((e) => WorkingUnitModel.fromSnapshot(e))
                .toList());
      }
      return ResponseModel(
          status: ResponseStatus.ok,
          results: combinedDocs
              .map((e) => WorkingUnitModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      debugPrint("===> error: ${e}");
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error $e'),
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitById(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("id", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByIdIgnoreEnable(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("id", isEqualTo: id)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByIdIgnoreClosed(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("id", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  // Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByScopeId(
  //     String id, {bool isClosed = false}) async {
  //   final snapshot = await db
  //       .collection("daily_pls_working_unit")
  //       .where("scope", arrayContains: id)
  //       .where("enable", isEqualTo: true)
  //       .where("closed", isEqualTo: isClosed)
  //       .get();
  //   return snapshot;
  // }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByScopeId(String id,
      {bool isAll = false}) async {
    Query<Map<String, dynamic>> query = db
        .collection("daily_pls_working_unit")
        .where("scope", arrayContains: id)
        .where("enable", isEqualTo: true);

    if (!isAll) {
      query = query.where("closed", isEqualTo: false);
    }

    final snapshot = await query.get();
    return snapshot;
  }

  Future<ResponseModel<List<WorkingUnitModel>>>
  getWorkingUnitByScopeIdUpdated(DateTime date, String id, {bool isAll = false}) async {
    try {
      Query<Map<String, dynamic>> query1 = db
          .collection("daily_pls_working_unit")
          .where("scope", arrayContains: id)
          .where("enable", isEqualTo: true)
          .where("updateAt", isGreaterThan: date);

      Query<Map<String, dynamic>> query2 = db
          .collection("daily_pls_working_unit")
          .where("scope", arrayContains: id)
          .where("enable", isEqualTo: true)
          .where("createAt", isGreaterThanOrEqualTo: date);
      if (!isAll) {
        query1 = query1.where("closed", isEqualTo: false);
        query2 = query2.where("closed", isEqualTo: false);
      }
      final ssQuery1 = await query1.get();
      final ssQuery2 = await query2.get();
      var combinedDocs = {...ssQuery1.docs, ...ssQuery2.docs}.toList();


      if (combinedDocs.isEmpty) {
        return ResponseModel(
            status: ResponseStatus.ok,
            results: combinedDocs
                .map((e) => WorkingUnitModel.fromSnapshot(e))
                .toList());
      }
      return ResponseModel(
          status: ResponseStatus.ok,
          results: combinedDocs
              .map((e) => WorkingUnitModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      debugPrint("===> error: ${e}");
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error $e'),
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitAsOkrs(
      String okrsGroup, String type) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("okr", arrayContains: okrsGroup)
        .where("type", isEqualTo: type)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSSTByScopeIdIC(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("scope", arrayContains: id)
        .where("type", whereIn: [
          TypeAssignmentDefine.sprint.title,
          TypeAssignmentDefine.story.title,
          TypeAssignmentDefine.task.title,
        ])
        .where("enable", isEqualTo: true)
        // .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByIdUser(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("assignees", arrayContains: id)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getWorkingUnitByIdUserIgnoreClosed(String id) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("assignees", arrayContains: id)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByParent(
      String idPar) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("parent", isEqualTo: idPar)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getWorkingUnitByParentIgnoreClosed(String idPar) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("parent", isEqualTo: idPar)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<ResponseModel<List<WorkingUnitModel>>>
  getWorkingUnitByParentIgnoreClosedUpdated(DateTime date, String id) async {
    try {
      var query1 = await db
          .collection("daily_pls_working_unit")
          .where("parent", isEqualTo: id)
          .where("enable", isEqualTo: true)
          .where("updateAt", isGreaterThan: date)
          .get();

      var query2 = await db
          .collection("daily_pls_working_unit")
          .where("parent", isEqualTo: id)
          .where("enable", isEqualTo: true)
          .where("createAt", isGreaterThanOrEqualTo: date)
          .get();
      var combinedDocs = {...query1.docs, ...query2.docs}.toList();

      if (combinedDocs.isEmpty) {
        return ResponseModel(
            status: ResponseStatus.ok,
            results: combinedDocs
                .map((e) => WorkingUnitModel.fromSnapshot(e))
                .toList());
      }
      return ResponseModel(
          status: ResponseStatus.ok,
          results: combinedDocs
              .map((e) => WorkingUnitModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      debugPrint("===> error: ${e}");
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error $e'),
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkingUnitByScope(
      String idScp) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("scope", arrayContains: idScp)
        .where("enable", isEqualTo: true)
        .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  Future<void> createWorkingUnit(WorkingUnitModel work) async {
    await db
        .collection('daily_pls_working_unit')
        .doc("daily_pls_working_unit_${work.id}")
        .set({
      ...work.toJson(),
      // "createAt": DateTime.now(),
      "version": DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Future<void> updateWorkingUnit(WorkingUnitModel work) async {
  //   await db
  //       .collection('daily_pls_working_unit')
  //       .doc("daily_pls_working_unit_${work.id}")
  //       .set({
  //     ...work.toJson(),
  //     "updateAt": DateTimeUtils.getTimestampNow(),
  //     "updateUser": ConfigsCubit.fromContext(context).user.id
  //   });
  // }

  Future<void> updateWorkingUnitField(
      WorkingUnitModel work, WorkingUnitModel preWork, String idU,
      {bool isGetUpdateTime = true, bool isUpdateAnnounces = false}) async {
    final updateFields = WorkingUnitModel.getDifferentFields(preWork, work);
    var newestWork = await getWorkingUnitByIdIgnoreEnable(work.id);
    Map<String, dynamic> updatedMap = {
      for (var doc in newestWork.docs) ...doc.data()
    };
    List<String> announces = (updatedMap['announces'] ?? []).cast<String>();
    updateFields.forEach((k, v) {
      updatedMap[k] = v;
      if (k == 'assignees' || k == 'followers') {
        announces = {...announces, ...(v as List<String>)}.toList();
      }
    });
    if (!isUpdateAnnounces) {
      updatedMap['announces'] = [...announces];
    }
    bool isUpdateStatus = updateFields.containsKey('status');
    await db
        .collection('daily_pls_working_unit')
        .doc("daily_pls_working_unit_${work.id}")
        .update({
      ...updatedMap,
      if (isGetUpdateTime) "updateAt": Timestamp.now(),
      "version": DateTime.now().millisecondsSinceEpoch,
      "updateUser": idU,
      if (isUpdateStatus) "lastWorkedAt": Timestamp.now(),
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getEpicByScopeIgnoreClosed(
      String idScp) async {
    final snapshot = await db
        .collection("daily_pls_working_unit")
        .where("scope", arrayContains: idScp)
        .where("type", isEqualTo: TypeAssignmentDefine.epic.title)
        .where("enable", isEqualTo: true)
        // .where("closed", isEqualTo: false)
        .get();
    return snapshot;
  }

  // ========= WORK FIELD =========

  Future<QuerySnapshot<Map<String, dynamic>>> getAllWorkField() async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getAllWorkFieldIgnoreEnable() async {
    final snapshot = await db.collection("daily_pls_work_field").get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkFieldById(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("id", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkFieldByWorkShift(
      String workShift) async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("work_shift", isEqualTo: workShift)
        .where('enable', isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkFieldByWorkShiftUpdated(
      String workShift, DateTime date) async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("work_shift", isEqualTo: workShift)
        .where("updateAt", isGreaterThan: date)
        .where('enable', isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkFieldByWorkShiftAndIdQuest(
      String workShift, String task) async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("work_shift", isEqualTo: workShift)
        .where("task_id", isEqualTo: task)
        .where('enable', isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getWorkFieldByWorkShiftAndIdQuestIgnoreEnable(
          String workShift, String task) async {
    final snapshot = await db
        .collection("daily_pls_work_field")
        .where("work_shift", isEqualTo: workShift)
        .where("task_id", isEqualTo: task)
        .get();
    return snapshot;
  }

  Future<void> createWorkField(WorkFieldModel work) async {
    await db
        .collection('daily_pls_work_field')
        .doc("daily_pls_work_field_${work.id}")
        .set(work.toJson());
  }

  Future<void> updateWorkField(WorkFieldModel work) async {
    await db
        .collection('daily_pls_work_field')
        .doc("daily_pls_work_field_${work.id}")
        .update(work.toJson());
  }

  Future<void> updateWorkFieldWithField(
      WorkFieldModel model, WorkFieldModel preModel,
      {bool isGetUpdateTime = true}) async {
    final updateFields = WorkFieldModel.getDifferentFields(preModel, model);
    var newestWork = await getWorkFieldById(model.id);
    Map<String, dynamic> updatedMap = {
      for (var doc in newestWork.docs) ...doc.data()
    };
    updateFields.forEach((k, v) {
      updatedMap[k] = v;
    });
    await db
        .collection('daily_pls_work_field')
        .doc("daily_pls_work_field_${model.id}")
        .update({
      ...updatedMap,
      if (isGetUpdateTime) "updateAt": Timestamp.now(),
    });
  }

  Future<String?> uploadFile(PlatformFile file, String wuId) async {
    try {
      final ref = fireStorage
          .ref()
          .child('working_unit_attachments/$wuId/${file.name}');

      await ref.putData(file.bytes!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading file: $e");
      return null;
    }
  }

  Future<String?> uploadIcon(PlatformFile file, String wuId) async {
    try {
      final ref =
          fireStorage.ref().child('working_unit_icon/$wuId/${file.name}');

      await ref.putData(file.bytes!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading file: $e");
      return null;
    }
  }
}
