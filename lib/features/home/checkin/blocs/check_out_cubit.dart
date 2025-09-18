import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/pair.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/function_utils.dart';

class CheckOutCubit extends Cubit<int> {
  CheckOutCubit(this.cfC) : super(0);

  int tab = 0;
  WorkShiftModel workShift = WorkShiftModel();
  List<WorkingUnitModel> listWorkAvailable = [];
  List<WorkingUnitModel> listWorkSelected = [];
  List<WorkingUnitModel> listWorkCheckOut = [];
  Map<String, WorkingUnitModel> mapWorkUnit = {};
  Map<String, List<WorkingUnitModel>> mapAddress = {};
  Map<String, int> mapWorkingTime = {};
  Map<String, String> mapWorkParent = {};
  Map<String, ScopeModel> mapScope = {};
  List<ScopeModel> listScope = [];
  bool isSelectedAll = false;
  DateTime timeResume = DateTime.now();
  DateTime timeCheckout = DateTime.now();
  DateTime timeBreak = DateTime.now();
  DateTime timeCheckIn = DateTime.now();

  late ConfigsCubit cfC;

  Map<WorkingUnitModel, List<WorkingUnitModel>> mapGroupTask = {};
  Map<String, WorkCheckOutModel> mapTaskCheckOutInfo = {};
  Map<String, Pair<String, bool>> mapCanEditDefaultSubtask = {};


  initData(BuildContext context) async {
    // final cfC = ConfigsCubit.fromContext(context);
    final workService = WorkingService.instance;
    final user = ConfigsCubit.fromContext(context).user;
    await cfC.getWorkShiftByUser(user.id, DateTimeUtils.getCurrentDate());
    // final workShift2 = await UserServices.instance
    //     .getWorkShiftByIdUserAndDate(user.id, DateTimeUtils.getCurrentDate());
    workShift = cfC.mapWorkShiftFromUserAndDate[
        '${user.id}_${DateTimeUtils.getCurrentDate()}']!;
    timeCheckIn = workShift.checkIn!.toDate();
    await cfC.getDataWorkingUnitNewest(cfC.user.id);
    final listWorkFull = cfC.allWorkingUnit
        .where((e) => e.assignees.contains(user.id) && !e.closed)
        .toList();
    final listWorkTask = listWorkFull
        .where((item) => item.type == TypeAssignmentDefine.subtask.title)
        .toList();

    mapWorkUnit.addAll(cfC.mapWorkingUnit);

    for (var work in listWorkFull) {
      mapWorkUnit[work.id] = work;
      mapWorkParent[work.id] = work.title;
    }

    listWorkAvailable.addAll(listWorkFull
        .where((item) => item.type == TypeAssignmentDefine.task.title)
        .toList());
    for (var work in listWorkTask) {
      mapAddress[work.id] = [];

      if (!mapWorkParent.containsKey(work.parent)) {
        WorkingUnitModel? workPar;
        if (cfC.mapWorkingUnit.containsKey(work.parent)) {
          workPar = cfC.mapWorkingUnit[work.parent];
        } else {
          // workPar = await workService.getWorkingUnitById(work.parent);
          // if (workPar != null) {
          //   cfC.addWorkingUnit(workPar);
          // }
        }
        if (workPar != null) {
          mapWorkParent[work.parent] = workPar.title;
          mapWorkUnit[work.parent] = workPar;
        }
      }
    }
    await cfC.getWorkFieldByWorkShift(workShift.id);
    final workAlreadySelected = cfC.mapWFfWS[workShift.id] ?? [];

    for (var work in workAlreadySelected) {
      WorkingUnitModel? workUnit =
          listWorkAvailable.where((item) => item.id == work.taskId).firstOrNull;
      if (workUnit != null) {
        listWorkAvailable.remove(workUnit);
      }
      workUnit = listWorkTask.where((item) => item.id == work.taskId).firstOrNull;
      if (workUnit != null) {
        listWorkSelected.add(workUnit.copyWith(status: work.toStatus));
        mapWorkingTime[workUnit.id] = work.duration;
        if (work.toStatus != work.fromStatus && !listWorkCheckOut.any((e) => e.id == listWorkSelected.last.id)) {
          listWorkCheckOut.add(listWorkSelected.last);
        }

      }

    }
    mapScope.addAll(cfC.allScopeMap);
    for (var scp in user.scopes) {
      final scope = cfC.allScopeMap[scp];
      if (scope != null) {
        listScope.add(scope);
      }
    }
    // auto select checkout
    for (var wf in workAlreadySelected) {
      WorkingUnitModel? work;
      if (mapWorkUnit.containsKey(wf.taskId)) {
        work = mapWorkUnit[wf.taskId];
      } else {
        if (cfC.mapWorkingUnit.containsKey(wf.taskId)) {
          work = cfC.mapWorkingUnit[wf.taskId];
        } else {
          work = await workService.getWorkingUnitByIdIgnoreClosed(wf.taskId);
          if (work != null) {
            cfC.addWorkingUnit(work);
          }
        }
        if (work != null) {
          mapWorkUnit[wf.taskId] = work;
        }
      }
      if (work == null) continue;
      if (wf.toStatus == StatusWorkingDefine.done.value &&
          work.status != StatusWorkingDefine.done.value && !listWorkCheckOut.any((e) => e.id == work?.id)) {
        listWorkCheckOut.add(work);
      }
    }
    await groupTask();
    EMIT();
    for (var work in listWorkTask) {
      mapAddress[work.id] = await findAddress(work.parent);
    }
    EMIT();
  }

  changeTab(int newTab) {
    if (newTab == tab) return;
    tab = newTab;
    EMIT();
  }

  selectWork(List<WorkingUnitModel> listAdd, BuildContext context) async {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    // final idWorkShift =
    //     await cfC.getWorkShiftByUser(idUser, DateTimeUtils.getCurrentDate());
    // final idWorkShift = await UserServices.instance
    //     .getWorkShiftByIdUserAndDate(idUser, DateTimeUtils.getCurrentDate());
    DialogUtils.showLoadingDialog(context);
    for (var item in listAdd) {
      if (listWorkAvailable.contains(item)) {
        listWorkAvailable.remove(item);
        if (checkIn == StatusCheckInDefine.checkIn) {
          addWorkToToday(item);
          for(var e in cfC.mapWorkChild[item.id] ?? []) {
            addWorkToToday(e);
            listWorkSelected.add(e);
          }
        }
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    tab = 0;
    await groupTask();
    emit(state + 1);
  }

  addWorkToToday(WorkingUnitModel item) async {
    final workField = await WorkingService.instance
        .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
        workShift.id, item.id);
    if (workField != null) {
      cfC.updateWorkField(workField.copyWith(enable: true), workField);
      // await WorkingService.instance.updateWorkField(
      //     workField.copyWith(enable: true));
    } else {
      mapWorkingTime[item.id] = 0;
      String id = FirebaseFirestore.instance
          .collection('daily_pls_work_field')
          .doc()
          .id;
      WorkFieldModel newWorkField = WorkFieldModel(
        id: id,
        taskId: item.id,
        fromStatus: item.status,
        toStatus: item.status,
        duration: mapWorkingTime[item.id]!,
        date: DateTimeUtils.getCurrentDate(),
        workShift: workShift.id,
        enable: true,
      );
      cfC.addWorkField(newWorkField);
      // await WorkingService.instance.addNewWorkField(newWorkField);
    }
  }

  removeWork(WorkingUnitModel work, BuildContext context) async {
    DialogUtils.showLoadingDialog(context);
    if (listWorkSelected.contains(work)) {
      listWorkAvailable.add(work);
      listWorkSelected.remove(work);
      if (listWorkCheckOut.contains(work)) {
        listWorkCheckOut.remove(work);
      }
      final workField = await WorkingService.instance
          .getWorkFieldByWorkShiftAndIdWork(workShift.id, work.id);
      if (workField != null) {
        cfC.updateWorkField(workField.copyWith(enable: false), workField);
        // await WorkingService.instance.updateWorkField(workField.copyWith(enable: false));
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    await groupTask();
    emit(state + 1);
  }

  updateWorkStatus(WorkingUnitModel work, BuildContext context) async {
    for (int i = 0; i < listWorkSelected.length; i++) {
      if (listWorkSelected[i].id == work.id) {
        listWorkSelected[i] = listWorkSelected[i].copyWith(status: work.status);
      }
    }
    DialogUtils.showLoadingDialog(context);
    final workField = await WorkingService.instance
        .getWorkFieldByWorkShiftAndIdWork(workShift.id, work.id);
    cfC.updateWorkField(workField!.copyWith(toStatus: work.status), workField);
    if(workField.fromStatus == work.status) {
      int index = listWorkCheckOut.indexWhere((e) => e.id == work.id);
      if(index != -1) {
        listWorkCheckOut.removeAt(index);
      }
    } else {
      if(!listWorkCheckOut.any((e) => e.id == work.id)) {
        listWorkCheckOut.add(work.copyWith(status: workField.fromStatus));
      }
    }
    // await WorkingService.instance
    //     .updateWorkField(workField!.copyWith(toStatus: work.status));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    groupTask();
    emit(state + 1);
  }

  changeWorkingTime(
      WorkingUnitModel work, int value, BuildContext context) async {

      mapWorkingTime[work.id] = value;
      DialogUtils.showLoadingDialog(context);
      final workField = await WorkingService.instance
          .getWorkFieldByWorkShiftAndIdWork(workShift.id, work.id);
      cfC.updateWorkField(workField!.copyWith(duration: value), workField);
      // await WorkingService.instance
      //     .updateWorkField(workField!.copyWith(duration: value));
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      groupTask();
      emit(state + 1);
  }

  selectWorkCheckOut(WorkingUnitModel work) {
    listWorkCheckOut.add(work);
    checkIsAll();
    EMIT();
  }

  removeWorkCheckOut(WorkingUnitModel work) {
    if (listWorkCheckOut.contains(work)) {
      listWorkCheckOut.remove(work);
      checkIsAll();
      EMIT();
    }
  }

  checkIsAll() {
    bool isAll = true;
    for (var work in listWorkSelected) {
      if (!listWorkCheckOut.contains(work)) {
        isAll = false;
        break;
      }
    }
    isSelectedAll = isAll;
  }

  changeSelectedAll() {
    if (isSelectedAll) {
      isSelectedAll = false;
      for (var work in listWorkSelected) {
        listWorkCheckOut.remove(work);
      }
    } else {
      for (var work in listWorkSelected) {
        if (!listWorkCheckOut.contains(work)) {
          listWorkCheckOut.add(work);
        }
      }
      isSelectedAll = true;
    }
    EMIT();
  }

  changeTimeResume(DateTime time) {
    timeResume = time;
    EMIT();
  }

  changeTimeCheckOut(DateTime time) {
    timeCheckout = time;
    if (time.isBefore(timeCheckIn)) {
      timeCheckout = timeCheckIn;
    }
    EMIT();
  }

  changeTimeBreak(DateTime time) {
    timeBreak = time;
    EMIT();
  }

  updateWorkShift(WorkShiftModel workS) {
    workShift = workS;
    EMIT();
  }

  groupTask() {
    mapGroupTask.clear();
    final other = WorkingUnitModel(title: AppText.textOther.text);
    for (var work in listWorkSelected) {
      WorkingUnitModel? workPar;
      if (cfC.mapWorkingUnit.containsKey(work.parent)) {
        workPar = cfC.mapWorkingUnit[work.parent];
      }
      // else {
      //   workPar = await WorkingService.instance.getWorkingUnitById(work.parent);
      //   if (workPar != null) {
      //     mapWorkUnit[work.parent] = workPar;
      //   }
      // }
      workPar ??= other;
      if (!mapGroupTask.containsKey(workPar)) {
        mapGroupTask[workPar] = [];
      }
      mapGroupTask[workPar]!.add(work);
    }
    final workFields = cfC.mapWFfWS[workShift.id] ?? [];
    mapGroupTask.forEach((k, v) {
      v.sort((a, b) => b.createAt.compareTo(a.createAt));
      final defaultSubtask = v.lastOrNull;
      bool canEdit = true;
      if(defaultSubtask != null) {
        for (var e in v) {
          if(e.id != defaultSubtask.id && e.status != StatusWorkingDefine.done.value) {
            canEdit = false;
            break;
          }
        }
        mapCanEditDefaultSubtask[k.id] = Pair<String, bool>(defaultSubtask.id, canEdit);
      }
      for (var e in v) {
        int status = FunctionUtils.getStatusTaskToday(e, v, workFields);
        int workingTime = 0;
        for (var f in v) {
          workingTime += mapWorkingTime[f.id] ?? 0;
        }
        mapTaskCheckOutInfo[k.id] = WorkCheckOutModel(
            status: status,
            workingPoint: max(k.workingPoint,0),
            workingTime: workingTime);
      }
    });
  }

  Future<List<WorkingUnitModel>> findAddress(String id) async {
    if (id == "") return [];
    if (mapAddress.containsKey(id)) return mapAddress[id]!;
    mapAddress[id] = [];
    List<WorkingUnitModel> tmp = [];
    WorkingUnitModel? work;
    if (cfC.mapWorkingUnit.containsKey(id)) {
      work = cfC.mapWorkingUnit[id];
    } else {
      work = await WorkingService.instance.getWorkingUnitById(id);
      if (work != null) {
        cfC.addWorkingUnit(work);
      }
    }
    if (work != null) {
      tmp = await findAddress(work.parent);
      if (tmp.isNotEmpty) {
        mapAddress[id] = [...tmp];
      }
      mapAddress[id]!.add(work);
    }
    return mapAddress[id]!;
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}

class WorkCheckOutModel {
  final int status;
  final int workingPoint;
  final int workingTime;

  WorkCheckOutModel({
    this.status = -1,
    this.workingPoint = 0,
    this.workingTime = 0,
  });

  WorkCheckOutModel copyWith({
    int? status,
    int? workingPoint,
    int? workingTime,
  }) {
    return WorkCheckOutModel(
      status: status ?? this.status,
      workingPoint: workingPoint ?? this.workingPoint,
      workingTime: workingTime ?? this.workingTime,
    );
  }
}
