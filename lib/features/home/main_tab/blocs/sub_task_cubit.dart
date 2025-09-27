import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/sorted_list_name_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/sorted_service.dart';

class SubTaskCubit extends Cubit<int> {
  SubTaskCubit() : super(0);

  final SortedService _sortedService = SortedService.instance;

  Map<String, SortedModel> mapSorted = {};

  List<WorkingUnitModel> listSubtask = [];
  List<String> listSubtaskToday = [];
  String subtaskSelected = "0";
  WorkingUnitModel? subtaskDF; // subtask default
  bool canEditDefaultTask = true;
  bool canCreateSubtask = true;
  SortedModel currentSorted = SortedModel();

  initData(WorkingUnitModel work, bool isToday, BuildContext context,
      UserModel user, List<WorkingUnitModel> listSub) async {
    // emit(0);
    canEditDefaultTask = true;
    listSubtask.clear();

    // listSubtask =
    // await WorkingService.instance.getWorkingUnitByIdParent(work.id);
    // final workShift = await UserServices.instance.getWorkShiftByIdUserAndDate(user.id, DateTimeUtils.getCurrentDate());
    // if(workShift != null && workShift.status != StatusCheckInDefine.checkOut.value) {
    //   List<WorkingUnitModel> tmpLW = [];
    //   final workField = await WorkingService.instance
    //       .getWorkFieldByIdWorkShift(workShift.id);
    //   for(var work in listSubtask) {
    //     final workCI = workField.where((item) => item.taskId == work.id).firstOrNull;
    //     if(workCI != null) {
    //       tmpLW.add(work.copyWith(status: workCI.toStatus));
    //     }
    //     else {
    //       tmpLW.add(work);
    //     }
    //   }
    listSubtask.clear();
    listSubtask.addAll(listSub);
    // }
    canCreateSubtask = true;
    listSubtask.sort((a, b) => a.createAt.compareTo(b.createAt));
    if (listSubtask.isNotEmpty) {
      subtaskDF = listSubtask.removeAt(0);
      listSubtask.add(subtaskDF!);
      if (subtaskDF!.status == StatusWorkingDefine.done.value) {
        canCreateSubtask = false;
      }
    }


    for (int i = 0; i < listSubtask.length - 1; i++) {
      if (listSubtask[i].status != StatusWorkingDefine.cancelled.value &&
          listSubtask[i].status != StatusWorkingDefine.done.value) {
        canEditDefaultTask = false;
        break;
      }
    }

    if (listSubtask.isNotEmpty) {}

    if (listSubtask.length == 1) {
      canEditDefaultTask = true;
    }

    if (isToday) {
      listSubtaskToday.clear();
      listSubtaskToday.addAll(listSub.map((e) => e.id));
    }
    // if (workShift != null && workShift.status != StatusCheckInDefine.checkOut.value) {
    //   List<WorkingUnitModel> tmp = [];
    //   final workField =
    //   await WorkingService.instance.getWorkFieldByIdWorkShift(workShift.id);
    //   for (var work in listSubtask) {
    //     final wf =
    //         workField
    //             .where((item) => item.taskId == work.id)
    //             .firstOrNull;
    //     if (wf != null) {
    //       tmp.add(work.copyWith(status: wf.toStatus));
    //       listSubtaskToday.add(work.id);
    //     } else if (!isToday) {
    //       tmp.add(work);
    //     }
    //   }
    //   listSubtask.clear();
    //   listSubtask.addAll(tmp);
    // }
    String listName = SortedListNameDefine.subtask.title;
    SortedModel? sorted;
    if (mapSorted['id_sorted_${user.id}_${listName}=${work.id}'] != null) {
      sorted = mapSorted['id_sorted_${user.id}_${listName}=${work.id}'];
    } else {
      sorted = await SortedService.instance
          .getSortedByUserAndListName(user.id, "${listName}=${work.id}");
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
        final task = listSubtask.where((item) => item.id == work).firstOrNull;
        if (task != null && !taskInSorted.contains(task)) {
          taskInSorted.add(task);
        }
      }
      for (var work in listSubtask) {
        if (!taskInSorted.contains(work)) {
          taskInSorted.add(work);
        }
      }
      listSubtask.clear();
      listSubtask.addAll(taskInSorted);

      _sortedService.updateSorted(
          sorted.copyWith(sorted: listSubtask.map((item) => item.id).toList()));
    } else {
      String id = FirebaseFirestore.instance
          .collection('whms_pls_working_unit')
          .doc()
          .id;
      sorted = SortedModel(
          id: id,
          user: user.id,
          listName: "${listName}=${work.id}",
          sorted: listSubtask.map((item) => item.id).toList(),
          enable: true);
      _sortedService.addNewSorted(sorted);
    }

    currentSorted = sorted;
    if (listSubtask.isNotEmpty) {
      subtaskSelected = listSubtask.first.id;
    }
    EMIT();
  }

  selectedSubtask(String subtask) {
    subtaskSelected = subtask;
    EMIT();
  }

  changeOrder(int index1, int index2) async {
    WorkingUnitModel tmp = listSubtask[index1];
    listSubtask.removeAt(index1);
    listSubtask.insert(index2, tmp);
    await _sortedService.updateSorted(currentSorted.copyWith(
        sorted: listSubtask.map((item) => item.id).toList()));
  }

  addSubtask(WorkingUnitModel work) {
    listSubtask.add(work);
    if (listSubtaskToday.isNotEmpty) {
      listSubtaskToday.add(work.id);
    }
    EMIT();
  }

  removeSubtask(WorkingUnitModel work) {
    listSubtask.remove(work);
    listSubtaskToday.remove(work.id);
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
