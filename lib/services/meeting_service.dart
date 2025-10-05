import 'package:whms/untils/function_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/repositories/meeting_respository.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/toast_utils.dart';

class MeetingService {
  MeetingService._privateConstructor();

  static MeetingService instance = MeetingService._privateConstructor();

  final MeetingRepository _meetingRepository = MeetingRepository.instance;

  // ========================== MEETING ==========================

  // Future<List<MeetingModel>> getAllMeetings() async {
  //   final response = await _meetingRepository.getAllMeetings();
  //   if (response.status == ResponseStatus.ok && response.results != null) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<MeetingModel?> getMeetingById(String id) async {
    final response = await _meetingRepository.getMeetingById(id);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<List<MeetingModel>> getMeetingsForUser(String idU) async {
    final response = await _meetingRepository.getMeetingsForUser(idU);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<List<MeetingModel>> getMeetingsForUserToday(String idU) async {
    final response = await _meetingRepository.getMeetingsForUserToday(idU);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<void> addNewMeeting(MeetingModel model) async {
    await _meetingRepository.addNewMeeting(model);
  }

  Future<void> updateMeeting(MeetingModel model, String idU) async {
    await _meetingRepository.updateMeeting(model, idU);
  }

  Future<void> updateMeetingZ(MeetingModel newM, MeetingModel oldM, String idU,
      BuildContext context) async {
    final cmpRecord = FunctionUtils.compareList<String>(
        newM.minutes, oldM.minutes, (a, b) => false);
    final cmpPreparation = FunctionUtils.compareList<String>(
        newM.preparation, oldM.preparation, (a, b) => false);
    final cmpSection = FunctionUtils.compareList<String>(
        newM.sections, oldM.sections, (a, b) => false);
    final cmpMembers =
    FunctionUtils.compareList(newM.members, oldM.members, (a, b) => false);
    final cmpScopes =
    FunctionUtils.compareList(newM.scopes, oldM.scopes, (a, b) => false);

    final newestModel = await getMeetingById(newM.id);
    debugPrint("=====> get newstModel: ${newestModel?.id} - ${newM.id}");
    if (newestModel == null) {
      ToastUtils.showBottomToast(context, AppText.textHasError.text);
      return;
    }
    List<String> newRecord = [...newestModel.minutes];
    List<String> newPreparation = [...newestModel.preparation];
    List<String> newSection = [...newestModel.sections];
    List<String> newMembers = [...newestModel.members];
    List<String> newScopes = [...newestModel.scopes];

    for (var e in cmpRecord.add) {
      if (newRecord.contains(e)) break;
      newRecord.add(e);
    }
    for (var e in cmpRecord.remove) {
      newRecord.remove(e);
    }

    for (var e in cmpPreparation.add) {
      if (newPreparation.contains(e)) break;
      newPreparation.add(e);
    }
    for (var e in cmpPreparation.remove) {
      newPreparation.remove(e);
    }

    for (var e in cmpSection.add) {
      if (newSection.contains(e)) break;
      newSection.add(e);
    }
    for (var e in cmpSection.remove) {
      newSection.remove(e);
    }

    for (var e in cmpMembers.add) {
      if (newMembers.contains(e)) break;
      newMembers.add(e);
    }
    for (var e in cmpMembers.remove) {
      newMembers.remove(e);
    }

    for (var e in cmpScopes.add) {
      if (newScopes.contains(e)) break;
      newScopes.add(e);
    }
    for (var e in cmpScopes.remove) {
      newScopes.remove(e);
    }

    final updateFields = MeetingModel.getDifferentFields(newM, oldM);
    Map<String, dynamic> updatedMap = {...newestModel.toJson()};
    updateFields.forEach((k, v) {
      updatedMap[k] = v;
    });

    updatedMap["minutes"] = newRecord;
    updatedMap["preparation"] = newPreparation;
    updatedMap["sections"] = newSection;
    updatedMap["members"] = newMembers;
    updatedMap["scopes"] = newScopes;

    debugPrint("====> update meeting fields: ${updatedMap.toString()}");

    await _meetingRepository.updateMeetingZ(newM.id, updatedMap, idU);
  }

  // ========================== MEETING SECTION ==========================

  // Future<List<MeetingSectionModel>> getAllMeetingSections() async {
  //   final response = await _meetingRepository.getAllMeetingSections();
  //   if (response.status == ResponseStatus.ok && response.results != null) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<MeetingSectionModel?> getMeetingSectionById(String id) async {
    final response = await _meetingRepository.getMeetingSectionById(id);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<void> addNewMeetingSection(MeetingSectionModel model) async {
    await _meetingRepository.addNewMeetingSection(model);
  }

  Future<void> updateMeetingSection(
      MeetingSectionModel model, String idU) async {
    await _meetingRepository.updateMeetingSection(model, idU);
  }

  // ========================== MEETING PREPARATION ==========================

  // Future<List<MeetingPreparationModel>> getAllMeetingPreparations() async {
  //   final response = await _meetingRepository.getAllMeetingPreparations();
  //   if (response.status == ResponseStatus.ok && response.results != null) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<MeetingPreparationModel?> getMeetingPreparationById(String id) async {
    final response = await _meetingRepository.getMeetingPreparationById(id);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<void> addNewMeetingPreparation(MeetingPreparationModel model) async {
    await _meetingRepository.addNewMeetingPreparation(model);
  }

  Future<void> updateMeetingPreparation(
      MeetingPreparationModel model, String idU) async {
    await _meetingRepository.updateMeetingPreparation(model, idU);
  }

  // ========================== MEETING RECORD ==========================

  // Future<List<MeetingRecordModel>> getAllMeetingRecords() async {
  //   final response = await _meetingRepository.getAllMeetingRecords();
  //   if (response.status == ResponseStatus.ok && response.results != null) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<MeetingRecordModel?> getMeetingRecordById(String id) async {
    final response = await _meetingRepository.getMeetingRecordById(id);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<void> addNewMeetingRecord(MeetingRecordModel model) async {
    await _meetingRepository.addNewMeetingRecord(model);
  }

  Future<void> updateMeetingRecord(MeetingRecordModel model, String idU) async {
    await _meetingRepository.updateMeetingRecord(model, idU);
  }
}
