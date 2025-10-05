import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MeetingRepository {
  MeetingRepository._privateConstructor();

  static MeetingRepository instance = MeetingRepository._privateConstructor();

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  FirebaseStorage get fireStorage {
    return FirebaseStorage.instance;
  }

  // =================== MEETING ===================

  Future<ResponseModel<List<MeetingModel>>> getAllMeetings() async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => MeetingModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all meetings $e'),
      );
    }
  }

  Future<ResponseModel<MeetingModel>> getMeetingById(String id) async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get note by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<List<MeetingModel>>> getMeetingsForUser(
      String idU) async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting")
          .where('enable', isEqualTo: true)
          .where(
            Filter.or(
              Filter("owner", isEqualTo: idU),
              Filter("members", arrayContains: idU),
            ),
          )
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => MeetingModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all meetings $e'),
      );
    }
  }

  Future<ResponseModel<List<MeetingModel>>> getMeetingsForUserToday(
      String idU) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await fireStore
          .collection("daily_pls_meeting")
          .where('enable', isEqualTo: true)
          .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('time', isLessThan: Timestamp.fromDate(endOfDay))
          .where(
            Filter.or(
              Filter("owner", isEqualTo: idU),
              Filter("members", arrayContains: idU),
            ),
          )
          .get();

      print("====> get meeting today: ${startOfDay} - ${endOfDay} : ${snapshot.docs}");

      return ResponseModel(
        status: ResponseStatus.ok,
        results:
            snapshot.docs.map((e) => MeetingModel.fromSnapshot(e)).toList(),
      );
    } catch (e) {
      print("=====> error ne hehe: $e");

      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all meetings $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewMeeting(MeetingModel model) async {
    try {
      await fireStore
          .collection('daily_pls_meeting')
          .doc("daily_pls_meeting_${model.id}")
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

  Future<ResponseModel<void>> updateMeeting(
      MeetingModel model, String idU) async {
    try {
      await fireStore
          .collection('daily_pls_meeting')
          .doc("daily_pls_meeting_${model.id}")
          .set({
        ...model.toSnapshot(),
        "updateAt": DateTime.now(),
        "userUpdate": idU
      });
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

  Future<ResponseModel<void>> updateMeetingZ(String id,
      Map<String, dynamic> modelUpdate, String idU) async {
    try {
      await fireStore
          .collection('daily_pls_meeting')
          .doc("daily_pls_meeting_${id}")
          .set({
        ...modelUpdate,
        "updateAt": DateTime.now(),
        "userUpdate": idU
      });
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

  // =================== MEETING SECTION ===================

  Future<ResponseModel<List<MeetingSectionModel>>>
      getAllMeetingSections() async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_section")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingSectionModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error:
            ErrorModel(text: '==========> Error get all meetings section $e'),
      );
    }
  }

  Future<ResponseModel<MeetingSectionModel>> getMeetingSectionById(
      String id) async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_section")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingSectionModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get note by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewMeetingSection(
      MeetingSectionModel model) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_section')
          .doc("daily_pls_meeting_section_${model.id}")
          .set(model.toJson());
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

  Future<ResponseModel<void>> updateMeetingSection(
      MeetingSectionModel model, String idU) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_section')
          .doc("daily_pls_meeting_section_${model.id}")
          .set({
        ...model.toJson(),
        "updateAt": DateTime.now(),
        "userUpdate": idU
      });
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

  // =================== MEETING PREPARATION ===================

  Future<ResponseModel<List<MeetingPreparationModel>>>
      getAllMeetingPreparations() async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_preparation")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingPreparationModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all meetings $e'),
      );
    }
  }

  Future<ResponseModel<MeetingPreparationModel>> getMeetingPreparationById(
      String id) async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_preparation")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingPreparationModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get note by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewMeetingPreparation(
      MeetingPreparationModel model) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_preparation')
          .doc("daily_pls_meeting_preparation_${model.id}")
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

  Future<ResponseModel<void>> updateMeetingPreparation(
      MeetingPreparationModel model, String idU) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_preparation')
          .doc("daily_pls_meeting_preparation_${model.id}")
          .set({
        ...model.toSnapshot(),
        "updateAt": DateTime.now(),
        "userUpdate": idU
      });
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

  // =================== MEETING RECORD ===================

  Future<ResponseModel<List<MeetingRecordModel>>> getAllMeetingRecords() async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_record")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingRecordModel.fromSnapshot(e))
              .toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all meetings $e'),
      );
    }
  }

  Future<ResponseModel<MeetingRecordModel>> getMeetingRecordById(
      String id) async {
    try {
      final snapshot = await fireStore
          .collection("daily_pls_meeting_record")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => MeetingRecordModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get note by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewMeetingRecord(
      MeetingRecordModel model) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_record')
          .doc("daily_pls_meeting_record_${model.id}")
          .set(model.toJson());
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

  Future<ResponseModel<void>> updateMeetingRecord(
      MeetingRecordModel model, String idU) async {
    try {
      await fireStore
          .collection('daily_pls_meeting_record')
          .doc("daily_pls_meeting_record_${model.id}")
          .set({
        ...model.toJson(),
        "updateAt": DateTime.now(),
        "userUpdate": idU
      });
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
