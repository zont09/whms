import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';

class CheckInCubit extends Cubit<int> {
  CheckInCubit() : super(0);

  final WorkingService _workingService = WorkingService.instance;

  int tab = 0;
  Timestamp startTime = DateTimeUtils.getTimestampNow();
  Timestamp endTime = DateTimeUtils.getTimestampNow();
  List<WorkingUnitModel> listWorkAvailable = [];
  List<WorkingUnitModel> listWorkSelected = [];
  Map<String, int> mapWorkingTime = {};
  Map<String, List<WorkingUnitModel>> mapAddress = {};
  Map<String, String> mapWorkParent = {}; // id work -> title
  Map<String, ScopeModel> mapScope = {};
  Map<String, List<WorkingUnitModel>> mapWorkChild = {};
  List<ScopeModel> listScope = [];

  late ConfigsCubit cfC;

  int sortTitle = 0; // 1: a->z ; 2: z->a

  initData(BuildContext context, StatusCheckInDefine status) async {
    cfC = ConfigsCubit.fromContext(context);
    final now = DateTime.now();
    endTime = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 18));
    final user = ConfigsCubit.fromContext(context).user;
    await cfC.getDataWorkingUnitNewest(cfC.user.id);
    final listWorkFull = cfC.allWorkingUnit.where((e) => e.assignees.contains(user.id) && !e.closed).toList();
    final listWorkTask = listWorkFull
        .where((item) => item.type == TypeAssignmentDefine.task.title)
        .toList();
    for(var work in listWorkTask) {
      mapAddress[work.id] = [];
      // await findAddress(work.parent, work.id);

      // if(!mapWorkParent.containsKey(work.parent)) {
      //   final workPar = await workService.getWorkingUnitById(work.parent);
      //   if(workPar != null) {
      //     mapWorkParent[work.parent] = workPar.title;
      //   }
      // }
    }
    listWorkAvailable = listWorkTask;
    if (status != StatusCheckInDefine.notCheckIn) {
      // await initDataCheckout(idUser);
    }
    for (var scp in user.scopes) {
      final scope = cfC.allScopeMap[scp];
      if (scope != null) {
        listScope.add(scope);
        for(var scp in listScope) {
          if(mapScope[scp.id] == null) {
            mapScope[scp.id] = scp;
          }
        }
      }
    }

    mapScope.addAll(cfC.allScopeMap);

    // final getFullListScopes = await ScopeService.instance.getListScope() as ResponseModel<List<ScopeModel>>;
    // if (getFullListScopes.status == ResponseStatus.ok) {
    //   for(var scp in getFullListScopes.results!) {
    //     if(mapScope[scp.id] == null) {
    //       mapScope[scp.id] = scp;
    //     }
    //   }
    // }
    EMIT();

    for(var work in listWorkTask) {
      mapAddress[work.id] = [];
      await findAddress(work.parent, work.id);

      // if(!mapWorkParent.containsKey(work.parent)) {
      //   final workPar = await workService.getWorkingUnitById(work.parent);
      //   if(workPar != null) {
      //     mapWorkParent[work.parent] = workPar.title;
      //   }
      // }
    }


  }

  // initDataCheckout(String idUser) async {
  //   final workService = WorkingService.instance;
  //   final idWorkShift = await UserServices.instance
  //       .getWorkShiftByIdUserAndDate(idUser, DateTimeUtils.getCurrentDate());
  //   final workAlreadySelected =
  //       await workService.getWorkFieldByIdWorkShift(idWorkShift!.id);
  //   for (var work in workAlreadySelected) {
  //     WorkingUnitModel? workUnit =
  //         listWorkAvailable.where((item) => item.id == work.taskId).firstOrNull;
  //     if (workUnit != null) {
  //       listWorkAvailable.remove(workUnit);
  //       listWorkSelected.add(workUnit.copyWith(status: work.toStatus));
  //     }
  //   }
  //   startTime = idWorkShift.checkIn!;
  //   endTime = idWorkShift.checkOut!;
  // }

  selectWork(List<WorkingUnitModel> listAdd, BuildContext context) async {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    final idUser = ConfigsCubit.fromContext(context).user.id;
    final idWorkShift = await cfC.getWorkShiftByUser(idUser, DateTimeUtils.getCurrentDate());
    // final idWorkShift = await UserServices.instance
    //     .getWorkShiftByIdUserAndDate(idUser, DateTimeUtils.getCurrentDate());
    DialogUtils.showLoadingDialog(context);
    for (var item in listAdd) {
      if (listWorkAvailable.contains(item)) {
        listWorkAvailable.remove(item);
        listWorkSelected.add(item);
        mapWorkingTime[item.id] = 10;

        if(!mapWorkChild.containsKey(item.id)) {
          final works = await _workingService.getWorkingUnitByIdParent(item.id);
          mapWorkChild[item.id] = [];
          mapWorkChild[item.id]!.addAll(works);
        }

        if (checkIn == StatusCheckInDefine.checkIn) {
          String id = FirebaseFirestore.instance
              .collection('daily_pls_work_field')
              .doc()
              .id;
          WorkFieldModel newWorkField = WorkFieldModel(
            id: id,
            taskId: item.id,
            fromStatus: item.status,
            toStatus: item.status,
            duration: 0,
            date: DateTimeUtils.getCurrentDate(),
            workShift: idWorkShift!.id,
          );
          cfC.addWorkField(newWorkField);
          // await WorkingService.instance.addNewWorkField(newWorkField);
        }
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    tab = 0;
    emit(state + 1);
  }

  removeWork(WorkingUnitModel work) {
    if (listWorkSelected.contains(work)) {
      listWorkAvailable.add(work);
      listWorkSelected.remove(work);
    }
    emit(state + 1);
  }

  updateWorkStatus(WorkingUnitModel work) {
    for (int i = 0; i < listWorkSelected.length; i++) {
      if (listWorkSelected[i].id == work.id) {
        listWorkSelected[i] = listWorkSelected[i].copyWith(status: work.status);
      }
    }
    emit(state + 1);
  }

  changeWorkingTime(WorkingUnitModel work, int value) {
    if (value == 0) {
      removeWork(work);
    } else {
      mapWorkingTime[work.id] = value;
      emit(state + 1);
    }
  }

  changeStartTime(Timestamp time) {
    startTime = time;
    emit(state + 1);
  }

  changeEndTime(Timestamp time) {
    if (time.seconds < startTime.seconds) {
      endTime = startTime;
    } else {
      endTime = time;
    }
    emit(state + 1);
  }

  changeTab(int newTab) {
    tab = newTab;
    emit(state + 1);
  }

  findAddress(String id, String idTask) async {
    if(id == "") return;
    final work = await WorkingService.instance.getWorkingUnitById(id);
    if(work != null) {
      if(mapAddress.containsKey(idTask)) {
        mapAddress[idTask] = [...mapAddress[idTask]!, work];
      }
      else {
        mapAddress[idTask] = [work];
      }
      findAddress(work.parent, idTask);
    }
  }

  changeSortTitle() {
    if(sortTitle == 0) {
      sortTitle = 1;
    } else {
      sortTitle = 3 - sortTitle;
    }
    if(sortTitle == 1) {
      listWorkSelected.sort((a, b) => a.title.compareTo(b.title));
      listWorkAvailable.sort((a, b) => a.title.compareTo(b.title));
    } else {
      listWorkSelected.sort((a, b) => b.title.compareTo(a.title));
      listWorkAvailable.sort((a, b) => b.title.compareTo(a.title));
    }
    EMIT();
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}
