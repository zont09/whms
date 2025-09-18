import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';

class SelectWorkCubit extends Cubit<int> {
  SelectWorkCubit(this.cfC) : super(0);

  int tab = 0;
  bool isSelectedAll = false;
  ScopeModel? selectedScope;
  final TextEditingController searchController = TextEditingController();
  List<WorkingUnitModel> selectWork = [];
  List<WorkingUnitModel> listCanChoose = [];
  List<WorkingUnitModel> listShow = [];
  List<ScopeModel> listScope = [];
  Map<String, ScopeModel> mapScope = {};
  Map<String, String> mapParent = {};
  WorkingUnitModel? workSelected;
  bool isSelectOne = false;

  int sortTitle = 0; // 1: a->z ; 2: z->a
  String filterStatus = AppText.titleDoing.text;

  late ConfigsCubit cfC;

  initData(List<WorkingUnitModel>? listData, List<ScopeModel>? listScp,
      Map<String, String>? mapPar,
      {bool selectOne = false, BuildContext? ctx}) async {
    listCanChoose.clear();
    listShow.clear();
    selectWork.clear();
    mapParent.clear();

    if (listData != null) {
      for(var e in listData) {
        debugPrint("=====> Check data select work: ${e.title} - ${e.id}");
      }
      listCanChoose.addAll(listData);
      listShow.addAll(listData);
    } else {
      final user = ConfigsCubit.fromContext(ctx!).user;
      final listTaskFull = cfC.allWorkingUnit.where((e) => !e.closed && e.assignees.contains(user.id)).toList();
      // await workingService.getWorkingUnitByIdUser(user.id);
      List<WorkingUnitModel> listSubtask = listTaskFull
          .where((item) => item.type == TypeAssignmentDefine.task.title)
          .toList();
      final workShift = await cfC.getWorkShiftByUser(user.id, DateTimeUtils.getCurrentDate());
      // final workShift = await UserServices.instance
      //     .getWorkShiftByIdUserAndDate(user.id, DateTimeUtils.getCurrentDate());
      List<WorkFieldModel> listWorkField = [];
      if(workShift != null) {
        await cfC.getWorkFieldByWorkShift(workShift.id);
        listWorkField = cfC.mapWFfWS[workShift.id] ?? [];
      }

      for (var wf in listWorkField) {
        final workSD =
            listSubtask.where((item) => item.id == wf.taskId).firstOrNull;
        if (workSD != null) {
          listSubtask.remove(workSD);
        }
      }
      listCanChoose.addAll(listSubtask);
      listShow.addAll(listSubtask);
    }

    changeStatusFilter(AppText.titleDoing.text);

    if (listScp != null) {
      listScope = listScp;
    } else {
      for (var work in listCanChoose) {
        for (var scp in work.scopes) {
          final resScope = await ScopeService.instance.getScopeById(scp)
              as ResponseModel<ScopeModel>;
          if (resScope.status == ResponseStatus.ok &&
              resScope.results != null &&
              !listScope.any((item) => item.id == resScope.results!.id)) {
            listScope.add(resScope.results!);
          }
        }
      }
      // ResponseModel<List<ScopeModel>> res =
      // await ScopeService.instance.getListScope();
      // if (res.status == ResponseStatus.ok) {
      //   listScope = res.results!;
      // } else {
      //   listScope = [];
      // }
    }

    if (mapPar != null) {
      mapParent.addAll(mapPar);
    } else {
      for (var work in listCanChoose) {
        final workPar =
            await WorkingService.instance.getWorkingUnitById(work.parent);
        if (workPar != null && !mapParent.containsKey(workPar.id)) {
          mapParent[workPar.id] = workPar.title;
        }
      }
    }

    isSelectOne = selectOne;
    for (var scope in listScope) {
      if (!mapScope.containsKey(scope.title)) {
        mapScope[scope.title] = scope;
      }
    }
    EMIT();
  }

  changeSelectedAll() {
    if (isSelectedAll) {
      isSelectedAll = false;
      for (var work in listShow) {
        selectWork.remove(work);
      }
    } else {
      for (var work in listShow) {
        if (!selectWork.contains(work)) {
          selectWork.add(work);
        }
      }
      isSelectedAll = true;
    }
    EMIT();
  }

  selectedWork(WorkingUnitModel work) {
    if (isSelectOne) {
      if (work == workSelected) {
        workSelected = null;
      } else {
        workSelected = work;
      }
    } else {
      selectWork.add(work);
      checkIsAll();
    }
    EMIT();
  }

  removeWork(WorkingUnitModel work) {
    selectWork.remove(work);
    isSelectedAll = false;
    EMIT();
  }

  changeScope(String scope) {
    if (scope == AppText.textAll.text && searchController.text.isEmpty) {
      selectedScope = null;
      listShow.clear();
      listShow.addAll(listCanChoose);
    } else {
      selectedScope = mapScope[scope];
      listShow.clear();
      for (var work in listCanChoose) {
        if ((selectedScope == null ||
                work.scopes.contains(selectedScope!.id)) &&
            (searchController.text.isEmpty ||
                work.title.contains(searchController.text))) {
          listShow.add(work);
        }
      }
    }
    checkIsAll();
    EMIT();
  }

  bool isStatusCorrect(String status, WorkingUnitModel work) {
    if (filterStatus == AppText.textAll.text) return true;
    if (filterStatus == AppText.titleDoing.text &&
        StatusWorkingExtension.fromValue(work.status).isDynamic) return true;
    if (filterStatus == AppText.textByFinished.text && work.isFinished) {
      return true;
    }
    if (filterStatus == AppText.textNone.text &&
        work.status == StatusWorkingDefine.none.value) return true;
    return false;
  }

  changeStatusFilter(String newS) {
    filterStatus = newS;
    if (filterStatus == AppText.textAll.text && searchController.text.isEmpty) {
      listShow.clear();
      listShow.addAll(listCanChoose);
    } else {
      listShow.clear();
      for (var work in listCanChoose) {
        if (isStatusCorrect(filterStatus, work) &&
            (searchController.text.isEmpty ||
                work.title.contains(searchController.text))) {
          listShow.add(work);
        }
      }
    }
    checkIsAll();
    EMIT();
  }

  changeSearchField(String value) {
    if (value.isEmpty && filterStatus == AppText.textAll.text) {
      listShow.clear();
      listShow.addAll(listCanChoose);
    } else {
      listShow.clear();
      for (var work in listCanChoose) {
        if (isStatusCorrect(filterStatus, work) &&
            (value.isEmpty ||
                formatStringVN(work.title).contains(formatStringVN(value)) ||
                (mapParent[work.parent] != null &&
                    formatStringVN(mapParent[work.parent]!)
                        .contains(formatStringVN(value))))) {
          listShow.add(work);
        }
      }
    }
    searchController.text = value;
    checkIsAll();
    EMIT();
  }

  changeSortTitle() {
    if(sortTitle == 0) {
      sortTitle = 1;
    } else {
      sortTitle = 3 - sortTitle;
    }
    if(sortTitle == 1) {
      listShow.sort((a, b) => a.title.compareTo(b.title));
      listCanChoose.sort((a, b) => a.title.compareTo(b.title));
      selectWork.sort((a, b) => a.title.compareTo(b.title));
    } else {
      listShow.sort((a, b) => b.title.compareTo(a.title));
      listCanChoose.sort((a, b) => b.title.compareTo(a.title));
      selectWork.sort((a, b) => b.title.compareTo(a.title));
    }
    EMIT();
  }

  checkIsAll() {
    bool isAll = true;
    for (var work in listShow) {
      if (!selectWork.contains(work)) {
        isAll = false;
        break;
      }
    }
    isSelectedAll = isAll;
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}

String formatStringVN(String input) {
  const vietnameseChars =
      'ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơỲÝỴỶỸỳýỵỷỹƯỨỰỪỬỮưứựừửữÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜèéêëìíîïòóôõöùúûüÇç';
  const asciiChars =
      'AAAAEEEIIOOOOUUADIOUaaaaeeeiioooouuadioUYYYYyyyyUUUUuuuuuEEEEIIIIOOOOOUUUUeeeeiiiiooooouuuuCc';

  String normalized = input.split('').map((char) {
    int index = vietnameseChars.indexOf(char);
    return index != -1 ? asciiChars[index] : char;
  }).join('');

  return normalized.toLowerCase();
}
