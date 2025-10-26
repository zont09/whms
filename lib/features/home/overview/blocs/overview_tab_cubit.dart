import 'dart:math';

import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/user_overview_data.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/pair.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/services/working_service.dart';

class OverviewTabCubit extends Cubit<int> {
  OverviewTabCubit(this.cfC) : super(0);

  final WorkingService _workingService = WorkingService.instance;
  // final IssueService _issueService = IssueService.instance;

  int request = 0;
  int loadingDataUser = 0;
  int loadingDataTask = 0;
  int loadingIssue = 0;

  String scopeSelected = "";
  String epicSelected = "";
  String sprintSelected = "";
  String tabTaskSelected = AppText.txtSprint.text;

  Pair<int, String> tabSelected = Pair(0, "");
  String timeMode = AppText.text5Days.text;
  DateTime startTime =
      DateTimeUtils.getCurrentDate().subtract(const Duration(days: 4));
  DateTime endTime = DateTimeUtils.getCurrentDate();

  List<ScopeModel> listScopeUser = [];
  List<UserOverviewData> listDataUser = [];
  Map<String, List<WorkingUnitModel>> epicOfScope = {};
  Map<String, List<WorkingUnitModel>> sprintOfEpic = {};

  Map<String, ScopeModel> mapScope = {};
  Map<String, List<ScopeModel>> mapScopeOfUser = {};
  Map<String, List<UserModel>> mapUserInScope = {};
  Map<String, UserModel> mapUserModel = {};
  Map<String, WorkShiftModel?> mapWorkShift = {};
  Map<String, List<WorkFieldModel>> mapWFfWS = {};
  Map<String, WorkingUnitModel> mapWorkUnit = {};
  Map<String, WorkingUnitModel?> mapWorkParEpic = {};
  Map<String, WorkingUnitModel?> mapWorkParSprint = {};
  Map<String, List<WorkingUnitModel>> mapWorkChild = {};
  Map<String, List<WorkingUnitModel>> mapWorkInScope = {};
  // Map<String, List<IssueModel>> mapListIssue = {};

  late ConfigsCubit cfC;

  initData(BuildContext context) async {
    final user = ConfigsCubit.fromContext(context).user;

    final scopeUsers =
        cfC.allScopes.where((e) => e.members.contains(user.id)).toList();
    // await _scopeService.getScopeByIdUser(user.id);

    listScopeUser.clear();
    listScopeUser.addAll(scopeUsers);

    // mapWFfWS.addAll(cfC.mapWFfWS);

    for (var scp in scopeUsers) {
      if (epicOfScope.containsKey(scp.id)) continue;
      await cfC.getDataWorkingUnitTypeByScopeNewest(
          scp.id, TypeAssignmentDefine.epic.title);
      final epics = cfC.allWorkingUnit
          .where((e) =>
              e.scopes.contains(scp.id) &&
              !e.closed &&
              e.type == TypeAssignmentDefine.epic.title)
          .toList();
      // await _workingService.getEpicByScopeIgnoreClosed(scp.id);
      epicOfScope[scp.id] = [];
      epicOfScope[scp.id]!.addAll(epics);
      for (var epic in epics) {
        if (sprintOfEpic.containsKey(epic.id)) continue;
        final sprints = await _workingService.getWorkingUnitByIdParent(epic.id);
        sprintOfEpic[epic.id] = [];
        sprintOfEpic[epic.id]!.addAll(sprints
            .where((item) => item.type == TypeAssignmentDefine.sprint.title)
            .toList());
      }
    }
    EMIT();
    loadingDataTask++;
    updateDataIssue();
    updateDataForTaskTable();
    await updateDataUser();

    // loadingDataTask--;
    EMIT();
  }

  updateDataUser() async {
    loadingDataUser++;
    int curReq = ++request;
    listDataUser.clear();
    ScopeModel? scope;
    if (mapScope.containsKey(scopeSelected)) {
      scope = mapScope[scopeSelected];
    } else {
      final response = cfC.allScopeMap[scopeSelected];
      // await _scopeService.getScopeById(scopeSelected)
      //     as ResponseModel<ScopeModel>;
      if (response != null) {
        scope = response;
        mapScope[scopeSelected] = scope;
      }
    }
    List<UserModel> listUser = [];
    if (!mapUserInScope.containsKey(scopeSelected)) {
      final userInScope =
          cfC.allUsers.where((e) => e.scopes.contains(scopeSelected)).toList();
      // await _userServices.getUserByScopeId(scopeSelected);
      mapUserInScope[scopeSelected] = userInScope;
      listUser.addAll(userInScope);
      for (var u in userInScope) {
        if (!mapUserModel.containsKey(u.id)) {
          mapUserModel[u.id] = u;
        }
      }
    } else {
      listUser.addAll(mapUserInScope[scopeSelected]!);
    }

    for (var user in listUser) {
      if (curReq != request) {
        loadingDataUser--;
        return;
      }
      int logTime = 0;
      int workingPoint = 0;
      int workingTime = 0;
      int taskDone = 0;
      int taskDoing = 0;
      int taskOther = 0;

      for (DateTime date = startTime;
          date.isBefore(endTime.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        WorkShiftModel? ws;
        if (mapWorkShift.containsKey('ws_${user.id}_$date')) {
          ws = mapWorkShift['ws_${user.id}_$date'];
        } else {
          ws = await cfC.getWorkShiftByUser(user.id, date);
          // ws = await _userServices.getWorkShiftByIdUserAndDate(user.id, date);
          mapWorkShift['ws_${user.id}_$date'] = ws;
        }
        if (ws == null) continue;

        logTime += FunctionUtils.getLogTimeFromWorkShift(ws);

        List<WorkFieldModel> wfs = [];
        if (mapWFfWS.containsKey(ws.id)) {
          wfs = mapWFfWS[ws.id]!;
        } else {
          await cfC.getWorkFieldByWorkShift(ws.id);
          wfs = cfC.mapWFfWS[ws.id] ?? [];
          // wfs = await _workingService.getWorkFieldByIdWorkShift(ws.id);
          mapWFfWS[ws.id] = [];
          mapWFfWS[ws.id]!.addAll(wfs);
        }
        for (var wf in wfs) {
          WorkingUnitModel? work;
          if (mapWorkUnit.containsKey(wf.taskId)) {
            work = mapWorkUnit[wf.taskId];
          } else {
            work =
                await _workingService.getWorkingUnitByIdIgnoreClosed(wf.taskId);
            if (work != null) {
              mapWorkUnit[wf.taskId] = work;
            }
          }
          if (work == null) continue;
          if (!work.scopes.contains(scopeSelected)) continue;
          if (epicSelected.isNotEmpty) {
            final epicOfWork = await getEpicOfWorkUnit(work);
            if (epicOfWork == null || epicOfWork.id != epicSelected) continue;
          }
          if (sprintSelected.isNotEmpty) {
            final sprintOfWork = await getSprintOfWorkUnit(work);
            if (sprintOfWork == null || sprintOfWork.id != sprintSelected) {
              continue;
            }
          }
          int percent = max(
              0,
              getDurationFromStatus(wf.toStatus, work.type) -
                  getDurationFromStatus(wf.fromStatus, work.type));
          if (work.type == TypeAssignmentDefine.task.title) {
            workingPoint += max(0, work.workingPoint) * percent ~/ 100;
            if (wf.toStatus == StatusWorkingDefine.done.value) {
              taskDone++;
            } else if (StatusWorkingExtension.fromValue(wf.toStatus)
                .isDynamic) {
              taskDoing++;
            } else {
              taskOther++;
            }
          } else if (work.type == TypeAssignmentDefine.subtask.title) {
            workingTime += wf.duration; //work.duration * percent ~/ 100;
          }
        }
      }

      final newDataUser = UserOverviewData(
          user: user,
          logTime: logTime,
          workingPoint: workingPoint,
          workingTime: workingTime,
          taskDone: taskDone,
          taskDoing: taskDoing,
          taskOther: taskOther);
      if (curReq != request) {
        loadingDataUser--;
        return;
      }
      listDataUser.add(newDataUser);
      EMIT();
    }
    loadingDataUser--;
    EMIT();
  }

  updateDataForTaskTable() async {
    if (sprintSelected.isNotEmpty) {
      if (!mapWorkChild.containsKey(sprintSelected)) {
        await cfC.getDataWorkingUnitByIdParentNewest(sprintSelected);
        final works = cfC.allWorkingUnit
            .where((e) => e.parent == sprintSelected)
            .toList();
        // await _workingService
        //     .getWorkingUnitByIdParentIgnoreClosed(sprintSelected);
        mapWorkChild[sprintSelected] = [];
        mapWorkChild[sprintSelected]!.addAll(works);
      }
      loadingDataTask--;
      EMIT();
      for (var work in mapWorkChild[sprintSelected]!) {
        if (!mapWorkChild.containsKey(work.id)) {
          await cfC.getDataWorkingUnitByIdParentNewest(work.id);
          final works =
              cfC.allWorkingUnit.where((e) => e.parent == work.id).toList();
          // final works = await _workingService
          //     .getWorkingUnitByIdParentIgnoreClosed(work.id);
          mapWorkChild[work.id] = [];
          mapWorkChild[work.id]!.addAll(works);
        }
      }
    } else if (epicSelected.isNotEmpty) {
      if (!mapWorkChild.containsKey(epicSelected)) {
        await cfC.getDataWorkingUnitByIdParentNewest(epicSelected);
        final works =
            cfC.allWorkingUnit.where((e) => e.parent == epicSelected).toList();
        // final works = await _workingService
        //     .getWorkingUnitByIdParentIgnoreClosed(epicSelected);
        mapWorkChild[epicSelected] = [];
        mapWorkChild[epicSelected]!.addAll(works);
      }
      loadingDataTask--;
      EMIT();
      for (var work in mapWorkChild[epicSelected]!) {
        if (!mapWorkChild.containsKey(work.id)) {
          await cfC.getDataWorkingUnitByIdParentNewest(work.id);
          final works =
              cfC.allWorkingUnit.where((e) => e.parent == work.id).toList();
          // final works = await _workingService
          //     .getWorkingUnitByIdParentIgnoreClosed(work.id);
          mapWorkChild[work.id] = [];
          mapWorkChild[work.id]!.addAll(works);
        }
      }
    } else {
      if (!mapWorkInScope.containsKey(scopeSelected)) {
        //     TypeAssignmentDefine.sprint.title,
        // TypeAssignmentDefine.story.title,
        // TypeAssignmentDefine.task.title,
        await cfC.getDataWorkingUnitTypeByScopeNewest(
            scopeSelected, TypeAssignmentDefine.sprint.title);
        await cfC.getDataWorkingUnitTypeByScopeNewest(
            scopeSelected, TypeAssignmentDefine.story.title);
        await cfC.getDataWorkingUnitTypeByScopeNewest(
            scopeSelected, TypeAssignmentDefine.task.title);
        final works = cfC.allWorkingUnit.where((e) =>
            (e.type == TypeAssignmentDefine.sprint.title ||
                e.type == TypeAssignmentDefine.story.title ||
                e.type == TypeAssignmentDefine.task.title) &&
             e.scopes.contains(scopeSelected));
        // await _workingService.getSSTByScopeIdIC(scopeSelected);
        mapWorkInScope[scopeSelected] = [];
        mapWorkInScope[scopeSelected]!.addAll(works);
      }
      loadingDataTask--;
      EMIT();
      for (var work in mapWorkInScope[scopeSelected]!) {
        if (!mapWorkInScope.containsKey(work.id)) {
          await cfC.getDataWorkingUnitByIdParentNewest(work.id);
          final works =
              cfC.allWorkingUnit.where((e) => e.parent == work.id).toList();
          // final works = await _workingService
          //     .getWorkingUnitByIdParentIgnoreClosed(work.id);
          mapWorkChild[work.id] = [];
          mapWorkChild[work.id]!.addAll(works);
        }
      }
    }
    EMIT();
  }

  updateDataIssue() async {
    // loadingIssue++;
    // if (epicSelected.isNotEmpty &&
    //     !mapListIssue.containsKey("epic_$epicSelected")) {
    //   final issues = await _issueService.getIssueByIdProject(epicSelected);
    //   issues.sort((a, b) => a.createAt.compareTo(b.createAt));
    //   mapListIssue["epic_$epicSelected"] = [];
    //   mapListIssue["epic_$epicSelected"]!.addAll(issues);
    // } else if (!mapListIssue.containsKey("scope_$scopeSelected")) {
    //   final issues = await _issueService.getIssueByIdScope(scopeSelected);
    //   issues.sort((a, b) => a.createAt.compareTo(b.createAt));
    //   mapListIssue["scope_$scopeSelected"] = [];
    //   mapListIssue["scope_$scopeSelected"]!.addAll(issues);
    // }
    //
    // EMIT();
    // loadingIssue--;
  }

  changeTabSelected(String newTab) async {
    List<String> tabs = newTab.split("&");
    int len = tabs.length - 1;
    tabSelected = Pair(len, tabs[len]);
    scopeSelected = tabs[0];
    epicSelected = len > 0 ? tabs[1] : "";
    sprintSelected = len > 1 ? tabs[2] : "";
    loadingDataTask++;
    if (sprintSelected.isNotEmpty) {
      tabTaskSelected = AppText.txtStory.text;
    } else {
      tabTaskSelected = AppText.txtSprint.text;
    }
    updateDataForTaskTable();
    updateDataIssue();
    await updateDataUser();
    EMIT();
  }

  changeTime(String mode) async {
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
    await updateDataUser();
    EMIT();
  }

  changeTabTaskSelected(String newV) {
    tabTaskSelected = newV;
    EMIT();
  }

  Future<WorkingUnitModel?> getEpicOfWorkUnit(WorkingUnitModel work) async {
    if (mapWorkParEpic.containsKey(work.id)) return mapWorkParEpic[work.id];
    if (work.type == TypeAssignmentDefine.epic.title) {
      mapWorkParEpic[work.id] = work;
      return work;
    }
    if (work.parent.isEmpty) return null;
    WorkingUnitModel? workPar;
    if (mapWorkUnit.containsKey(work.parent)) {
      workPar = mapWorkUnit[work.parent];
    } else {
      workPar =
          await _workingService.getWorkingUnitByIdIgnoreClosed(work.parent);
      if (workPar != null) {
        mapWorkUnit[work.parent] = workPar;
      }
    }
    if (workPar == null) return null;
    final epic = await getEpicOfWorkUnit(workPar);
    mapWorkParEpic[work.id] = epic;
    return epic;
  }

  Future<WorkingUnitModel?> getSprintOfWorkUnit(WorkingUnitModel work) async {
    if (mapWorkParSprint.containsKey(work.id)) return mapWorkParSprint[work.id];
    if (work.type == TypeAssignmentDefine.sprint.title) {
      mapWorkParSprint[work.id] = work;
      return work;
    }
    if (work.parent.isEmpty) return null;
    WorkingUnitModel? workPar;
    if (mapWorkUnit.containsKey(work.parent)) {
      workPar = mapWorkUnit[work.parent];
    } else {
      workPar =
          await _workingService.getWorkingUnitByIdIgnoreClosed(work.parent);
      if (workPar != null) {
        mapWorkUnit[work.parent] = workPar;
      }
    }
    if (workPar == null) return null;
    final epic = await getEpicOfWorkUnit(workPar);
    mapWorkParSprint[work.id] = epic;
    return epic;
  }

  int getDurationFromStatus(int status, String type) {
    if (type != TypeAssignmentDefine.task.title &&
        type != TypeAssignmentDefine.subtask.title) return status;
    if (StatusWorkingExtension.fromValue(status).isDynamic) {
      return status % 100;
    }
    if (status == StatusWorkingDefine.done.value) {
      return 100;
    }
    return 0;
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
    if (mapWorkChild.containsKey(task)) return;
    cfC.getDataWorkingUnitByIdParentNewest(task);
    final listSubtask =
        cfC.allWorkingUnit.where((e) => e.parent == task).toList();
    // await _workingService.getWorkingUnitByIdParentIgnoreClosed(task);
    for (var task in listSubtask) {
      if (!mapWorkUnit.containsKey(task.id)) {
        mapWorkUnit[task.id] = task;
      }
    }
    mapWorkChild[task] = listSubtask;
    // EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
