import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/file_attachment_service.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/date_time_utils.dart';

class MainTabCubit extends Cubit<int> {
  MainTabCubit(this.cfC) : super(0);

  final WorkingService _workingService = WorkingService.instance;
  // final MeetingService _meetingService = MeetingService.instance;
  final FileAttachmentService _fileAttachmentService =
      FileAttachmentService.instance;
  final CacheUtils _cacheUtils = CacheUtils.instance;

  int taskToday = 0;
  int sumTask = 0;
  int taskTop = 0;
  int taskPersonal = 0;
  int taskAssign = 0;
  int taskUrgent = 0;
  int taskDoing = 0;
  int taskFollowing = 0;

  UserModel? userCur;

  List<WorkingUnitModel> listSum = [];
  List<WorkingUnitModel> listToday = [];
  List<WorkingUnitModel> listTop = [];
  List<WorkingUnitModel> listPersonal = [];
  List<WorkingUnitModel> listAssign = [];
  List<WorkingUnitModel> listSubTaskToday = [];
  List<WorkingUnitModel> listUrgent = [];
  List<WorkingUnitModel> listDoing = [];
  List<WorkingUnitModel> listFullTask = [];
  List<WorkingUnitModel> listFollowing = [];
  List<WorkingUnitModel> listOKRs = [];
  List<ScopeModel> listUserScope = [];
  // List<MeetingModel> listMeeting = [];
  List<WorkingUnitModel> listProject = [];
  List<WorkFieldModel> listWFs = [];
  Map<String, List<FileAttachmentModel>> mapFileMeeting = {};

  List<String> sortedFullTask = [];

  List<ScopeModel> listScope = [];

  Map<String, List<WorkingUnitModel>> mapAddress = {};
  Map<String, int> mapNumberSubTask = {};
  Map<String, String> mapWorkParent = {};
  Map<String, ScopeModel> mapScope = {};
  Map<String, WorkingUnitModel> mapWorkUnit = {};
  Map<String, List<WorkingUnitModel>> mapProjectInScope = {};

  Map<String, List<WorkingUnitModel>> mapWorkChild = {};

  Map<String, WorkFieldModel> mapWorkFieldfTask = {};
  WorkShiftModel? workShift;

  late ConfigsCubit cfC;

  int request = 0;

  // String get version => ConfigsCubit.version;

  initData(
      BuildContext context,
      List<WorkingUnitModel> listWork,
      Map<String, WorkingUnitModel> mapWU,
      Map<String, List<WorkingUnitModel>> mapChild) async {
    if (!isClosed) {
      emit(0);
    }
    int currentRequest = ++request;
    listSum.clear();
    listToday.clear();
    listPersonal.clear();
    listTop.clear();
    listAssign.clear();
    listSubTaskToday.clear();
    listUrgent.clear();
    listDoing.clear();
    listFollowing.clear();
    listFullTask.clear();
    mapAddress.clear();
    // ConfigsCubit.fromContext(context).getDataStaffEvaluation();
    mapWorkUnit = {...mapWU};
    final user = ConfigsCubit.fromContext(context).user;
    userCur = user;
    final lisWorkSumTmp = listWork.where((e) =>
        (e.assignees.contains(user.id) || e.followers.contains(user.id)) &&
        !e.closed);
    List<WorkingUnitModel> lisWorkSum = lisWorkSumTmp
        .where((item) => item.type == TypeAssignmentDefine.task.title)
        .toList();
    listFullTask.addAll(lisWorkSum);
    for (var work in lisWorkSum) {
      mapAddress[work.id] = [];

      if (!mapWorkParent.containsKey(work.id)) {
        mapWorkParent[work.id] = work.title;
      }
    }

    if (request != currentRequest) return;
    final workShift = cfC
            .mapWorkShift["${user.id}_${DateTimeUtils.getCurrentDate()}"] ??
        await cfC.getWorkShiftByUser(user.id, DateTimeUtils.getCurrentDate());
    final workField = workShift == null ||
            workShift.status == StatusCheckInDefine.checkOut.value
        ? null
        : cfC.mapWFfWS[workShift.id];
    // final workField = workShift != null &&
    //     workShift.status != StatusCheckInDefine.checkOut.value
    //     ? await WorkingService.instance.getWorkFieldByIdWorkShift(workShift.id)
    //     : null;
    listWFs = [...workField ?? []];

    for (var e in workField ?? []) {
      if (!mapWorkFieldfTask.containsKey(e.id)) {
        mapWorkFieldfTask[e.taskId] = e;
      }
    }

    mapWorkChild = {...mapChild};

    List<WorkingUnitModel> tmpLW = [];
    for (var work in lisWorkSum) {
      List<WorkingUnitModel> listSubWork = [];
      if (mapWorkChild.containsKey(work.id)) {
        listSubWork.addAll(mapWorkChild[work.id]!);
      } else {
        listSubWork.addAll([]);
      }

      int cnt = 0;
      int process = 0;
      int mandatoryStatus = -9;
      List<WorkingUnitModel> tmpWorkChild = [];
      if (listSubWork.isNotEmpty) {
        for (var sW in listSubWork) {
          int status = sW.status;

          final workk =
              workField?.where((item) => item.taskId == sW.id).firstOrNull;
          if (workk != null) {
            status = workk.toStatus;
            tmpWorkChild.add(sW.copyWith(status: workk.toStatus));
          } else {
            tmpWorkChild.add(sW);
          }
          if (sW.owner.isEmpty &&
              (status == StatusWorkingDefine.cancelled.value ||
                  status == StatusWorkingDefine.failed.value)) {
            mandatoryStatus = status;
          }
          if (status == StatusWorkingDefine.cancelled.value) continue;
          cnt++;
          if (status == StatusWorkingDefine.done.value) process++;
        }
      }
      // if (!mapWorkChild.containsKey(work.id)) {
      mapWorkChild[work.id] = [];
      mapWorkChild[work.id] = [...tmpWorkChild];
      // }
      if (request != currentRequest) return;
      if (mandatoryStatus != -9) {
        tmpLW.add(work.copyWith(status: mandatoryStatus));
      } else if (cnt == process) {
        tmpLW.add(work.copyWith(status: StatusWorkingDefine.done.value));
      } else if (cnt > 0) {
        if (process == 0) {
          tmpLW.add(work);
        } else {
          tmpLW.add(work.copyWith(
              status: StatusWorkingDefine.processing.value +
                  (process * 100) ~/ cnt));
        }
      } else {
        tmpLW.add(work);
      }
    }

    lisWorkSum.clear();
    lisWorkSum = [...tmpLW];
    sumTask = lisWorkSum.length;
    if (request != currentRequest) return;
    listSum.addAll(lisWorkSum);
    for (var work in listSum) {
      if (mapNumberSubTask.containsKey(work.id)) continue;
      final workST = mapWorkChild[work.id] ?? [];
      mapNumberSubTask[work.id] = workST.length;
    }

    if (workField != null) {
      for (var wf in workField) {
        WorkingUnitModel? work;
        if (mapWorkUnit.containsKey(wf.taskId)) {
          work = mapWorkUnit[wf.taskId];
        } else {
          work = await WorkingService.instance.getWorkingUnitById(wf.taskId);

          if (work != null) {
            mapWorkUnit[wf.taskId] = work;
          }
        }
        if (work != null) {
          listSubTaskToday.add(work.copyWith(status: wf.toStatus));
          final workUnit =
              listSum.where((item) => item.id == work!.parent).firstOrNull;
          if (workUnit != null) {
            if (!listToday.contains(workUnit)) {
              if (request != currentRequest) return;
              listToday.add(workUnit);
            }
          }
        }
      }
    }

    // listToday.sort((a, b) => a.deadline)

    taskToday = listToday.isNotEmpty ? listToday.length : 0;
    final listTaskPersonal =
        lisWorkSum.where((item) => item.scopes.isEmpty).toList();
    taskPersonal = listTaskPersonal.length;
    listPersonal = [...listTaskPersonal];
    final listTaskTop = lisWorkSum
        .where((item) => item.priority == PriorityLevelDefine.top.title)
        .toList();
    if (request != currentRequest) return;
    taskTop = listTaskTop.length;
    if (request != currentRequest) return;
    listTop.addAll(listTaskTop);
    if (request != currentRequest) return;
    listAssign = listSum.where((item) => item.scopes.isNotEmpty).toList();
    if (request != currentRequest) return;
    taskAssign = listAssign.length;

    final today = DateTime.now();
    for (var work in lisWorkSum) {
      if (today.isAfter(work.urgent.toDate()) &&
          (!today.isAfter(work.deadline.toDate()) ||
              DateTimeUtils.getCurrentDate() == work.deadline.toDate())) {
        if (request != currentRequest) return;
        listUrgent.add(work);
      }
    }

    taskUrgent = listUrgent.length;

    for (var work in lisWorkSum) {
      if (StatusWorkingExtension.fromValue(work.status).isDynamic) {
        if (request != currentRequest) return;
        listDoing.add(work);
      }
    }
    taskDoing = listDoing.length;

    // final taskFollow = await _workingService.getAllTaskFollowing(user.id);
    listFollowing = [...lisWorkSum.where((e) => e.followers.contains(user.id))];
    taskFollowing = listFollowing.length;
    for (var e in listFollowing) {
      if (!mapWorkUnit.containsKey(e.id)) {
        mapWorkUnit[e.id] = e;
      }
      // if(!mapWorkChild.containsKey(e.id)) {
      //   final data = await _workingService.getWorkingUnitByIdParent(e.id);
      //   mapWorkChild[e.id] = [...data];
      // }
    }

    final List<ScopeModel> userScopes = [
      ...user.scopes
          .where((e) => cfC.allScopeMap[e] != null)
          .map((e) => cfC.allScopeMap[e]!)
    ];
    listUserScope = [...userScopes];

    // getFullTask(lisWorkSum, user.id);

    getDataScope();
    // final list
    EMIT();
    // loadMeeting();

    listProject.clear();
    for (var scp in userScopes) {
      await cfC.getDataWorkingUnitByScopeNewest(scp.id);
      final projects = cfC.allWorkingUnit
          .where((e) => e.scopes.contains(scp.id) && !e.closed)
          .toList();
      // final projects = await _workingService.getWorkingUnitByScopeId(scp.id);
      if (projects.isNotEmpty) {
        mapProjectInScope[scp.id] = projects
            .where((item) => item.type == TypeAssignmentDefine.epic.title)
            .toList();
        listProject.addAll(mapProjectInScope[scp.id]!);
        for (var prj in mapProjectInScope[scp.id]!) {
          mapWorkUnit[prj.id] = prj;
        }
      }
    }
    EMIT();
    for (var e in listFollowing) {
      // if (!mapWorkUnit.containsKey(e.id)) {
      //   mapWorkUnit[e.id] = e;
      // }
      if (!mapWorkChild.containsKey(e.id)) {
        final data = await _workingService.getWorkingUnitByIdParent(e.id);
        mapWorkChild[e.id] = [...data];
        for (var f in data) {
          cfC.addWorkingUnit(f, isLocal: true);
        }
      }
    }
    EMIT();
    for (var work in lisWorkSum) {
      mapAddress[work.id] = await findAddress(work.parent);
    }
    EMIT();
    final resScope = await ScopeService.instance.getListScope()
        as ResponseModel<List<ScopeModel>>;
    if (resScope.status == ResponseStatus.ok &&
        resScope.results != null &&
        resScope.results!.isNotEmpty) {
      for (var scp in resScope.results!) {
        if (!mapScope.containsKey(scp.id)) {
          mapScope[scp.id] = scp;
        }
      }
    }
    EMIT();
  }

  getFullTask(List<WorkingUnitModel> listData, String idU) async {
    await cfC.getDataWorkingUnitClosedNewest(cfC.user.id);
    // final workClosed = ;
    // await _workingService.getAllWorkingUnitOfUserByClosed(idU);
    listFullTask.clear();
    listFullTask = [
      ...cfC.allWorkingUnit.where((e) => e.assignees.contains(cfC.user.id))
    ];
    for (var e in listFullTask) {
      if (!mapWorkUnit.containsKey(e.id)) {
        mapWorkUnit[e.id] = e;
      }
    }
    EMIT();
  }

  getDataScope() async {
    final scopes = cfC.allScopes;
    if (scopes.isNotEmpty) {
      listScope.clear();
      listScope.addAll(cfC.allScopes);
    }
  }

  Future<List<WorkingUnitModel>> findAddress(String id) async {
    if (id == "") return [];
    if (mapAddress.containsKey(id)) return mapAddress[id]!;
    List<WorkingUnitModel> tmp = [];
    final work = cfC.mapWorkingUnit[id] ??
        await WorkingService.instance.getWorkingUnitByIdIgnoreClosed(id);
    if (work != null) {
      tmp = await findAddress(work.parent);
      if (tmp.isNotEmpty) {
        mapAddress[id] = [...tmp];
      } else {
        mapAddress[id] = [];
      }
    } else {
      mapAddress[id] = [];
    }
    List<WorkingUnitModel> returnData = [...mapAddress[id]!];
    if (work != null) {
      returnData.insert(0, work);
    }
    return returnData;
  }

  updateTaskListFullTask(WorkingUnitModel task) {
    int index = listFullTask.indexWhere((e) => e.id == task.id);
    if (index != -1) {
      listFullTask[index] = task;
      EMIT();
    }
  }

  getDataTaskChildAndUser(String task) async {
    if (mapWorkChild.containsKey(task)) return;
    final listSubtask =
        await _workingService.getWorkingUnitByIdParentIgnoreClosed(task);
    for (var task in listSubtask) {
      if (!mapWorkUnit.containsKey(task.id)) {
        mapWorkUnit[task.id] = task;
      }
      cfC.addWorkingUnit(task, isLocal: true);
    }
    mapWorkChild[task] = listSubtask;
    // EMIT();
  }

  updateSubtask(WorkingUnitModel work) {
    WorkingUnitModel? workPar = mapWorkUnit[work.parent];
    if (workPar == null) return null;
    List<WorkingUnitModel> tmp = mapWorkChild[work.parent] ?? [];
    int index = tmp.indexWhere((e) => e.id == work.id);
    if (index != -1) {
      tmp[index] = work;
    }
    mapWorkChild[work.parent] = [...tmp];
    int cnt = 0;
    int process = 0;
    int mandatoryStatus = -9;
    for (var sub in tmp) {
      if (sub.owner.isEmpty &&
          (sub.status == StatusWorkingDefine.cancelled.value ||
              sub.status == StatusWorkingDefine.failed.value)) {
        mandatoryStatus = sub.status;
      }
      if (sub.status == StatusWorkingDefine.cancelled.value) continue;
      cnt++;
      if (sub.status == StatusWorkingDefine.done.value) process++;
    }
    if (mandatoryStatus != -9) {
      workPar = workPar.copyWith(status: mandatoryStatus);
    } else if (cnt == process) {
      workPar = workPar.copyWith(status: StatusWorkingDefine.done.value);
    } else if (cnt > 0) {
      if (process == 0) {
        workPar = workPar;
      } else {
        workPar = workPar.copyWith(
            status:
                StatusWorkingDefine.processing.value + (process * 100) ~/ cnt);
      }
    } else {
      workPar = workPar;
    }
    updateWorkingUnit(workPar);
    EMIT();
    return workPar;
  }

  updateWorkingUnit(WorkingUnitModel work, {bool isEmit = true}) async {
    if (work.type == TypeAssignmentDefine.subtask.title) {
      updateWorkInList(listSubTaskToday, work);
      List<WorkingUnitModel> tmp = mapWorkChild[work.parent] ?? [];
      int index = tmp.indexWhere((e) => e.id == work.id);
      if (index != -1) {
        tmp[index] = work;
      } else {
        tmp.add(work);
      }
      mapWorkChild[work.parent] = [...tmp];
      // if (!listFullTask.any((e) => e.id == work.id)) {
      //   listFullTask.add(value)
      // }
      if (isEmit) {
        EMIT();
      }
      return;
    }
    if (work.type != TypeAssignmentDefine.task.title) return;
    if (!listFullTask.any((e) => e.id == work.id)) {
      await addWorkToList(work);
      if (isEmit) {
        EMIT();
      }
      return;
    }
    mapWorkUnit[work.id] = work;
    List<WorkingUnitModel> tmp = mapWorkChild[work.parent] ?? [];
    int idx = tmp.indexWhere((e) => e.id == work.id);
    if (idx != -1) {
      if (work.enable) {
        tmp[idx] = work;
      } else {
        tmp.removeAt(idx);
      }
      mapWorkChild[work.parent] = [...tmp];
    }
    updateWorkInList(listFullTask, work, isListFullTask: true);
    updateWorkInList(listFollowing, work);
    if (!work.assignees.contains(cfC.user.id)) {
      if (isEmit) {
        EMIT();
      }
      return;
    }
    updateWorkInList(listSum, work);
    taskToday = updateWorkInList(listToday, work);
    taskTop = updateWorkInList(listTop, work);
    taskPersonal = updateWorkInList(listPersonal, work);
    taskAssign = updateWorkInList(listAssign, work);
    updateWorkInList(listSubTaskToday, work);
    taskUrgent = updateWorkInList(listUrgent, work);
    taskDoing = updateWorkInList(listDoing, work);

    if (isEmit) {
      EMIT();
    }
  }

  addWorkToList(WorkingUnitModel work) async {
    if (listFullTask.any((e) => e.id == work.id)) return;
    listFullTask.add(work);
    if (work.followers.contains(userCur?.id)) {
      listFollowing.add(work);
      taskFollowing++;
    }
    if (!work.assignees.contains(cfC.user.id)) {
      EMIT();
      return;
    }
    mapAddress[work.id] = await findAddress(work.parent);
    if (work.closed) {
      EMIT();
      return;
    }
    listSum.add(work);

    if (work.scopes.isEmpty && work.assignees.contains(userCur?.id)) {
      listPersonal.add(work);
      taskPersonal++;
    } else if (work.assignees.contains(userCur?.id)) {
      listAssign.add(work);
      taskAssign++;
    }
    if (work.priority == PriorityLevelDefine.top.title) {
      listTop.add(work);
      taskTop++;
    }
    final today = DateTime.now();
    if (today.isAfter(work.urgent.toDate()) &&
        (!today.isAfter(work.deadline.toDate()) ||
            DateTimeUtils.getCurrentDate() == work.deadline.toDate())) {
      listUrgent.add(work);
      taskUrgent++;
    }
    if (StatusWorkingExtension.fromValue(work.status).isDynamic) {
      listDoing.add(work);
      taskDoing++;
    }
  }

  updateWorkInList(List<WorkingUnitModel> list, WorkingUnitModel work,
      {bool isListFullTask = false}) {
    int index = list.indexWhere((e) => e.id == work.id);
    if (index != -1) {
      if ((work.closed && !isListFullTask) || !work.enable) {
        list.removeAt(index);
      } else {
        list[index] = work;
      }
    }
    return list.length;
  }

  addSubtask(WorkingUnitModel work) {
    if (work.enable) {
      mapWorkUnit[work.id] = work;
      List<WorkingUnitModel> listSub = mapWorkChild[work.parent] ?? [];
      mapWorkChild[work.parent] = [...listSub, work];
      updateSubtask(work);
    } else {
      mapWorkUnit.remove(work.id);
      List<WorkingUnitModel> listSub = mapWorkChild[work.parent] ?? [];
      int idx2 = listSub.indexWhere((e) => e.id == work.id);
      listSub.removeAt(idx2);
      mapWorkChild[work.parent] = [...listSub];
    }
  }

  removeSubtask(WorkingUnitModel work) {
    mapWorkUnit.remove(work.id);
    List<WorkingUnitModel> listSub = mapWorkChild[work.parent] ?? [];
    listSub.remove(work);
    mapWorkChild[work.parent] = [...listSub];
    updateSubtask(work);
  }

  addTaskPersonal(WorkingUnitModel work) {
    mapWorkUnit[work.id] = work;
    if (!listPersonal.contains(work)) {
      listPersonal.add(work);
    }
    taskPersonal++;
    EMIT();
  }

  int loadingMeeting = 0;
  //
  // loadMeeting() async {
  //   if (listMeeting.isNotEmpty) return;
  //   loadingMeeting++;
  //   final data = await _meetingService.getMeetingsForUser(userCur?.id ?? "");
  //   listMeeting.addAll(data.where((e) =>
  //       e.status != StatusMeetingDefine.done.title &&
  //       e.status != StatusMeetingDefine.ended.title));
  //   loadingMeeting--;
  //   EMIT();
  // }
  //
  // getDataFileMeeting(MeetingModel meet) async {
  //   if (mapFileMeeting.containsKey(meet.id)) return;
  //   List<FileAttachmentModel> tmp = [];
  //   for (var e in meet.sections) {
  //     final sec = await _meetingService.getMeetingSectionById(e);
  //     if (sec == null) continue;
  //     for (var a in sec.attachments) {
  //       final file = await _fileAttachmentService.getFileAttachmentById(a);
  //       if (file == null) continue;
  //       tmp.add(file);
  //       if (file.type != "link") {
  //         await _cacheUtils.getFileGB(file.source);
  //       }
  //     }
  //
  //     final pre = await _meetingService.getMeetingPreparationById(e);
  //     if (pre == null) continue;
  //     for (var a in pre.attachments) {
  //       final file = await _fileAttachmentService.getFileAttachmentById(a);
  //       if (file == null) continue;
  //       tmp.add(file);
  //       if (file.type != "link") {
  //         await _cacheUtils.getFileGB(file.source);
  //       }
  //     }
  //   }
  //   mapFileMeeting[meet.id] = tmp;
  //   EMIT();
  // }

  updateWorkFieldfTask(WorkFieldModel wf) {
    mapWorkFieldfTask[wf.taskId] = wf;
    EMIT();
  }

  updateWorkField(WorkFieldModel model) async {
    int index = listWFs.indexWhere((e) => e.id == model.id);
    if (index != -1) {
      if (model.enable) {
        listWFs[index] = model;
        mapWorkFieldfTask[model.taskId] = model;
      } else {
        listWFs.removeAt(index);
        mapWorkFieldfTask.remove(model.taskId);
      }
    } else {
      listWFs.add(model);
      mapWorkFieldfTask[model.taskId] = model;
    }
    await updateTaskToday();
    EMIT();
  }

  updateWorkShift(WorkShiftModel model) async {
    workShift = model;
    await updateTaskToday();
    EMIT();
  }

  updateTaskToday() {
    if (workShift?.status == StatusCheckInDefine.checkOut.value) {
      listToday.clear();
      taskToday = 0;
      return;
    }
    final lisWorkSum = listFullTask.where((e) => !e.closed).toList();
    final workField = listWFs.where((e) => e.workShift == workShift?.id);
    List<WorkingUnitModel> tmpLW = [];
    for (var work in lisWorkSum) {
      List<WorkingUnitModel> listSubWork = [];
      if (mapWorkChild.containsKey(work.id)) {
        listSubWork.addAll(mapWorkChild[work.id]!);
      } else {
        listSubWork.addAll([]);
      }

      int cnt = 0;
      int process = 0;
      int mandatoryStatus = -9;
      List<WorkingUnitModel> tmpWorkChild = [];
      if (listSubWork.isNotEmpty) {
        for (var sW in listSubWork) {
          int status = sW.status;

          final workk =
              workField.where((item) => item.taskId == sW.id).firstOrNull;
          if (workk != null) {
            status = workk.toStatus;
            tmpWorkChild.add(sW.copyWith(status: workk.toStatus));
          } else {
            tmpWorkChild.add(sW);
          }
          if (sW.owner.isEmpty &&
              (status == StatusWorkingDefine.cancelled.value ||
                  status == StatusWorkingDefine.failed.value)) {
            mandatoryStatus = status;
          }
          if (status == StatusWorkingDefine.cancelled.value) continue;
          cnt++;
          if (status == StatusWorkingDefine.done.value) process++;
        }
      }
      // if (!mapWorkChild.containsKey(work.id)) {
      mapWorkChild[work.id] = [];
      mapWorkChild[work.id] = [...tmpWorkChild];
      // }
      if (mandatoryStatus != -9) {
        tmpLW.add(work.copyWith(status: mandatoryStatus));
      } else if (cnt == process) {
        tmpLW.add(work.copyWith(status: StatusWorkingDefine.done.value));
      } else if (cnt > 0) {
        if (process == 0) {
          tmpLW.add(work);
        } else {
          tmpLW.add(work.copyWith(
              status: StatusWorkingDefine.processing.value +
                  (process * 100) ~/ cnt));
        }
      } else {
        tmpLW.add(work);
      }
    }
    for (var e in tmpLW) {
      int indexSum = listSum.indexWhere((f) => f.id == e.id);
      if (indexSum != -1) {
        listSum[indexSum] = e;
      } else {
        listSum.add(e);
      }
    }
    for (var wf in workField.toList()) {
      WorkingUnitModel? work;
      if (mapWorkUnit.containsKey(wf.taskId)) {
        work = mapWorkUnit[wf.taskId];
      } else {
        work = cfC.mapWorkingUnit[wf.taskId];
        // await WorkingService.instance.getWorkingUnitById(wf.taskId);
        if (work != null) {
          mapWorkUnit[wf.taskId] = work;
        }
      }
      if (work != null) {
        listSubTaskToday.add(work.copyWith(status: wf.toStatus));
        final workUnit =
            tmpLW.where((item) => item.id == work!.parent).firstOrNull;
        if (workUnit != null) {
          int index = listToday.indexWhere((e) => e.id == workUnit.id);
          if (index == -1) {
            listToday.add(workUnit);
          } else {
            listToday[index] = workUnit;
          }
          updateWorkingUnit(workUnit, isEmit: false);
        }
      }
    }
    taskToday = listToday.length;
  }

  initDataDefault(
      BuildContext context,
      List<WorkingUnitModel> listWork,
      Map<String, WorkingUnitModel> mapWU,
      Map<String, List<WorkingUnitModel>> mapChild) {
    if (!isClosed) {
      emit(0);
    }
    int currentRequest = ++request;
    listSum.clear();
    listToday.clear();
    listPersonal.clear();
    listTop.clear();
    listAssign.clear();
    listSubTaskToday.clear();
    listUrgent.clear();
    listDoing.clear();
    listFollowing.clear();
    listFullTask.clear();
    mapAddress.clear();
    // ConfigsCubit.fromContext(context).getDataStaffEvaluation();
    mapWorkUnit = {...mapWU};
    final user = ConfigsCubit.fromContext(context).user;
    userCur = user;
    final lisWorkSumTmp = listWork.where((e) =>
        (e.assignees.contains(user.id) || e.followers.contains(user.id)) &&
        !e.closed);
    List<WorkingUnitModel> lisWorkSum = lisWorkSumTmp
        .where((item) => item.type == TypeAssignmentDefine.task.title)
        .toList();
    listFullTask.addAll(lisWorkSum);
    for (var work in lisWorkSum) {
      mapAddress[work.id] = [];

      if (!mapWorkParent.containsKey(work.id)) {
        mapWorkParent[work.id] = work.title;
      }
    }

    if (request != currentRequest) return;
    final workShift =
        cfC.mapWorkShift["${user.id}_${DateTimeUtils.getCurrentDate()}"];
    // final workShift = await UserServices.instance
    //     .getWorkShiftByIdUserAndDate(user.id, DateTimeUtils.getCurrentDate());
    if (workShift != null) {
      // await cfC.getWorkFieldByWorkShift(workShift.id);
    }
    final workField = workShift == null ||
            workShift.status == StatusCheckInDefine.checkOut.value
        ? null
        : cfC.mapWFfWS[workShift.id];
    // final workField = workShift != null &&
    //     workShift.status != StatusCheckInDefine.checkOut.value
    //     ? await WorkingService.instance.getWorkFieldByIdWorkShift(workShift.id)
    //     : null;
    listWFs = [...workField ?? []];

    for (var e in workField ?? []) {
      if (!mapWorkFieldfTask.containsKey(e.id)) {
        mapWorkFieldfTask[e.taskId] = e;
      }
    }

    mapWorkChild = {...mapChild};

    List<WorkingUnitModel> tmpLW = [];
    for (var work in lisWorkSum) {
      List<WorkingUnitModel> listSubWork = [];
      if (mapWorkChild.containsKey(work.id)) {
        listSubWork.addAll(mapWorkChild[work.id]!);
      } else {
        listSubWork.addAll([]);
      }

      int cnt = 0;
      int process = 0;
      int mandatoryStatus = -9;
      List<WorkingUnitModel> tmpWorkChild = [];
      if (listSubWork.isNotEmpty) {
        for (var sW in listSubWork) {
          int status = sW.status;
          final workk =
              workField?.where((item) => item.taskId == sW.id).firstOrNull;
          if (workk != null) {
            status = workk.toStatus;
            tmpWorkChild.add(sW.copyWith(status: workk.toStatus));
          } else {
            tmpWorkChild.add(sW);
          }
          if (sW.owner.isEmpty &&
              (status == StatusWorkingDefine.cancelled.value ||
                  status == StatusWorkingDefine.failed.value)) {
            mandatoryStatus = status;
          }
          if (status == StatusWorkingDefine.cancelled.value) continue;
          cnt++;
          if (status == StatusWorkingDefine.done.value) process++;
        }
      }
      // if (!mapWorkChild.containsKey(work.id)) {
      mapWorkChild[work.id] = [];
      mapWorkChild[work.id] = [...tmpWorkChild];
      // }
      if (request != currentRequest) return;
      if (mandatoryStatus != -9) {
        tmpLW.add(work.copyWith(status: mandatoryStatus));
      } else if (cnt == process) {
        tmpLW.add(work.copyWith(status: StatusWorkingDefine.done.value));
      } else if (cnt > 0) {
        if (process == 0) {
          tmpLW.add(work);
        } else {
          tmpLW.add(work.copyWith(
              status: StatusWorkingDefine.processing.value +
                  (process * 100) ~/ cnt));
        }
      } else {
        tmpLW.add(work);
      }
    }

    lisWorkSum.clear();
    lisWorkSum = [...tmpLW];
    sumTask = lisWorkSum.length;
    if (request != currentRequest) return;
    listSum.addAll(lisWorkSum);
    for (var work in listSum) {
      if (mapNumberSubTask.containsKey(work.id)) continue;
      final workST = mapWorkChild[work.id] ?? [];
      mapNumberSubTask[work.id] = workST.length;
    }

    if (workField != null) {
      for (var wf in workField) {
        WorkingUnitModel? work;
        if (mapWorkUnit.containsKey(wf.taskId)) {
          work = mapWorkUnit[wf.taskId];
        }
        if (work != null) {
          listSubTaskToday.add(work.copyWith(status: wf.toStatus));
          final workUnit =
              listSum.where((item) => item.id == work!.parent).firstOrNull;
          if (workUnit != null) {
            if (!listToday.contains(workUnit)) {
              if (request != currentRequest) return;
              listToday.add(workUnit);
            }
          }
        }
      }
    }

    // listToday.sort((a, b) => a.deadline)

    taskToday = listToday.isNotEmpty ? listToday.length : 0;
    final listTaskPersonal = lisWorkSum
        .where((item) =>
            item.scopes.isEmpty && item.assignees.contains(userCur?.id))
        .toList();
    taskPersonal = listTaskPersonal.length;
    listPersonal = [...listTaskPersonal];
    final listTaskTop = lisWorkSum
        .where((item) => item.priority == PriorityLevelDefine.top.title)
        .toList();
    if (request != currentRequest) return;
    taskTop = listTaskTop.length;
    if (request != currentRequest) return;
    listTop.addAll(listTaskTop);
    if (request != currentRequest) return;
    listAssign = listSum.where((item) => item.scopes.isNotEmpty).toList();
    if (request != currentRequest) return;
    taskAssign = listAssign.length;

    final today = DateTime.now();
    for (var work in lisWorkSum) {
      if (today.isAfter(work.urgent.toDate()) &&
          (!today.isAfter(work.deadline.toDate()) ||
              DateTimeUtils.getCurrentDate() == work.deadline.toDate())) {
        if (request != currentRequest) return;
        listUrgent.add(work);
      }
    }

    taskUrgent = listUrgent.length;

    for (var work in lisWorkSum) {
      if (StatusWorkingExtension.fromValue(work.status).isDynamic) {
        if (request != currentRequest) return;
        listDoing.add(work);
      }
    }
    taskDoing = listDoing.length;

    // final taskFollow = await _workingService.getAllTaskFollowing(user.id);
    listFollowing = [...lisWorkSum.where((e) => e.followers.contains(user.id))];
    taskFollowing = listFollowing.length;
    for (var e in listFollowing) {
      if (!mapWorkUnit.containsKey(e.id)) {
        mapWorkUnit[e.id] = e;
      }
      // if(!mapWorkChild.containsKey(e.id)) {
      //   final data = await _workingService.getWorkingUnitByIdParent(e.id);
      //   mapWorkChild[e.id] = [...data];
      // }
    }

    final List<ScopeModel> userScopes = [
      ...user.scopes
          .where((e) => cfC.allScopeMap[e] != null)
          .map((e) => cfC.allScopeMap[e]!)
    ];
    listUserScope = [...userScopes];

    // getFullTask(lisWorkSum, user.id);

    getDataScope();
    // final list
    // loadMeeting();

    listProject.clear();
    for (var scp in userScopes) {
      // await cfC.getDataWorkingUnitByScopeNewest(scp.id);
      final projects = cfC.allWorkingUnit
          .where((e) => e.scopes.contains(scp.id) && !e.closed)
          .toList();
      // final projects = await _workingService.getWorkingUnitByScopeId(scp.id);
      if (projects.isNotEmpty) {
        mapProjectInScope[scp.id] = projects
            .where((item) => item.type == TypeAssignmentDefine.epic.title)
            .toList();
        listProject.addAll(mapProjectInScope[scp.id]!);
        for (var prj in mapProjectInScope[scp.id]!) {
          mapWorkUnit[prj.id] = prj;
        }
      }
    }
    for (var e in listFollowing) {
      // if (!mapWorkUnit.containsKey(e.id)) {
      //   mapWorkUnit[e.id] = e;
      // }
      if (!mapWorkChild.containsKey(e.id)) {
        final data = cfC.allWorkingUnit.where((f) => f.parent == e.id).toList();
        // await _workingService.getWorkingUnitByIdParent(e.id);
        mapWorkChild[e.id] = [...data];
        for (var f in data) {
          cfC.addWorkingUnit(f, isLocal: true);
        }
      }
    }
    for (var work in lisWorkSum) {
      mapAddress[work.id] = findAddressDefault(work.parent);
    }
    mapScope = {...cfC.allScopeMap};
    EMIT();
  }

  List<WorkingUnitModel> findAddressDefault(String id) {
    if (id == "") return [];
    if (mapAddress.containsKey(id)) return mapAddress[id]!;
    List<WorkingUnitModel> tmp = [];
    final work = cfC.mapWorkingUnit[id];
    if (work != null) {
      tmp = findAddressDefault(work.parent);
      if (tmp.isNotEmpty) {
        mapAddress[id] = [...tmp];
      } else {
        mapAddress[id] = [];
      }
    } else {
      mapAddress[id] = [];
    }
    List<WorkingUnitModel> returnData = [...mapAddress[id]!];
    if (work != null) {
      returnData.insert(0, work);
    }
    return returnData;
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
