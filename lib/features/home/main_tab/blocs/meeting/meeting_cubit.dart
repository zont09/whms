import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/defines/sorted_list_name_define.dart';
import 'package:whms/defines/status_meeting_define.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/services/file_attachment_service.dart';
import 'package:whms/services/meeting_service.dart';
import 'package:whms/services/sorted_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MeetingCubit extends Cubit<int> {
  MeetingCubit(UserModel u, this.context) : super(0) {
    user = u;
  }

  final MeetingService _meetingService = MeetingService.instance;
  final SortedService _sortedService = SortedService.instance;
  final FileAttachmentService _fileAttachmentService =
      FileAttachmentService.instance;

  late UserModel user;
  late BuildContext context;

  MeetingModel meetingSelected = MeetingModel(id: "none");

  List<MeetingModel> listMeeting = [];
  List<MeetingModel> listShow = [];

  int sortTitle = 0;
  int sortTime = 0;

  SortedModel? sortSave;
  List<String> sorted = [];

  Map<String, List<MeetingSectionModel>> mapSection = {};
  Map<String, List<MeetingPreparationModel>> mapPreparation = {};
  Map<String, List<MeetingRecordModel>> mapRecord = {};
  Map<String, FileAttachmentModel> mapFileAttach = {};

  String filterTime = AppText.textThisWeek.text;
  String filterStatus = AppText.textByUnFinished.text;
  final TextEditingController conSearch = TextEditingController();

  initData(String tab, {bool isToday = false}) async {
    listMeeting.clear();
    listShow.clear();

    List<MeetingModel> dataMeetings = isToday
        ? await _meetingService.getMeetingsForUserToday(user.id)
        : await _meetingService.getMeetingsForUser(user.id);

    // List<MeetingModel> dataMeetings =
    //     await _meetingService.getMeetingsForUser(user.id);
    // if (isToday) {
    //   final now = DateTime.now();
    //   dataMeetings =
    //       dataMeetings.where((e) => isSameDate(now, e.time)).toList();
    // }

    debugPrint("=====> Init meeting: ${isToday} - ${dataMeetings.length}");
    // final dataMeetings = await _meetingService.getAllMeetings();

    listMeeting.addAll(dataMeetings);
    List<String> detail = tab.split('id=');
    if (detail.length > 1) {
      String id = detail.last;
      final meetSelected = listMeeting.where((e) => e.id == id).firstOrNull;
      if (meetSelected != null) {
        meetingSelected = meetSelected;
        getDataSection(meetingSelected);
        getDataPreparation(meetingSelected);
        getDataRecord(meetingSelected);
      }
    }
    await sortMeeting();
    updateListShow();
    EMIT();
  }

  sortMeeting() async {
    final sortedFb = await _sortedService.getSortedByUserAndListName(
        user.id, SortedListNameDefine.meeting.title);
    if (sortedFb == null) {
      sorted = listMeeting.map((e) => e.id).toList();
      sortSave = SortedModel(
          id: FirebaseFirestore.instance
              .collection("daily_pls_sorted")
              .doc()
              .id,
          user: user.id,
          listName: SortedListNameDefine.meeting.title,
          sorted: sorted,
          enable: true);
      _sortedService.addNewSorted(sortSave!);
    } else {
      sortSave = sortedFb;
      List<MeetingModel> tmp = [];
      sorted = sortedFb.sorted;
      for (var e in sorted) {
        int index = listMeeting.indexWhere((item) => item.id == e);
        if (index != -1) {
          tmp.add(listMeeting[index]);
        }
      }
      for (var e in listMeeting) {
        if (!tmp.contains(e)) {
          tmp.add(e);
        }
      }
      List<String> newSorted = tmp.map((e) => e.id).toList();
      _sortedService.updateSorted(sortedFb.copyWith(sorted: newSorted));
      sorted = [...newSorted];
      listMeeting = [...tmp];
    }
  }

  updateOrder() {
    List<MeetingModel> tmp = [];
    for (var e in sorted) {
      int index = listShow.indexWhere((i) => i.id == e);
      if (index != -1) {
        tmp.add(listShow[index]);
      }
    }
    for (var e in listShow) {
      if (!tmp.contains(e)) {
        tmp.add(e);
      }
    }
    listShow = [...tmp];
  }

  changeOrder(int index1, int index2) async {
    final tmp = listShow[index1];
    String item = tmp.id;
    listShow.removeAt(index1);
    listShow.insert(index2, tmp);
    if (index2 == 0) {
      sorted.remove(item);
      sorted.insert(0, item);
    } else {
      int index = sorted.indexWhere((e) => e == listShow[index2 - 1].id);
      if (index != -1) {
        sorted.insert(index + 1, item);
        for (int i = 0; i < sorted.length; i++) {
          if (sorted[i] == item && i != index + 1) {
            sorted.removeAt(i);
            break;
          }
        }
      }
    }
    _sortedService.updateSorted(sortSave!.copyWith(sorted: sorted));
    updateListShow();
  }

  selectMeeting(MeetingModel meet) {
    meetingSelected = meet;
    EMIT();
  }

  getDataSection(MeetingModel meet) async {
    if (mapSection.containsKey(meet.id)) {
      EMIT();
      return;
    }
    List<MeetingSectionModel> tmp = [];
    for (var e in meet.sections) {
      final sec = await _meetingService.getMeetingSectionById(e);
      if (sec != null) {
        tmp.add(sec);
        getDataFileAttach(sec.attachments);
      }
    }
    mapSection[meet.id] = [...tmp];
    EMIT();
  }

  getDataPreparation(MeetingModel meet) async {
    if (mapPreparation.containsKey(meet.id)) {
      EMIT();
      return;
    }
    List<MeetingPreparationModel> tmp = [];
    for (var e in meet.preparation) {
      final pre = await _meetingService.getMeetingPreparationById(e);
      if (pre != null) {
        tmp.add(pre);
        getDataFileAttach(pre.attachments);
      }
    }
    mapPreparation[meet.id] = [...tmp];
    EMIT();
  }

  getDataRecord(MeetingModel meet) async {
    debugPrint(
        "====> get data record: ${meet.id} - ${meet.title} - ${mapRecord.containsKey(meet.id)}");
    if (mapRecord.containsKey(meet.id)) {
      EMIT();
      return;
    }
    List<MeetingRecordModel> tmp = [];
    for (var e in meet.minutes) {
      final rec = await _meetingService.getMeetingRecordById(e);
      if (rec != null) {
        tmp.add(rec);
      }
    }
    debugPrint("=====> get data successful: ${tmp.length}");
    mapRecord[meet.id] = [...tmp];
    EMIT();
  }

  getDataFileAttach(List<String> attachments) async {
    for (var e in attachments) {
      if (!mapFileAttach.containsKey(e)) {
        final file = await _fileAttachmentService.getFileAttachmentById(e);
        if (file != null) {
          if (file.type != "link") {
            await CacheUtils.instance.getFileGB(file.source);
          }
          mapFileAttach[e] = file;
        }
      }
    }
    EMIT();
  }

  addMeeting(MeetingModel meet) {
    listMeeting.add(meet);
    updateListShow();
    _meetingService.addNewMeeting(meet);
    EMIT();
  }

  updateMeeting(MeetingModel meet) {
    final index = listMeeting.indexWhere((e) => e.id == meet.id);
    if (index != -1) {
      final oldModel = listMeeting[index].copyWith();
      if (!meet.enable) {
        listMeeting.removeAt(index);
      } else {
        listMeeting[index] = meet;
        debugPrint(
            "=======> Meeting selected: ${meetingSelected.id} - ${meet.id}");
        if (meetingSelected.id == meet.id) {
          meetingSelected = meet;
        }
      }
      updateListShow();
      _meetingService.updateMeetingZ(meet, oldModel, user.id, context);
      // _meetingService.updateMeeting(meet, user.id);
      EMIT();
    }
  }

  updateSection(MeetingSectionModel section, MeetingModel meet) {
    if (section.id.isEmpty) {
      if (section.title.isEmpty &&
          section.description.isEmpty &&
          section.attachments.isEmpty &&
          section.durations == 0 &&
          section.checklist.isEmpty) return;
      addSection(section, meet);
      return;
    }
    final listSec = mapSection[meet.id] ?? [];
    int index = listSec.indexWhere((e) => e.id == section.id);
    if (index != -1) {
      if (!section.enable) {
        listSec.removeAt(index);
      } else {
        listSec[index] = section;
      }
      mapSection[meet.id] = [...listSec];
      _meetingService.updateMeetingSection(section, user.id);
    }
    EMIT();
  }

  addSection(MeetingSectionModel section, MeetingModel meet) {
    if (section.id.isEmpty) {
      section = section.copyWith(
          id: FirebaseFirestore.instance
              .collection("daily_pls_meeting_section")
              .doc()
              .id);
    }
    final listSec = mapSection[meet.id] ?? [];
    listSec.add(section);
    mapSection[meet.id] = [...listSec];
    _meetingService.addNewMeetingSection(section);
    updateMeeting(meet.copyWith(sections: [...meet.sections, section.id]));
    EMIT();
  }

  updatePreparation(MeetingPreparationModel prepare, MeetingModel meet) {
    if (prepare.id.isEmpty) {
      if (prepare.checklist.isEmpty &&
          prepare.attachments.isEmpty &&
          prepare.content.isEmpty &&
          prepare.documents.isEmpty) return;
      addPreparation(prepare, meet);
      return;
    }
    final listPre = mapPreparation[meet.id] ?? [];
    int index = listPre.indexWhere((e) => e.id == prepare.id);
    if (index != -1) {
      if (!prepare.enable) {
        listPre.removeAt(index);
      } else {
        listPre[index] = prepare;
      }
      mapPreparation[meet.id] = [...listPre];
      _meetingService.updateMeetingPreparation(prepare, user.id);
    }
    EMIT();
  }

  addPreparation(MeetingPreparationModel prepare, MeetingModel meet) {
    if (prepare.id.isEmpty) {
      prepare = prepare.copyWith(
          id: FirebaseFirestore.instance
              .collection("daily_pls_meeting_preparation")
              .doc()
              .id);
    }
    final listPre = mapPreparation[meet.id] ?? [];
    listPre.add(prepare);
    mapPreparation[meet.id] = [...listPre];
    _meetingService.addNewMeetingPreparation(prepare);
    updateMeeting(
        meet.copyWith(preparation: [...meet.preparation, prepare.id]));
    EMIT();
  }

  addFileAttachPreparation(MeetingPreparationModel prepare, MeetingModel meet,
      FileAttachmentModel file) {
    updatePreparation(
        prepare.copyWith(attachments: [...prepare.attachments, file.id]), meet);
    mapFileAttach[file.id] = file;
    CacheUtils.instance.getFileGB(file.source);
    EMIT();
  }

  addFileAttachSection(MeetingSectionModel section, MeetingModel meet,
      FileAttachmentModel file) {
    updateSection(
        section.copyWith(attachments: [...section.attachments, file.id]), meet);
    mapFileAttach[file.id] = file;
    CacheUtils.instance.getFileGB(file.source);
    EMIT();
  }

  updateRecord(MeetingRecordModel record, MeetingModel meet) {
    if (record.id.isEmpty) {
      if (record.title.isEmpty && record.content.isEmpty) return;
      addRecord(record, meet);
      return;
    }
    final listPre = mapRecord[meet.id] ?? [];
    int index = listPre.indexWhere((e) => e.id == record.id);
    if (index != -1) {
      if (!record.enable) {
        listPre.removeAt(index);
      } else {
        listPre[index] = record;
      }
      mapRecord[meet.id] = [...listPre];
      _meetingService.updateMeetingRecord(record, user.id);
    }
    EMIT();
  }

  addRecord(MeetingRecordModel record, MeetingModel meet) {
    if (record.id.isEmpty) {
      record = record.copyWith(
          id: FirebaseFirestore.instance
              .collection("daily_pls_meeting_record")
              .doc()
              .id);
    }
    final listPre = mapRecord[meet.id] ?? [];
    listPre.add(record);
    mapRecord[meet.id] = [...listPre];
    _meetingService.addNewMeetingRecord(record);
    updateMeeting(meet.copyWith(minutes: [...meet.minutes, record.id]));
    EMIT();
  }

  List<MeetingModel> updateListFilterTime(List<MeetingModel> listData) {
    if (filterTime == AppText.textAll.text) {
      return listData;
    } else if (filterTime == AppText.titleToday.text) {
      return listData.where((e) => isSameDate(e.time, DateTime.now())).toList();
    } else if (filterTime == AppText.titleThisWeek.text) {
      final week = DateTimeUtils.getStartAndEndOfWeek(0);
      DateTime start = week['start']!;
      DateTime end = week['end']!;
      return listData
          .where((e) =>
              e.time.isAfter(start.subtract(const Duration(microseconds: 1))) &&
              e.time.isBefore(end.add(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
    } else if (filterTime == AppText.textNeedPrepare.text) {
      return listData
          .where((e) =>
              e.status != StatusMeetingDefine.done.title &&
              e.status != StatusMeetingDefine.ended.title &&
              e.reminderTime
                  .isBefore(DateTime.now().add(const Duration(days: 1))))
          .toList();
    } else if (filterTime == AppText.textTomorrow.text) {
      return listData
          .where((e) =>
              isSameDate(e.time, DateTime.now().add(const Duration(days: 1))))
          .toList();
    } else if (filterTime == AppText.textNext3Days.text) {
      DateTime start = DateTimeUtils.getCurrentDate();
      DateTime end = start.add(const Duration(days: 2));
      debugPrint(
          "======> Day start: ${start} - after: ${start.subtract(const Duration(days: 1))}");
      return listData
          .where((e) =>
              e.time.isAfter(start.subtract(const Duration(microseconds: 1))) &&
              e.time.isBefore(end.add(const Duration(days: 1))))
          .toList();
    }
    return [];
  }

  List<MeetingModel> updateFilterStatus(List<MeetingModel> listData) {
    if (filterStatus == AppText.textAll.text) {
      return listData;
    } else if (filterStatus == AppText.textDone.text) {
      return listData
          .where((e) => e.status == StatusMeetingDefine.done.title)
          .toList();
    } else if (filterStatus == AppText.textByUnFinished.text) {
      return listData
          .where((e) => e.status != StatusMeetingDefine.done.title)
          .toList();
    }
    return [];
  }

  List<MeetingModel> updateSearchMeeting(List<MeetingModel> listData) {
    List<MeetingModel> listTmp = [];
    if (conSearch.text.isEmpty || conSearch.text == "") {
      listTmp.addAll(listData);
    } else {
      for (var e in listData) {
        if (FunctionUtils.formatStringVN(e.title)
            .contains(FunctionUtils.formatStringVN(conSearch.text))) {
          listTmp.add(e);
        }
      }
    }
    return listTmp;
  }

  updateListShow() {
    List<MeetingModel> tmp = [];
    tmp.addAll(updateListFilterTime(listMeeting));
    tmp = [...updateFilterStatus(tmp)];
    tmp = [...updateSearchMeeting(tmp)];
    listShow.clear();
    listShow.addAll(tmp);
    if (filterTime != AppText.textThisWeek.text) {
      updateOrder();
    }
    if (sortTitle == 1) {
      listShow.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortTitle == -1) {
      listShow.sort((a, b) => b.title.compareTo(a.title));
    }
    if (sortTime == 1) {
      listShow.sort((a, b) => a.time.compareTo(b.time));
    } else if (sortTime == -1) {
      listShow.sort((a, b) => b.time.compareTo(a.time));
    }
  }

  changeFilter(String newV) {
    filterTime = newV;
    updateListShow();
    EMIT();
  }

  changeFilterStatus(String newV) {
    filterStatus = newV;
    updateListShow();
    EMIT();
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  changeSortTitle() {
    sortTime = 0;
    if (sortTitle == 0) {
      sortTitle = 1;
    } else if (sortTitle == 1) {
      sortTitle = -1;
    } else {
      sortTitle = 0;
    }
    updateListShow();
    EMIT();
  }

  changeSortDeadline() {
    sortTitle = 0;
    if (sortTime == 0) {
      sortTime = 1;
    } else if (sortTime == 1) {
      sortTime = -1;
    } else {
      sortTime = 0;
    }
    updateListShow();
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
