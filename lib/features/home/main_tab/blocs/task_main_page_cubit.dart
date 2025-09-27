import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/sorted_list_name_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/sorted_service.dart';
import 'package:whms/untils/app_text.dart';

import '../../checkin/blocs/select_work_cubit.dart' as FunctionUtils;

class TaskMainPageCubit extends Cubit<int> {
  TaskMainPageCubit(this.cfC) : super(0);

  List<WorkingUnitModel> listTask = [];
  List<WorkingUnitModel> listShow = [];
  List<String> sorted = [];

  SortedModel? sortSave;

  String filterStatusTask = AppText.textByUnFinished.text;
  String filterStatusClosed = AppText.textOpened.text;
  ScopeModel filterScope = ScopeModel(title: AppText.textAll.text);
  final TextEditingController searchCon = TextEditingController();

  int loadingTaskClosed = 0;
  final ScopeModel scopeFull = ScopeModel(title: AppText.textAll.text);
  late ConfigsCubit cfC;

  initData(BuildContext context, List<WorkingUnitModel> listData, List<String> sort)  {
    listTask.clear();
    listShow.clear();
    listTask.addAll(listData.where((e) => e.assignees.contains(cfC.user.id)));
    listShow.addAll(listData.where((e) => e.assignees.contains(cfC.user.id)));
    filterScope = scopeFull;
    sorted = [...sort];
    final user = ConfigsCubit.fromContext(context).user;
    // await getDataTaskClosed(cfC.user.id);
    getFullTask(user.id);
    changeStatusTask(AppText.textByUnFinished.text);
    EMIT();
  }

  getFullTask(String idU)  {
    final SortedService sortedService = SortedService.instance;
    final sortedFb = null;
    // = await sortedService.getSortedByUserAndListName(
    //     idU, SortedListNameDefine.task.title);
    if (sortedFb == null) {
      sorted = listTask.map((e) => e.id).toList();
      sortSave = SortedModel(
          id: FirebaseFirestore.instance
              .collection("whms_pls_sorted")
              .doc()
              .id,
          user: idU,
          listName: SortedListNameDefine.task.title,
          sorted: sorted,
          enable: true);
      sortedService.addNewSorted(sortSave!);
    } else {
      sortSave = sortedFb;
      List<WorkingUnitModel> tmp = [];
      sorted = sortedFb.sorted;
      for(var e in sorted) {
        int index = listTask.indexWhere((item) => item.id == e);
        if(index != -1 && tmp.contains(listTask[index])) {
          tmp.add(listTask[index]);
        }
      }
      for(var e in listTask) {
        if(!tmp.contains(e)) {
          tmp.add(e);
        }
      }
      List<String> newSorted = tmp.map((e) => e.id).toList();
      sortedService.updateSorted(sortedFb.copyWith(sorted: newSorted));
      sorted = [...newSorted];
      listTask = [...tmp];
    }
  }

  getDataTaskClosed(String idUser) async {
    if (loadingTaskClosed == -1) return;
    loadingTaskClosed++;
    EMIT();
    await cfC.getDataWorkingUnitClosedNewest(cfC.user.id);
    // final tasksClosed =
    //     await _workingService.getAllWorkingUnitOfUserByClosed(idUser);
    listTask.clear();
    listTask.addAll(cfC.allWorkingUnit.where((e) => e.assignees.contains(cfC.user.id) && e.type == TypeAssignmentDefine.task.title));
    loadingTaskClosed = -1;
    updateStatusClosed(listTask);
  }

  List<WorkingUnitModel> updateStatusTask(List<WorkingUnitModel> listData) {
    List<WorkingUnitModel> listTmp = [];
    if (filterStatusTask == AppText.textAll.text) {
      listTmp.addAll(listData);
    } else if (filterStatusTask == AppText.textByUnFinished.text) {
      for (var e in listData) {
        if (e.isDoing) {
          listTmp.add(e);
        }
      }
    } else if (filterStatusTask == AppText.textByFinished.text) {
      for (var e in listData) {
        if (e.isFinished) {
          listTmp.add(e);
        }
      }
    } else if (filterStatusTask == AppText.titleDoing.text) {
      for (var e in listData) {
        if (StatusWorkingExtension.fromValue(e.status).isDynamic) {
          listTmp.add(e);
        }
      }
    } else if (filterStatusTask == AppText.textNone.text) {
      for (var e in listData) {
        if (e.status == StatusWorkingDefine.none.value) {
          listTmp.add(e);
        }
      }
    } else if (filterStatusTask == AppText.textCancelled.text) {
      for (var e in listData) {
        if (e.status == StatusWorkingDefine.cancelled.value) {
          listTmp.add(e);
        }
      }
    }
    return listTmp;
  }

  List<WorkingUnitModel> updateStatusClosed(List<WorkingUnitModel> listData) {
    List<WorkingUnitModel> listTmp = [];
    if (filterStatusClosed == AppText.textAll.text) {
      listTmp.addAll(listData);
    } else if (filterStatusClosed == AppText.textClosed.text) {
      for (var e in listData) {
        if (e.closed) {
          listTmp.add(e);
        }
      }
    } else if (filterStatusClosed == AppText.textOpened.text) {
      for (var e in listData) {
        if (!e.closed) {
          listTmp.add(e);
        }
      }
    }
    return listTmp;
  }

  List<WorkingUnitModel> updateScope(List<WorkingUnitModel> listData) {
    List<WorkingUnitModel> listTmp = [];
    if (filterScope.title == AppText.textAll.text) {
      listTmp.addAll(listData);
    } else {
      for (var e in listData) {
        if (e.scopes.contains(filterScope.id)) {
          listTmp.add(e);
        }
      }
    }
    return listTmp;
  }

  List<WorkingUnitModel> updateSearchTask(List<WorkingUnitModel> listData) {
    List<WorkingUnitModel> listTmp = [];
    if (searchCon.text.isEmpty || searchCon.text == "") {
      listTmp.addAll(listData);
    } else {
      for (var e in listData) {
        if (FunctionUtils.formatStringVN(e.title)
            .contains(FunctionUtils.formatStringVN(searchCon.text))) {
          listTmp.add(e);
        }
      }
    }
    return listTmp;
  }

  changeStatusTask(String newS) {
    filterStatusTask = newS;
    updateListShow();
  }

  changeStatusClosed(String newS) {
    filterStatusClosed = newS;
    updateListShow();
  }

  changeScope(ScopeModel scp) {
    filterScope = scp;
    updateListShow();
  }

  changeSearchField(String newV) {
    updateListShow();
  }

  updateOrder() {
    List<WorkingUnitModel> tmp = [];
    for(var e in sorted) {
      int index = listShow.indexWhere((i) => i.id == e);
      if(index != -1) {
        tmp.add(listShow[index]);
      }
    }
    for(var e in listShow) {
      if(!tmp.contains(e)) {
        tmp.add(e);
      }
    }
    listShow = [...tmp];
  }

  updateListShow() {
    listShow.clear();
    List<WorkingUnitModel> listTmp = [];
    listTmp.addAll(updateStatusClosed(listTask));
    listTmp = [...updateStatusTask(listTmp)];
    listTmp = [...updateScope(listTmp)];
    listTmp = [...updateSearchTask(listTmp)];
    listShow.addAll(listTmp);
    updateOrder();
    EMIT();
  }

  updateTask(WorkingUnitModel task) {
    int index = listTask.indexWhere((e) => e.id == task.id);
    if(index != -1) {
      listTask[index] = task.copyWith();
      changeStatusTask(filterStatusTask);
    }
  }

  changeOrder(int index1, int index2) async {
    final tmp = listShow[index1];
    String item = tmp.id;
    listShow.removeAt(index1);
    listShow.insert(index2, tmp);
    if(index2 == 0) {
      sorted.remove(item);
      sorted.insert(0, item);
    } else {
      int index = sorted.indexWhere((e) => e == listShow[index2 - 1].id);
      if(index != -1) {
        sorted.insert(index + 1, item);
        for(int i = 0; i < sorted.length; i++) {
          if(sorted[i] == item && i != index + 1) {
            sorted.removeAt(i);
            break;
          }
        }
      }
    }
    await SortedService.instance.updateSorted(sortSave!.copyWith(sorted: sorted));
    updateListShow();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
