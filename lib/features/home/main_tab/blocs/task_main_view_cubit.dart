import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/sorted_list_name_define.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/sorted_service.dart';
import 'package:whms/untils/app_text.dart';

class TaskMainViewCubit extends Cubit<int> {
  TaskMainViewCubit() : super(0);

  final SortedService _sortedService = SortedService.instance;

  List<ScopeModel> listAllScope = [];
  List<ScopeModel> listScope = [];
  List<WorkingUnitModel> listWork = [];

  // Map<String, UserModel> listUser = {};
  Map<String, WorkingUnitModel> mapWorkId = {};
  Map<String, String> mapScopeId = {};
  Map<String, SortedModel> mapSorted = {};

  SortedModel currentSorted = SortedModel();

  int currentRequest = 0;
  int sumWorkingPoint = 0;

  String selectedScope = AppText.textPrivateKey.text;
  String selectedTask = "0";

  initData(
      BuildContext context, List<WorkingUnitModel> listData, List<ScopeModel> scp,String tab) async {
    final request = ++currentRequest;
    emit(0);
    selectedScope = AppText.textPrivateKey.text;
    listScope.clear();
    listAllScope.clear();
    listWork.clear();
    // listUser.clear();
    mapScopeId.clear();
    mapScopeId.clear();
    if (request != currentRequest) return;
    // ResponseModel<List<ScopeModel>> res =
    //     await ScopeService.instance.getListScope();
    if (request != currentRequest) return;
    // if (res.status == ResponseStatus.ok) {
    //   listAllScope = res.results!;
    // }
    listAllScope = [...scp];
    final user = ConfigsCubit.fromContext(context).user;
    for (var scp in user.scopes) {
      final scope = listAllScope.where((e) => e.id == scp).firstOrNull;
      if(scope == null) continue;
      listScope.add(scope);
      // final ResponseModel<ScopeModel> scope =
      //     await ScopeService.instance.getScopeById(scp);
      // if (request != currentRequest) return;
      // if (scope.status == ResponseStatus.ok) {
      //   if (scope.results != null) {
      //     listScope.add(scope.results!);
      //   }
      // }
    }
    if (request != currentRequest) return;
    listWork.clear();
    listWork = [...listData];

    for (var item in listScope) {
      mapScopeId[item.title] = item.id;
    }

    mapScopeId[AppText.textAll.text] = AppText.textPrivateKey.text;

    // for (var item in listWork) {
    //   for (var user in item.assignees) {
    //     if (!listUser.containsKey(user)) {
    //       final dataUser = await UserServices.instance.getUserById(user);
    //       if(request != currentRequest) return;
    //       if (dataUser != null) {
    //         listUser[user] = dataUser;
    //       }
    //     }
    //   }
    // }
    if (listWork.isNotEmpty) {
      selectedTask = listWork.first.id;
      for (var work in listWork) {
        if (!mapWorkId.containsKey(work.id)) {
          mapWorkId[work.id] = work;
        }
      }
    }

    listWork.sort((a, b) => a.createAt.compareTo(b.createAt));

    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }

    String listName = getListNameFromTab(tab);
    SortedModel? sorted;
    if (mapSorted['id_sorted_${user.id}_${listName}'] != null) {
      sorted = mapSorted['id_sorted_${user.id}_${listName}'];
    }
    else {
      sorted = await SortedService.instance
          .getSortedByUserAndListName(user.id, listName);
    }
    if (sorted != null) {
      List<WorkingUnitModel> taskInSorted = [];
      // for (var work in listWork) {
      //   final task = sorted.sorted.where((item) => item == work.id).firstOrNull;
      //   if (task != null) {
      //     taskInSorted.add(work);
      //   } else {
      //     taskOutSorted.add(work);
      //   }
      // }
      for (var work in sorted.sorted) {
        final task = listWork.where((item) => item.id == work).firstOrNull;
        if (task != null && !taskInSorted.contains(task)) {
          taskInSorted.add(task);
        }
      }
      List<WorkingUnitModel> tmp = [];
      for (var work in listWork) {
        if (!taskInSorted.contains(work) && !taskInSorted.contains(work)) {
          tmp.add(work);
        }
      }
      tmp.sort((a, b) => a.deadline.compareTo(b.deadline));
      taskInSorted.addAll(tmp);

      if (request != currentRequest) return;
      listWork.clear();
      listWork.addAll(taskInSorted);
      _sortedService.updateSorted(
          sorted.copyWith(sorted: listWork.map((item) => item.id).toList()));
    } else {
      String id = FirebaseFirestore.instance
          .collection('whms_pls_working_unit')
          .doc()
          .id;
      sorted = SortedModel(
          id: id,
          user: user.id,
          listName: listName,
          sorted: listWork.map((item) => item.id).toList(),
          enable: true);
      _sortedService.addNewSorted(sorted);
    }

    currentSorted = sorted;

    if (listWork.isNotEmpty) {
      selectedTask = listWork.first.id;
    }

    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }
    EMIT();
  }

  changeOrder(int index1, int index2) async {
    final tmp = listWork[index1];
    listWork.removeAt(index1);
    listWork.insert(index2, tmp);
    _sortedService.updateSorted(currentSorted.copyWith(
        sorted: listWork.map((item) => item.id).toList()));
  }

  changeScope(String value) {
    if (mapScopeId.containsKey(value)) {
      selectedScope = mapScopeId[value]!;
    } else {
      selectedScope = AppText.textPrivateKey.text;
    }
    EMIT();
  }

  updateListWork(List<WorkingUnitModel> listData) {
    listWork.clear();
    listWork.addAll(listData);
    for(var e in listData) {
      mapWorkId[e.id] = e;
    }
    if(!listWork.any((e) => e.id == selectedTask)) {
      selectedTask = listWork.firstOrNull?.id ?? "";
    }
    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }
    EMIT();
  }

  addWorkingUnit(WorkingUnitModel work) {
    if (!listWork.contains(work)) {
      listWork.add(work);
      mapWorkId[work.id] = work;
    }
    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }
    EMIT();
  }

  updateWorkingUnit(WorkingUnitModel work) {
    final workUM = listWork.indexWhere((item) => item.id == work.id);
    if (workUM != -1) {
      listWork[workUM] = work;
      mapWorkId[work.id] = work;
    }
    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }
    cntUpdateTask++;
    EMIT();
  }

  changeTask(String value) {
    selectedTask = value;
    EMIT();
  }

  getListNameFromTab(String tab) {
    switch (tab) {
      case "201":
        return SortedListNameDefine.task_today.title;
      case "206":
        return SortedListNameDefine.task_doing.title;
      case "202":
        return SortedListNameDefine.task_FTF.title;
      case "205":
        return SortedListNameDefine.task_urgent.title;
      case "203":
        return SortedListNameDefine.task_personal.title;
      case "204":
        return SortedListNameDefine.task_assign.title;
      default:
        return SortedListNameDefine.task_today.title;
    }
  }

  int cntUpdateTask = 0;

  updateTask(WorkingUnitModel work) {
    mapWorkId[work.id] = work;
    int index = listWork.indexWhere((e) => e.id == work.id);
    if (index != -1) {
      if (work.closed) {
        listWork.removeAt(index);
      } else {
        listWork[index] = work;
      }
      sumWorkingPoint = 0;
      for(var e in listWork) {
        sumWorkingPoint += max(0, e.workingPoint);
      }
      cntUpdateTask++;
    }
    EMIT();
  }

  removeTask(WorkingUnitModel work) {
    mapWorkId.remove(work.id);
    listWork.remove(work);
    cntUpdateTask++;
    sumWorkingPoint = 0;
    for(var e in listWork) {
      sumWorkingPoint += max(0, e.workingPoint);
    }
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}