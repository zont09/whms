import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:whms/features/home/hr/widget/card_data_widget.dart';


class HrTabCubit extends Cubit<int> {
  HrTabCubit(this.cfC) : super(0);

  final WorkingService _workingService = WorkingService.instance;
  int request = 0;
  int requestGetData = 0;
  int loading = 0;

  List<String> listQuarter = [];
  List<CardHRModel> listHRData = [];
  List<WorkingUnitModel> listDataWorkOfUser = [];
  List<WorkHistorySynthetic> listTaskData = [];
  List<WorkingUnitModel> listTaskScope = [];
  Map<WorkingUnitModel, List<WorkHistorySynthetic>> mapTaskDataGroup = {};
  Map<WorkingUnitModel, Map<String, int>> mapTaskSumDataGroup = {};
  Map<WorkingUnitModel, List<WorkingUnitModel>> mapDataWorkOfUserGroup = {};
  Map<WorkingUnitModel, List<WorkingUnitModel>> mapDataTaskScopeGroup = {};
  List<int> quarterSelected = [1, 2025];
  String timeMode = AppText.textByDay.text;
  String scopeSelected = "";
  String userSelected = "";
  String modeViewUser = "";
  String filterStatusTaskAssign = AppText.textByUnFinished.text;
  String userViewMode = AppText.textByScope.text;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  bool isInTaskHr = false;

  late ConfigsCubit cfC;

  List<ScopeModel> listScope = [];

  Map<String, WorkingUnitModel?> mapWorkingUnit = {};

  // Map<String, CardHRModel> mapHRData = {};
  Map<String, UserModel> mapUserModel = {};
  Map<String, WorkShiftModel?> mapWorkShift = {};
  Map<String, List<WorkFieldModel>> mapWFfWS = {};
  Map<String, List<UserModel>> mapUserInScope = {};

  // Map<String, List<HrTaskModel>> mapHrTask = {};
  Map<String, List<WorkingUnitModel>> mapAddress = {};
  Map<String, List<WorkingUnitModel>> workOfUser = {};
  Map<String, List<WorkingUnitModel>> mapTaskChild = {};

  // Map<String, List<WorkHistorySynthetic>> mapWorkSynthetic = {};
  Map<String, List<WorkHistorySynthetic>> mapTaskWorkSynChild = {};
  Map<String, List<WorkingUnitModel>> mapTaskInScope = {};
  Map<String, List<WorkingUnitModel>> mapEpicInScope = {};

  Map<String, WorkingUnitModel> mapAncestor = {};

  Map<String, DateTime> taskWorkDateMap = {}; // Map lưu ngày làm việc của task

  Map<String, int> mapWorkChild = {};

  initData(
      BuildContext ctx, DateTime start, DateTime end, String? userSlt) async {
    emit(0);
    int currentRequest = ++request;
    filterEpicTV = allEpic;
    filterUserTV = userAll;
    final user = ConfigsCubit.fromContext(ctx).user;
    final resScp = cfC.allScopes.where((e) => e.managers.contains(user.id));
    // await _scopeService.getScopeByIdManager(user.id);
    listScope.clear();
    listScope.addAll(resScp);
    mapWorkingUnit.addAll(cfC.mapWorkingUnit);
    mapUserModel.addAll(cfC.usersMap);
    userSelected = userSlt ?? "";
    // mapWorkShift.addAll(cfC.mapWorkShift);
    mapWFfWS.addAll(cfC.mapWFfWS);
    mapTaskChild.addAll(cfC.mapWorkChild);
    for (var e in listScope) {
      mapTaskInScope[e.id] = [
        ...cfC.allWorkingUnit.where((f) =>
        f.scopes.contains(e) && f.type == TypeAssignmentDefine.task.title)
      ];
      mapEpicInScope[e.id] = [
        ...cfC.allWorkingUnit.where((f) =>
        f.scopes.contains(e) && f.type == TypeAssignmentDefine.epic.title)
      ];
      mapUserInScope[e.id] = [
        ...cfC.allUsers.where((f) => f.scopes.contains(e.id))
      ];
    }

    for (var scp in listScope) {
      if (!mapUserInScope.containsKey(scp.id)) {
        final userInScope =
        cfC.allUsers.where((e) => e.scopes.contains(scp.id));
        mapUserInScope[scp.id] = [...userInScope];
        for (var u in userInScope) {
          if (!mapUserModel.containsKey(u.id)) {
            mapUserModel[u.id] = u;
          }
        }
      }
    }

    if (currentRequest != request) return;
    // final quarter = DateTimeUtils.getQuartersFromYear(2022);
    // listQuarter.clear();
    // listQuarter.addAll(
    //     quarter.map((item) => "Quý ${item['quarter']} ${item['year']}"));
    //
    // quarterSelected.clear();
    // quarterSelected.add(quarter.last['quarter'] ?? 1);
    // quarterSelected.add(quarter.last['year'] ?? 2025);

    startTime = start;
    endTime = end;
    // modeViewUser = AppText.titleWorkHistory.text;
    modeViewUser = AppText.titleWorkHistory.text;

    if (currentRequest != request) return;
    await loadDataForTable(startTime, endTime);
    await getEpic();
    EMIT();
  }

  updateWorkShift(WorkShiftModel ws) {
    mapWorkShift[ws.id] = ws;
    EMIT();
  }

  updateWorkField(WorkFieldModel wf) {
    updateMapList(mapWFfWS, wf);
    EMIT();
  }

  updateWorkingUnit(WorkingUnitModel model) {
    if (model.enable) {
      mapWorkingUnit[model.id] = model;
      mapAncestor[model.id] = model;
      updateMapList(mapAddress, model);
      updateMapList(workOfUser, model);
      updateMapList(mapTaskChild, model);
      updateMapList(mapTaskInScope, model);
      updateMapList(mapEpicInScope, model);
    } else {
      mapWorkingUnit.remove(model.id);
      mapAncestor[model.id] = model;
      updateMapList(mapAddress, model);
      updateMapList(workOfUser, model);
      updateMapList(mapTaskChild, model);
      updateMapList(mapTaskInScope, model);
      updateMapList(mapEpicInScope, model);
    }
    EMIT();
  }

  void updateMapList(Map<String, List<dynamic>> map, dynamic model) {
    map.forEach((key, list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == model.id) {
          if (model.enable) {
            list[i] = model;
          } else {
            list.removeAt(i);
          }
          break;
        }
      }
    });
  }

  loadDataForTable(DateTime start, DateTime end) async {
    listHRData.clear();
    listTaskData.clear();

    if (userSelected.isNotEmpty &&
        modeViewUser != AppText.titleWorkHistory.text) {
      await loadDataForUser();
      return;
    }

    if (timeMode == AppText.textSynthetic.text) {
      await loadDataTaskTable();
      return;
    }

    int currentRequest = ++request;
    loading++;
    EMIT();

    print('========== LOAD DATA TABLE ==========');
    print('timeMode: $timeMode');
    print('scopeSelected: ${scopeSelected.isEmpty ? "ALL" : scopeSelected}');
    print('userSelected: ${userSelected.isEmpty ? "ALL" : userSelected}');
    print('startTime: ${DateTimeUtils.formatDateDayMonthYear(start)}');
    print('endTime: ${DateTimeUtils.formatDateDayMonthYear(end)}');
    print('=====================================');

    if (timeMode == AppText.textByDay.text || timeMode == "Timeline") {
      for (DateTime date = start;
      date.isBefore(end.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))) {
        final data = await getDataByDate(date);
        if (currentRequest != request) {
          loading--;
          EMIT();
          return;
        }
        if (data.logtime > 0 || userSelected.isNotEmpty) {
          listHRData.add(data);
          print('📅 ${DateTimeUtils.formatDateDayMonthYear(date)}: ${data.details.length} tasks, logtime: ${data.logtime} minutes');
          EMIT();
        }
      }
      print('✅ FINISHED loading - Total days with data: ${listHRData.length}');
    } else if (timeMode == AppText.textByWeek.text) {
      listHRData.clear();
      int cnt = 0;
      for (DateTime date = start;
      date.isBefore(end.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 7))) {
        DateTime st = DateTimeUtils.getStartOfThisWeek(date);
        DateTime en = st.add(const Duration(days: 6));

        if (st.isBefore(start)) {
          st = start;
        }

        if (en.isAfter(end)) {
          en = end;
        }

        final data = await getDataByWeek(++cnt, st, en);
        if (currentRequest != request) {
          loading--;
          EMIT();
          return;
        }
        if (data.logtime > 0 || userSelected.isNotEmpty) {
          listHRData.add(data);
          EMIT();
        }
      }
    } else if (timeMode == AppText.textByMonth.text) {
      for (DateTime date = DateTime(start.year, start.month);
      date.isBefore(DateTime(end.year, end.month + 1));
      date = DateTime(date.year, date.month + 1)) {
        final data = await getDataByMonth(date);
        if (currentRequest != request) {
          loading--;
          EMIT();
          return;
        }
        if (data.logtime > 0 || userSelected.isNotEmpty) {
          listHRData.add(data);
          EMIT();
        }
      }
    }
    loading--;
    EMIT();
  }

  Future<CardHRModel> getDataByMonth(DateTime inputDate) async {
    int workingTime = 0;
    int workingPoint = 0;
    int logTime = 0;
    int cntTask = 0;

    // if (mapHRData.containsKey(
    //     "Tháng ${inputDate.month}/${inputDate.year} - $scopeSelected - $userSelected")) {
    //   return mapHRData[
    //       "Tháng ${inputDate.month}/${inputDate.year} - $scopeSelected - $userSelected"]!;
    // }

    List<HrTaskModel> listTmp = [];

    for (DateTime date = DateTime(inputDate.year, inputDate.month, 1);
    date.isBefore(DateTime(inputDate.year, inputDate.month + 1, 1));
    date = date.add(const Duration(days: 1))) {
      final data = await getDataByDate(date);
      workingTime += data.workingTime;
      workingPoint += data.workingPoint;
      logTime += data.logtime;
      cntTask += data.taskOther;
      for (var tmp in data.details) {
        int index = listTmp.indexWhere((item) => item.task.id == tmp.task.id);
        if (index != -1) {
          int tmp2 = listTmp[index].workingTime + tmp.workingTime;
          listTmp[index] =
              HrTaskModel(task: tmp.task, workingTime: tmp2, users: tmp.users);
        } else {
          listTmp.add(tmp);
        }
      }
    }

    CardHRModel newData = CardHRModel(
        date: inputDate,
        dateStr: "Tháng ${inputDate.month}/${inputDate.year}",
        logtime: logTime,
        workingTime: workingTime,
        workingPoint: workingPoint,
        taskOther: cntTask,
        details: listTmp);
    // mapHRData[
    //         "Tháng ${inputDate.month}/${inputDate.year} - $scopeSelected - $userSelected"] =
    //     newData;
    return newData;
  }

  Future<CardHRModel> getDataByWeek(
      int cnt, DateTime start, DateTime end) async {
    int workingTime = 0;
    int workingPoint = 0;
    int logTime = 0;
    int cntTask = 0;

    // if (mapHRData.containsKey(
    //     "Tuần $cnt | ${start.day}/${start.month} - ${end.day}/${end.month} - $scopeSelected - $userSelected")) {
    //   return mapHRData[
    //       "Tuần $cnt | ${start.day}/${start.month} - ${end.day}/${end.month} - $scopeSelected - $userSelected"]!;
    // }

    // DateTime start = DateTimeUtils.getStartOfThisWeek(inputDate);
    // DateTime end = DateTimeUtils.getStartOfThisWeek(inputDate).add(
    //     const Duration(days: 6));

    List<HrTaskModel> listTmp = [];

    for (DateTime date = start;
    date.isBefore(end.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {
      final data = await getDataByDate(date);
      workingTime += data.workingTime;
      workingPoint += data.workingPoint;
      logTime += data.logtime;
      cntTask += data.taskOther;
      for (var tmp in data.details) {
        int index = listTmp.indexWhere((item) => item.task.id == tmp.task.id);
        if (index != -1) {
          int tmp2 = listTmp[index].workingTime + tmp.workingTime;
          listTmp[index] =
              HrTaskModel(task: tmp.task, workingTime: tmp2, users: tmp.users);
        } else {
          listTmp.add(tmp);
        }
      }
    }

    CardHRModel newData = CardHRModel(
        date: start,
        dateStr:
        "Tuần $cnt | ${start.day}/${start.month} - ${end.day}/${end.month}",
        logtime: logTime,
        workingTime: workingTime,
        workingPoint: workingPoint,
        taskOther: cntTask,
        details: listTmp);
    // mapHRData[
    //         "Tuần $cnt | ${start.day}/${start.month} - ${end.day}/${end.month} - $scopeSelected - $userSelected"] =
    //     newData;
    return newData;
  }

  Future<CardHRModel> getDataByDate(DateTime date) async {
    int curReq = ++requestGetData;

    int workingTime = 0;
    int workingPoint = 0;
    int logTime = 0;
    int cntTask = 0;

    Map<String, int> ddTask = {};
    Map<String, int> statusTask = {};
    Map<String, int> wpTask = {};

    // if (mapHRData.containsKey(
    //     "${DateTimeUtils.formatDateDayMonthYear(date)} - $scopeSelected - $userSelected - $userViewMode")) {
    //   return mapHRData[
    //       "${DateTimeUtils.formatDateDayMonthYear(date)} - $scopeSelected - $userSelected - $userViewMode"]!;
    // }

    mapTaskChild.addAll(cfC.mapWorkChild);

    List<UserModel> users = [];
    if (userSelected.isNotEmpty) {
      users.add(cfC.usersMap[userSelected]!);
    } else {
      users.addAll(mapUserInScope[scopeSelected] ?? []);
    }

    if (curReq != requestGetData) return CardHRModel();

    int statusCheckIn = 0;
    Timestamp checkIn = Timestamp.now();
    Timestamp checkOut = Timestamp.now();

    List<WorkFieldModel> listWFF = [];

    for (var user in users) {
      WorkShiftModel? ws;
      // = getData(mapWorkShift, "${user.id}_${date}", _userServices.getWorkShiftByIdUserAndDate(user.id, date));
      if (mapWorkShift.containsKey("${user.id}_${date}") &&
          date != DateTimeUtils.getCurrentDate()) {
        ws = mapWorkShift["${user.id}_${date}"];
      } else {
        await cfC.getWorkShiftByUser(user.id, date);
        ws = cfC.mapWorkShiftFromUserAndDate["${user.id}_$date"];
        // ws = await _userServices.getWorkShiftByIdUserAndDate(user.id, date);
        mapWorkShift["${user.id}_${date}"] = ws;
      }
      if (ws == null && userSelected.isNotEmpty) {
        statusCheckIn = 1;
      } else if (ws != null &&
          ws.status != StatusCheckInDefine.checkOut.value &&
          userSelected.isNotEmpty) {
        if (date == DateTimeUtils.getCurrentDate()) {
          statusCheckIn = 3;
        } else {
          statusCheckIn = 2;
        }
      }
      if (ws != null && userSelected.isNotEmpty) {
        checkIn = ws.checkIn!;
        checkOut = ws.checkOut!;
      }
      if (ws != null &&
          (scopeSelected.isNotEmpty ||
              ws.status == StatusCheckInDefine.checkOut.value)) {
        DateTime ci = ws.checkIn!.toDate();
        DateTime co = ws.checkOut!.toDate();
        if (ws.status == StatusCheckInDefine.checkOut.value) {
          logTime += co.difference(ci).inMinutes.round();
          int sumBreak = 0;
          for (int i = 0; i < ws.breakTimes.length; i++) {
            DateTime brk = ws.breakTimes[i].toDate();
            DateTime rsm = ws.resumeTimes[i].toDate();
            sumBreak += (rsm.difference(brk).inMinutes.round());
          }
          if (curReq != requestGetData) return CardHRModel();
          logTime -= sumBreak;
        }

        List<WorkFieldModel> listWF = [];
        if (mapWFfWS.containsKey(ws.id)) {
          listWF.addAll(mapWFfWS[ws.id]!);
        } else {
          await cfC.getWorkFieldByWorkShift(ws.id);
          listWF = cfC.mapWFfWS[ws.id] ?? [];
          // listWF = await _workingService.getWorkFieldByIdWorkShift(ws.id);
          mapWFfWS[ws.id] = listWF;
        }
        listWFF.addAll(listWF);
        for (var wf in listWF) {
          int percentStatus = max(
              0,
              getDurationFromStatus(wf.toStatus) -
                  getDurationFromStatus(wf.fromStatus));

          WorkingUnitModel? work;
          if (mapWorkingUnit.containsKey(wf.taskId)) {
            work = mapWorkingUnit[wf.taskId];
          } else {
            work =
            await _workingService.getWorkingUnitByIdIgnoreClosed(wf.taskId);
            mapWorkingUnit[wf.taskId] = work;
          }
          if (curReq != requestGetData) return CardHRModel();
          if (work != null &&
              (userSelected.isEmpty ||
                  (userViewMode != AppText.textByScope.text ||
                      work.scopes.contains(scopeSelected)))) {
            // workingTime += percentStatus * work.duration ~/ 100;

            if (work.type == TypeAssignmentDefine.subtask.title) {
              WorkingUnitModel? workPar;
              if (mapWorkingUnit.containsKey(work.parent)) {
                workPar = mapWorkingUnit[work.parent];
              } else {
                workPar = await _workingService
                    .getWorkingUnitByIdIgnoreClosed(work.parent);
                mapWorkingUnit[work.parent] = workPar;
              }
              if (workPar != null &&
                  (userSelected.isEmpty ||
                      (userViewMode != AppText.textByScope.text ||
                          workPar.scopes.contains(scopeSelected)))) {
                if (!ddTask.containsKey(workPar.id)) {
                  ddTask[workPar.id] = 0;
                  cntTask++;
                }
                workingTime += wf.duration;
                ddTask[workPar.id] =
                // ddTask[workPar.id]! + percentStatus * work.duration ~/ 100;
                ddTask[workPar.id]! + wf.duration;
              }
            }
            if (work.type == TypeAssignmentDefine.task.title) {
              workingPoint += percentStatus * work.workingPoint ~/ 100;
              statusTask[work.id] = wf.toStatus;
              wpTask[work.id] = percentStatus * work.workingPoint ~/ 100;
            }
          }
        }
      }
    }
    if (curReq != requestGetData) return CardHRModel();
    List<HrTaskModel> listTmp = [];

    ddTask.forEach((k, v) async {
      List<UserModel> listUserTmp = [];
      final taskk = mapWorkingUnit[k]!;
      for (var u in taskk.assignees) {
        if (mapUserModel.containsKey(u)) {
          listUserTmp.add(mapUserModel[u]!);
        } else {
          final us = cfC.usersMap[u];
          // await _userServices.getUserById(u);
          if (us != null) {
            mapUserModel[u] = us;
            listUserTmp.add(us);
          }
        }
      }
      List<WorkingUnitModel> listSub = [];
      if (mapTaskChild.containsKey(taskk.id)) {
        listSub = [...mapTaskChild[taskk.id]!];
      } else {
        // cfC.getDataWorkingUnitClosedNewest(user);
        final data = await _workingService
            .getWorkingUnitByIdParentIgnoreClosed(taskk.id);
        listSub = [...data];
        mapTaskChild[taskk.id] = [...data];
        for (var e in data) {
          cfC.addWorkingUnit(e, isLocal: true);
        }
      }
      final status = FunctionUtils.getStatusTaskToday(taskk, listSub, listWFF);

      listTmp.add(HrTaskModel(
          task: taskk,
          workingTime: v,
          users: listUserTmp,
          status: status,
          workingPoint: wpTask[k] ?? 0));
    });
    if (curReq != requestGetData) return CardHRModel();
    CardHRModel newData = CardHRModel(
        date: date,
        dateStr: DateTimeUtils.formatDateDayMonthYear(date),
        logtime: logTime,
        taskOther: cntTask,
        workingTime: workingTime,
        workingPoint: workingPoint,
        checkIn: checkIn,
        checkOut: checkOut,
        details: listTmp,
        statusCheckIn: statusCheckIn);
    if (curReq != requestGetData) return CardHRModel();
    // mapHRData[
    //         "${DateTimeUtils.formatDateDayMonthYear(date)} - $scopeSelected - $userSelected - $userViewMode"] =
    //     newData;
    return newData;
  }

  loadDataForUser() async {
    listDataWorkOfUser.clear();
    loading++;
    EMIT();
    int currentRequest = ++request;
    List<WorkingUnitModel> listUserWork = [];
    List<WorkingUnitModel> listSubTask = [];
    // if (workOfUser.containsKey(userSelected) && false) {
    //   final workTasks = workOfUser[userSelected]!
    //       .where((item) => item.type == TypeAssignmentDefine.task.title)
    //       .toList();
    //   listUserWork.addAll(workTasks);
    //   listSubTask = workOfUser[userSelected]!
    //       .where((item) => item.type == TypeAssignmentDefine.subtask.title)
    //       .toList();
    // } else {
    await cfC.getDataWorkingUnitNewest(userSelected);
    // await cfC.getDataWorkingUnitClosedNewest(userSelected);
    final works =
    cfC.allWorkingUnit.where((e) => e.assignees.contains(userSelected) && !e.closed);
    // mapTaskChild = {...cfC.mapWorkChild};
    // await _workingService
    //     .getWorkingUnitByIdUserIgnoreClosed(userSelected);
    final workTasks = works
        .where((item) => item.type == TypeAssignmentDefine.task.title)
        .toList();
    listSubTask = works
        .where((item) => item.type == TypeAssignmentDefine.subtask.title)
        .toList();
    workOfUser[userSelected] = [];
    workOfUser[userSelected]!.addAll(works);
    listUserWork.addAll(workTasks);
    // }
    if (userViewMode == AppText.textByScope.text) {
      listUserWork = listUserWork
          .where((item) => item.scopes.contains(scopeSelected))
          .toList();
      listSubTask = listSubTask
          .where((item) => item.scopes.contains(scopeSelected))
          .toList();
    }

    // =======> Get data task today <=====================
    if (modeViewUser == AppText.textTaskAssign.text) {
      listDataWorkOfUser =
          listUserWork.where((item) => item.scopes.isNotEmpty).toList();
    } else if (modeViewUser == AppText.textTaskPersonal.text) {
      listDataWorkOfUser =
          listUserWork.where((item) => item.scopes.isEmpty).toList();
    } else if (modeViewUser == AppText.titleToday.text) {
      final workShift = await cfC.getWorkShiftByUser(
          userSelected, DateTimeUtils.getCurrentDate());
      // final workShift = await _userServices.getWorkShiftByIdUserAndDate(
      //     userSelected, DateTimeUtils.getCurrentDate());

      if (workShift == null) {
        loading--;
        EMIT();
        return;
      }

      await cfC.getWorkFieldByWorkShift(workShift.id);
      final workFields = cfC.mapWFfWS[workShift.id] ?? [];
      // final workFields =
      //     await _workingService.getWorkFieldByIdWorkShift(workShift.id);

      if (workFields.isEmpty) {
        loading--;
        EMIT();
        return;
      }

      List<WorkingUnitModel> listTaskToday = [];

      for (var wf in workFields) {
        if (!listTaskToday.any((item) => item.id == wf.taskId)) {
          WorkingUnitModel? workSub;
          if (mapWorkingUnit.containsKey(wf.taskId) &&
              mapWorkingUnit[wf.taskId] != null) {
            workSub = mapWorkingUnit[wf.taskId];
          } else {
            workSub =
            await _workingService.getWorkingUnitByIdIgnoreClosed(wf.taskId);
          }

          if (currentRequest != request) {
            loading--;
            EMIT();
            return;
          }

          if (workSub == null ||
              (userViewMode == AppText.textByScope.text &&
                  !workSub.scopes.contains(scopeSelected))) continue;
          if (listTaskToday.any((item) => item.id == workSub!.parent)) continue;

          if (mapWorkingUnit.containsKey(workSub.parent) &&
              mapWorkingUnit[workSub.parent] != null) {
            if (currentRequest != request) {
              loading--;
              EMIT();
              return;
            }
            if (mapWorkingUnit[workSub.parent] != null &&
                (userViewMode != AppText.textByScope.text ||
                    mapWorkingUnit[workSub.parent]!
                        .scopes
                        .contains(scopeSelected)) &&
                mapWorkingUnit[workSub.parent]!.type ==
                    TypeAssignmentDefine.task.title) {
              listTaskToday.add(mapWorkingUnit[workSub.parent]!);
            }
          } else {
            final workZ = await _workingService
                .getWorkingUnitByIdIgnoreClosed(workSub.parent);
            mapWorkingUnit[workSub.parent] = workZ;
            if (workZ != null &&
                (userViewMode != AppText.textByScope.text ||
                    workZ.scopes.contains(scopeSelected)) &&
                workZ.type == TypeAssignmentDefine.task.title) {
              if (currentRequest != request) {
                loading--;
                EMIT();
                return;
              }
              listTaskToday.add(workZ);
            }
          }
        }
      }

      List<WorkingUnitModel> listTaskTodayFinal = [];

      for (var work in listTaskToday) {
        if (currentRequest != request) {
          loading--;
          EMIT();
          return;
        }
        final listSub =
        listSubTask.where((item) => item.parent == work.id).toList();

        int cnt = 0;
        int done = 0;
        int mandatory = -9;

        for (var st in listSub) {
          int status = st.status;
          final wf =
              workFields.where((item) => item.taskId == st.id).firstOrNull;
          if (wf != null) {
            status = wf.toStatus;
          }
          if (status != StatusWorkingDefine.cancelled.value) cnt++;
          if (status == StatusWorkingDefine.done.value) done++;
          if (st.owner.isEmpty &&
              (status == StatusWorkingDefine.cancelled.value ||
                  status == StatusWorkingDefine.failed.value)) {
            mandatory = st.status;
          }
        }

        int finalStatus = 0;

        if (mandatory != -9) {
          finalStatus = mandatory;
        } else if (cnt == done) {
          finalStatus = StatusWorkingDefine.done.value;
        } else {
          finalStatus =
              StatusWorkingDefine.processing.value + (done * 100) ~/ cnt;
        }
        if (currentRequest != request) {
          loading--;
          EMIT();
          return;
        }
        listTaskTodayFinal.add(work.copyWith(status: finalStatus));
      }
      if (currentRequest != request) {
        blockRequest();
        return;
      }
      listDataWorkOfUser.addAll(listTaskTodayFinal);
    } else if (modeViewUser == AppText.titleDoing.text) {
      listDataWorkOfUser = listUserWork
          .where(
              (item) => StatusWorkingExtension.fromValue(item.status).isDynamic)
          .toList();
    }
    for (var work in listDataWorkOfUser) {
      if (!mapWorkChild.containsKey(work.id)) {
        final cntSub =
            listSubTask.where((item) => item.parent == work.id).length;
        mapWorkChild[work.id] = cntSub;
      }
    }

    await groupDataWorkOfUser();

    loading--;
    EMIT();
    for (var work in listDataWorkOfUser) {
      if (!mapAddress.containsKey(work.id)) {
        mapAddress[work.id] = await findAddress(work.id);
      }
    }
    EMIT();
  }

  loadDataTaskTable() async {
    final String idMap = "$startTime-$endTime-$scopeSelected-$userSelected";
    loading++;
    EMIT();
    // if (mapWorkSynthetic.containsKey(idMap)) {
    //   listTaskData.clear();
    //   listTaskData.addAll(mapWorkSynthetic[idMap]!);
    //   await groupData();
    //   loading--;
    //   return;
    // }

    listTaskData.clear();

    int currentRequest = ++request;
    List<String> listUsers = [];
    listUsers.addAll(userSelected.isNotEmpty
        ? [userSelected]
        : mapUserInScope[scopeSelected]!.map((item) => item.id).toList());
    for (DateTime date = startTime;
    date.isBefore(endTime.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {
      for (var user in listUsers) {
        WorkShiftModel? workShift;
        if (mapWorkShift.containsKey("${user}_${date}") &&
            date != DateTimeUtils.getCurrentDate()) {
          workShift = mapWorkShift["${user}_${date}"];
        } else {
          await cfC.getWorkShiftByUser(user, date);
          workShift = cfC.mapWorkShiftFromUserAndDate["${user}_$date"];
          // workShift =
          //     await _userServices.getWorkShiftByIdUserAndDate(user, date);
          mapWorkShift["${user}_${date}"] = workShift;
        }

        if (workShift == null) continue;

        if (currentRequest != request) {
          listTaskData.clear();
          blockRequest();
          return;
        }

        List<WorkFieldModel> workFields = [];

        if (mapWFfWS.containsKey(workShift.id)) {
          workFields = mapWFfWS[workShift.id]!;
        } else {
          await cfC.getWorkFieldByWorkShift(workShift.id);
          workFields = cfC.mapWFfWS[workShift.id] ?? [];
          // workFields =
          //     await _workingService.getWorkFieldByIdWorkShift(workShift.id);
          mapWFfWS[workShift.id] = workFields;
        }

        if (workFields.isEmpty) continue;
        if (currentRequest != request) {
          listTaskData.clear();
          blockRequest();
          return;
        }

        for (var wf in workFields) {
          int percentStatus = max(
              0,
              getDurationFromStatus(wf.toStatus) -
                  getDurationFromStatus(wf.fromStatus));
          WorkingUnitModel? work;
          if (mapWorkingUnit.containsKey(wf.taskId)) {
            work = mapWorkingUnit[wf.taskId];
          } else {
            work =
            await _workingService.getWorkingUnitByIdIgnoreClosed(wf.taskId);
            mapWorkingUnit[wf.taskId] = work;
          }
          if (work == null || !work.scopes.contains(scopeSelected)) continue;

          if (work.type == TypeAssignmentDefine.task.title) {
            WorkHistorySynthetic whs = WorkHistorySynthetic(
                work,
                0,
                percentStatus * max(0, work.workingPoint) ~/ 100,
                wf.fromStatus,
                wf.toStatus);
            int indexTask =
            listTaskData.indexWhere((item) => item.work.id == work!.id);
            if (indexTask == -1) {
              listTaskData.add(whs);
            } else {
              listTaskData[indexTask] = whs.copyWith();
            }
          } else {
            WorkingUnitModel? workPar;
            if (mapWorkingUnit.containsKey(work.parent)) {
              workPar = mapWorkingUnit[work.parent];
            } else {
              workPar = await _workingService
                  .getWorkingUnitByIdIgnoreClosed(work.parent);
              mapWorkingUnit[work.parent] = workPar;
            }

            if (workPar == null || !workPar.scopes.contains(scopeSelected))
              continue;
            if (currentRequest != request) {
              listTaskData.clear();
              blockRequest();
              return;
            }

            // if (!mapTaskWorkSynChild.containsKey(idMap + workPar.id)) {
            //   mapTaskWorkSynChild[idMap + workPar.id] = [];
            // }

            List<WorkHistorySynthetic> taskChildren = [];
            // taskChildren.addAll(mapTaskWorkSynChild[idMap + workPar.id]!);

            WorkHistorySynthetic whsSubtask = WorkHistorySynthetic(
                work,
                // percentStatus * work.duration ~/ 100,
                wf.duration,
                0,
                wf.fromStatus,
                wf.toStatus);

            int indexSub =
            taskChildren.indexWhere((item) => item.work.id == work!.id);
            if (indexSub == -1) {
              taskChildren.add((whsSubtask));
            } else {
              final tmp = taskChildren[indexSub];
              taskChildren[indexSub] = tmp.copyWith(
                  toStatus: wf.toStatus,
                  workingTime: tmp.workingTime + whsSubtask.workingTime);
            }

            mapTaskWorkSynChild[idMap + workPar.id] = [
              ...taskChildren,
            ];

            if (!listTaskData.any((item) => item.work.id == workPar!.id)) {
              WorkHistorySynthetic whs =
              WorkHistorySynthetic(workPar, 0, 0, -2209, -2209);
              listTaskData.add(whs);
            }
          }
        }
      }
    }

    for (int i = 0; i < listTaskData.length; i++) {
      WorkHistorySynthetic data = listTaskData[i];
      final listChildren = mapTaskWorkSynChild[idMap + data.work.id] ?? [];
      for (var child in listChildren) {
        data = data.copyWith(workingTime: data.workingTime + child.workingTime);
      }
      listTaskData[i] = data;
    }

    // mapWorkSynthetic[idMap] = [];
    // mapWorkSynthetic[idMap]!.addAll(listTaskData);
    await groupData();
    loading--;
    EMIT();
  }

  groupData() async {
    mapTaskDataGroup.clear();
    final personal =
    WorkingUnitModel(id: "personal", title: AppText.titlePersonal.text);
    final other = WorkingUnitModel(id: "other", title: AppText.textOther.text);
    for (var e in listTaskData) {
      WorkingUnitModel ancestor = await findAncestor(e.work);
      if (ancestor.id == e.work.id) {
        ancestor = personal;
      } else if (ancestor.type != TypeAssignmentDefine.epic.title) {
        ancestor = other;
      }
      if (!mapTaskDataGroup.containsKey(ancestor)) {
        mapTaskDataGroup[ancestor] = [];
      }
      if (!mapTaskSumDataGroup.containsKey(ancestor)) {
        mapTaskSumDataGroup[ancestor] = {
          "workingPoint": 0,
          "numOfSubtask": 0,
        };
      }
      List<WorkHistorySynthetic> tmp = mapTaskDataGroup[ancestor]!;
      mapTaskDataGroup[ancestor] = [];
      mapTaskDataGroup[ancestor]!.addAll([...tmp, e]);

    }
  }

  groupDataWorkOfUser() async {
    mapDataWorkOfUserGroup.clear();
    mapTaskSumDataGroup.clear();
    final personal =
    WorkingUnitModel(id: "personal", title: AppText.titlePersonal.text);
    final other = WorkingUnitModel(id: "other", title: AppText.textOther.text);
    for (var e in listDataWorkOfUser) {
      if (userSelected.isNotEmpty &&
          modeViewUser == AppText.textTaskAssign.text &&
          filterStatusTaskAssign != AppText.textByFull.text) {
        if (filterStatusTaskAssign == AppText.textByFinished.text &&
            !e.isFinished) continue;
        if (filterStatusTaskAssign == AppText.textByUnFinished.text &&
            !e.isDoing) continue;
        if (filterStatusTaskAssign == AppText.titleDoing.text &&
            !StatusWorkingExtension.fromValue(e.status).isDynamic) continue;
        if (filterStatusTaskAssign == AppText.textThisWeek.text &&
            (!e.isInThisWeek || !e.isDone)) continue;
        if (filterStatusTaskAssign == AppText.textLastWeek.text &&
            (!e.isInLastWeek || !e.isDone)) continue;
      }
      WorkingUnitModel ancestor = await findAncestor(e);
      if (ancestor.id == e.id) {
        ancestor = personal;
      } else if (ancestor.type != TypeAssignmentDefine.epic.title) {
        ancestor = other;
      }
      if (!mapDataWorkOfUserGroup.containsKey(ancestor)) {
        mapDataWorkOfUserGroup[ancestor] = [];
      }
      if (!mapTaskSumDataGroup.containsKey(ancestor)) {
        mapTaskSumDataGroup[ancestor] = {
          "workingPoint": 0,
          "numOfSubtask": 0,
        };
      }
      List<WorkingUnitModel> tmp = mapDataWorkOfUserGroup[ancestor]!;
      mapDataWorkOfUserGroup[ancestor] = [];
      mapDataWorkOfUserGroup[ancestor]!.addAll([...tmp, e]);
      mapTaskSumDataGroup[ancestor]!['workingPoint'] =
          mapTaskSumDataGroup[ancestor]!['workingPoint']! +
              max(0, e.workingPoint);
      int cntSubtask = 0;
      if (mapWorkChild.containsKey(e.id)) {
        cntSubtask = mapWorkChild[e.id]!;
      } else {
        final subChildren =
        cfC.allWorkingUnit.where((f) => f.parent == e.id).toList();
        // await _workingService.getWorkingUnitByIdParent(e.id);
        mapWorkChild[e.id] = subChildren.length;
        mapTaskChild[e.id] = subChildren;
        cntSubtask = subChildren.length;
      }
      mapTaskSumDataGroup[ancestor]!['numOfSubtask'] =
          mapTaskSumDataGroup[ancestor]!['numOfSubtask']! + cntSubtask;
    }
  }

  getDataUser(List<String> users) async {
    for (var user in users) {
      if (!mapUserModel.containsKey(user)) {
        final userData = cfC.usersMap[user];
        // await _userServices.getUserById(user);
        if (userData != null) {
          mapUserModel[user] = userData;
        }
      }
    }
    // EMIT();
  }

  getDataTaskChildAndUser(String task, List<String> users) async {
    getDataUser(users);
    if (mapTaskChild.containsKey(task)) return;
    await cfC.getDataWorkingUnitNewest(userSelected);
    await cfC.getDataWorkingUnitClosedNewest(userSelected);
    final listSubtask =
    cfC.allWorkingUnit.where((e) => e.parent == task).toList();
    // final listSubtask =
    //     await _workingService.getWorkingUnitByIdParentIgnoreClosed(task);
    for (var task in listSubtask) {
      if (!mapWorkingUnit.containsKey(task.id)) {
        mapWorkingUnit[task.id] = task;
      }
    }
    mapTaskChild[task] = listSubtask;
    // EMIT();
  }

  getDataTaskChildToday(
      String task, List<String> users, String user, DateTime date) async {
    // getDataUser(users);
    // if (mapTaskChildToday.containsKey(task)) return;
    // final listSubtask =
    // await _workingService.getWorkingUnitByIdParentIgnoreClosed(task);
    // final workShift = await _userServices.getWorkShiftByIdUserAndDate(user, date);
    // List<WorkFieldModel> wfs = [];
    //
    // if(mapWFfWS.containsKey(workShift.id))
    // for (var task in listSubtask) {
    //   if (!mapWorkingUnit.containsKey(task.id)) {
    //     mapWorkingUnit[task.id] = task;
    //   }
    // }
    // mapTaskChild[task] = listSubtask;
    // EMIT();
  }

  // dynamic getDataMap(dynamic map, String key, dynamic getDT) async {
  //   if (map.containsKey(key)) {
  //     return map[key];
  //   }
  //   final data = getDT();
  //   map[key] = data;
  //   return data;
  // }

  changeQuarter(String newQuarter) {
    final parts = newQuarter.split(" ");
    quarterSelected.clear();
    quarterSelected.add(int.parse(parts[1]));
    quarterSelected.add(int.parse(parts[2]));
    final data = DateTimeUtils.getQuarterDateRange(
        quarterSelected[0], quarterSelected[1]);
    startTime = data['startDate']!;
    endTime = data['endDate']!;
    loadDataForTable(startTime, endTime);
    // EMIT();
  }

  changeTimeView(String mode) {
    DateTime end = DateTimeUtils.getCurrentDate();
    DateTime start = end.subtract(const Duration(days: 4));
    if (mode == AppText.text10Days.text) {
      start = end.subtract(const Duration(days: 9));
    } else if (mode == AppText.textLastWeek.text) {
      start = DateTimeUtils.getStartOfThisWeek(end)
          .subtract(const Duration(days: 7));
      end = start.add((const Duration(days: 6)));
    } else if (mode == AppText.textThisWeek.text) {
      start = DateTimeUtils.getStartOfThisWeek(end);
    } else if (mode == AppText.textThisMonth.text) {
      start = DateTime(end.year, end.month, 1);
    } else if (mode == AppText.textLastMonth.text) {
      start = DateTimeUtils.getStartOfLastMonth(end);
      end = DateTimeUtils.getEndOfLastMonth(end);
    }
    startTime = start;
    endTime = end;
    loadDataForTable(start, end);
  }

  changeTime(DateTime s, DateTime e) {
    startTime = s;
    endTime = e;
    loadDataForTable(s, e);
    // EMIT();
  }

  changeTimeMode(String newV) {
    timeMode = newV;
    loadDataForTable(startTime, endTime);
    // EMIT();
  }

  changeUserViewMode(String newV) {
    userViewMode = newV;
    loadDataForTable(startTime, endTime);
  }

  changeFilterStatusTaskAssign(String newV) {
    filterStatusTaskAssign = newV;
    groupDataWorkOfUser();
    EMIT();
  }

  changeScopeAndUser(String newScp, String newUser,
      {bool isLoad = true}) async {
    scopeSelected = newScp;
    userSelected = newUser;
    // EMIT();
    if (isLoad) {
      if (userSelected.isEmpty && isInTaskHr) {
        loadingTaskView++;
        await getEpic();
        filterEpicTV = mapEpicInScope[scopeSelected]!.firstOrNull ?? allEpic;
        EMIT();
        loadTaskForHrTaskView();
        updateFilterTaskHrView();
        loadingTaskView--;
      } else {
        isInTaskHr = false;
        loadDataForTable(startTime, endTime);
      }
    } else {
      if (userSelected.isEmpty && isInTaskHr) {
        loadingTaskView++;
        await getEpic();
        filterEpicTV = mapEpicInScope[scopeSelected]!.firstOrNull ?? allEpic;
        EMIT();
        loadTaskForHrTaskView();
        updateFilterTaskHrView();
        loadingTaskView--;
      }
    }

    // EMIT();
  }

  changeModeViewUser(String newV) {
    modeViewUser = newV;
    loadDataForTable(startTime, endTime);
    // EMIT();
  }

  getEpic() async {
    if (mapEpicInScope.containsKey(scopeSelected)) return;
    await cfC.getDataWorkingUnitTypeByScopeNewest(
        scopeSelected, TypeAssignmentDefine.epic.title);
    final epics = cfC.allWorkingUnit
        .where((e) =>
    e.scopes.contains(scopeSelected) &&
        e.type == TypeAssignmentDefine.epic.title)
        .toList();
    // await _workingService.getAllEpicInScopeIgnoreClosed(scopeSelected);
    mapEpicInScope[scopeSelected] = [...epics];
  }

  Future<List<WorkingUnitModel>> findAddress(String id) async {
    if (id == "") return [];
    if (mapAddress.containsKey(id)) return mapAddress[id]!;
    List<WorkingUnitModel> tmp = [];
    final work =
    await WorkingService.instance.getWorkingUnitByIdIgnoreClosed(id);
    if (work != null) {
      tmp = await findAddress(work.parent);
      if (tmp.isNotEmpty) {
        mapAddress[id] = [work, ...tmp];
      } else {
        mapAddress[id] = [work];
      }
    } else {
      mapAddress[id] = [];
    }
    return mapAddress[id]!;
  }

  int getDurationFromStatus(int status) {
    if (StatusWorkingExtension.fromValue(status).isDynamic) {
      return status % 100;
    }
    if (status == StatusWorkingDefine.done.value) {
      return 100;
    }
    return 0;
  }

  Future<WorkingUnitModel> findAncestor(WorkingUnitModel work) async {
    // if (mapAncestor.containsKey(work.id)) return mapAncestor[work.id]!;
    if (work.parent.isEmpty) {
      mapAncestor[work.id] = work;
      return work;
    }
    WorkingUnitModel? workPar;
    if (mapWorkingUnit.containsKey(work.parent)) {
      workPar = mapWorkingUnit[work.parent];
    } else {
      workPar =
      await _workingService.getWorkingUnitByIdIgnoreClosed(work.parent);
      if (workPar != null) {
        mapWorkingUnit[work.parent] = workPar;
      }
    }
    // if (workPar == null || !workPar.scopes.contains(scopeSelected)) return work;
    if (workPar == null) return work;
    final workAncestor = await findAncestor(workPar);
    mapAncestor[work.id] = workAncestor;
    return workAncestor;
  }

  int loadingTaskView = 0;

  loadTaskForHrTaskView() async {
    loadingTaskView++;
    listTaskScope.clear();
    if (mapTaskInScope.containsKey(scopeSelected)) {
      listTaskScope = [...mapTaskInScope[scopeSelected]!];
      await groupDataTaskScope();
      loadingTaskView--;
      EMIT();
      return;
    }
    await cfC.getDataWorkingUnitByScopeNewest(scopeSelected);
    final tasks =
    cfC.allWorkingUnit.where((e) => e.scopes.contains(scopeSelected));
    // await _workingService.getAllTaskInScopeIgnoreClosed(scopeSelected);
    listTaskScope = [...tasks];
    mapTaskInScope[scopeSelected] = [...tasks];
    updateFilterTaskHrView();
    // await groupDataTaskScope();
    loadingTaskView--;
    EMIT();
  }

  getTaskInScope(String scp) async {
    if (mapTaskInScope.containsKey(scopeSelected)) {
      return mapTaskInScope[scopeSelected]!;
    } else {
      await cfC.getDataWorkingUnitByScopeNewest(scopeSelected);
      final tasks = cfC.allWorkingUnit.where((e) =>
      e.scopes.contains(scopeSelected) &&
          e.type == TypeAssignmentDefine.task.title);
      mapTaskInScope[scopeSelected] = [...tasks];
      return tasks;
    }
  }

  groupDataTaskScope() async {
    mapDataTaskScopeGroup.clear();
    mapTaskSumDataGroup.clear();
    final personal =
    WorkingUnitModel(id: "personal", title: AppText.titlePersonal.text);
    final other = WorkingUnitModel(id: "other", title: AppText.textOther.text);
    for (var e in listTaskScope) {
      WorkingUnitModel ancestor = await findAncestor(e);
      if (ancestor.id == e.id) {
        ancestor = personal;
      } else if (ancestor.type != TypeAssignmentDefine.epic.title) {
        ancestor = other;
      }
      if (!mapDataTaskScopeGroup.containsKey(ancestor)) {
        mapDataTaskScopeGroup[ancestor] = [];
      }
      if (!mapTaskSumDataGroup.containsKey(ancestor) ||
          mapTaskSumDataGroup[ancestor] == null) {
        mapTaskSumDataGroup[ancestor] = {
          "workingPoint": 0,
          "numOfSubtask": 0,
        };
      }
      List<WorkingUnitModel> tmp = mapDataTaskScopeGroup[ancestor]!;
      mapDataTaskScopeGroup[ancestor] = [];
      mapDataTaskScopeGroup[ancestor]!.addAll([...tmp, e]);

      mapTaskSumDataGroup[ancestor]!['workingPoint'] =
          mapTaskSumDataGroup[ancestor]!['workingPoint']! +
              max(0, e.workingPoint);

      int cntSubtask = 0;
      if (mapWorkChild.containsKey(e.id)) {
        cntSubtask = mapWorkChild[e.id]!;
      } else {
        final subChildren =
        cfC.allWorkingUnit.where((f) => f.parent == e.id).toList();
        // await _workingService.getWorkingUnitByIdParent(e.id);
        mapWorkChild[e.id] = subChildren.length;
        mapTaskChild[e.id] = subChildren;
        cntSubtask = subChildren.length;
      }
      if (mapTaskSumDataGroup[ancestor] != null) {
        mapTaskSumDataGroup[ancestor]!['numOfSubtask'] =
            mapTaskSumDataGroup[ancestor]!['numOfSubtask']! + cntSubtask;
      }
    }
  }

  changeHrTaskView(bool v) async {
    isInTaskHr = v;
    if (v) {
      loadingTaskView++;
      await getEpic();
      filterEpicTV = mapEpicInScope[scopeSelected]!.firstOrNull ?? allEpic;
      EMIT();
      loadTaskForHrTaskView();
      loadingTaskView--;
    } else {
      loadDataForTable(startTime, endTime);
    }
    EMIT();
  }

  blockRequest() {
    listTaskData.clear();
    loading--;
    EMIT();
  }

  String filterAssignTV = AppText.textAll.text;
  String filterStatusTV = AppText.textNeedToDo.text;
  String filterClosedTV = AppText.textOpened.text;
  final allEpic = WorkingUnitModel(title: AppText.textAll.text);
  WorkingUnitModel filterEpicTV = WorkingUnitModel(title: AppText.textAll.text);
  String filterDeadlineTV = AppText.text2Week.text;
  bool isSortDeadline = false;
  final userAll = UserModel(name: AppText.textAll.text);
  UserModel filterUserTV = UserModel(name: AppText.textAll.text);
  bool isSortAssignees = false;

  changeFilterAssignTV(String v) {
    filterAssignTV = v;
    updateFilterTaskHrView();
  }

  changeFilterStatusTV(String v) {
    filterStatusTV = v;
    updateFilterTaskHrView();
  }

  changeFilterClosedTV(String v) {
    filterClosedTV = v;
    updateFilterTaskHrView();
  }

  changeFilterEpicTV(WorkingUnitModel v) {
    filterEpicTV = v;
    updateFilterTaskHrView();
  }

  changeFilterDeadlineTV(String v) {
    filterDeadlineTV = v;
    updateFilterTaskHrView();
  }

  changeSortDeadline(bool v) {
    isSortDeadline = v;
    if (v) {
      isSortAssignees = false;
    }
    updateFilterTaskHrView();
  }

  changeFilterUserTV(UserModel v) {
    filterUserTV = v;
    updateFilterTaskHrView();
  }

  changeSortAssignees(bool v) {
    isSortAssignees = v;
    if (v) {
      isSortDeadline = false;
    }
    updateFilterTaskHrView();
  }

  updateFilterTaskHrView() async {
    loadingTaskView++;
    mapDataTaskScopeGroup.clear();
    EMIT();
    final listData = await getTaskInScope(scopeSelected);

    List<WorkingUnitModel> tmp = [];
    tmp = [...updateFilterAssignTV(listData)];
    tmp = [...updateFilterStatusTV(tmp)];
    tmp = [...updateFilterClosedTV(tmp)];
    final tmp2 = await updateFilterEpicTV(tmp);
    tmp = [...tmp2];
    tmp = [...updateFilterDeadlineTV(tmp)];
    tmp = [...updateFilterUserTV(tmp)];

    if (isSortDeadline) {
      tmp.sort((a, b) => a.deadline.compareTo(b.deadline));
    }
    if (isSortAssignees) {
      tmp.sort((a, b) => (a.assignees.firstOrNull ?? "")
          .compareTo(b.assignees.firstOrNull ?? ""));
    }
    listTaskScope = [...tmp];

    await groupDataTaskScope();
    loadingTaskView--;
    EMIT();
  }

  updateFilterUserTV(List<WorkingUnitModel> listData) {
    if (filterUserTV.name == AppText.textAll.text) {
      return listData;
    } else {
      return listData
          .where((e) => e.assignees.contains(filterUserTV.id))
          .toList();
    }
  }

  updateFilterDeadlineTV(List<WorkingUnitModel> listData) {
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    if (filterDeadlineTV == AppText.textAll.text) {
      return listData;
    } else if (filterDeadlineTV == AppText.textThisWeek.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(0);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.textNextWeek.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(1);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text2Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(2);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text3Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(3);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text4Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(4);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text5Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(5);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text6Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(6);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text7Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(7);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text8Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(8);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text9Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(9);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text10Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(10);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text11Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(11);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.text12Week.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfWeek(12);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.textThisMonth.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfMonth(0);
      start = timeRange['start']!;
      end = timeRange['end']!;
    } else if (filterDeadlineTV == AppText.textNextMonth.text) {
      final timeRange = DateTimeUtils.getStartAndEndOfMonth(1);
      start = timeRange['start']!;
      end = timeRange['end']!;
    }
    return listData
        .where((e) =>
    e.deadline.toDate().isBefore(end.add(const Duration(days: 1))) &&
        e.deadline
            .toDate()
            .isAfter(start.subtract(const Duration(days: 1))))
        .toList();
  }

  updateFilterEpicTV(List<WorkingUnitModel> listData) async {
    if (filterEpicTV.title == AppText.textAll.text) {
      return listData;
    } else {
      List<WorkingUnitModel> tmp = [];
      for (var e in listData) {
        final ancestor = await findAncestor(e);
        if (ancestor.id == filterEpicTV.id) {
          tmp.add(e);
        }
      }
      return tmp;
    }
  }

  updateFilterClosedTV(List<WorkingUnitModel> listData) {
    if (filterClosedTV == AppText.textAll.text) {
      return listData;
    } else if (filterClosedTV == AppText.textClosed.text) {
      return listData.where((e) => e.closed).toList();
    } else if (filterClosedTV == AppText.textOpened.text) {
      return listData.where((e) => !e.closed).toList();
    }
    return [];
  }

  updateFilterStatusTV(List<WorkingUnitModel> listData) {
    if (filterStatusTV == AppText.textAll.text) {
      return listData;
    } else if (filterStatusTV == AppText.textNeedToDo.text) {
      return listData.where((e) => e.isDoing).toList();
    } else if (filterStatusTV == AppText.titleDoing.text) {
      return listData
          .where((e) => StatusWorkingExtension.fromValue(e.status).isDynamic)
          .toList();
    } else if (filterStatusTV == AppText.textByFinished.text) {
      return listData.where((e) => e.isFinished).toList();
    } else if (filterStatusTV == AppText.textNone.text) {
      return listData
          .where((e) => e.status == StatusWorkingDefine.none.value)
          .toList();
    }
    return [];
  }

  updateFilterAssignTV(List<WorkingUnitModel> listData) {
    if (filterAssignTV == AppText.textAll.text) {
      return listData;
    } else if (filterAssignTV == AppText.textByAssign.text) {
      return listData.where((e) => e.assignees.isNotEmpty).toList();
    } else if (filterAssignTV == AppText.textByUnassign.text) {
      return listData.where((e) => e.assignees.isEmpty).toList();
    }
    return [];
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}