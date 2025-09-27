import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/features/home/main_tab/widgets/personal/history_card_widget.dart';


class WorkHistoryCubit extends Cubit<int> {
  WorkHistoryCubit(this.cfC) : super(0);

  final WorkingService _workingService = WorkingService.instance;

  List<WorkHistoryData> listHistory = [];
  Map<String, WorkHistoryData> mapWorkHistory = {};
  Map<String, WorkingUnitModel> mapWorkingUnit = {};
  Map<String, WorkShiftModel?> mapWorkShift = {};
  Map<String, List<HistoryTaskModel>> mapHistoryTask = {};
  List<WorkHistorySynthetic> listWorkSyn = [];
  Map<String, WorkHistorySynthetic> mapWHS = {};
  Map<String, List<WorkHistorySynthetic>> mapChildWHS = {};

  String modeView = AppText.textByDay.text;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  late ConfigsCubit cfC;

  int request = 0;

  initData(DateTime? start, DateTime? end) async {
    emit(0);
    mapWorkingUnit = {...cfC.mapWorkingUnit};

    if (start != null) {
      startTime = start;
    }
    if (end != null) {
      endTime = end;
    }

    int curRequest = ++request;
    listWorkSyn.clear();

    final user = cfC.user;

    listHistory.clear();
    for (DateTime date = startTime;
        date.isBefore(endTime.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      String idDate = DateTimeUtils.formatDateDayMonthYear(date);
      // if (mapWorkHistory[DateTimeUtils.formatDateDayMonthYear(date)] != null) {
      //   if (curRequest != request) return;
      //   listHistory
      //       .add(mapWorkHistory[DateTimeUtils.formatDateDayMonthYear(date)]!);
      //   continue;
      // }
      WorkShiftModel? workShift;
      if (mapWorkShift.containsKey("${user.id}_$date")) {
        workShift = mapWorkShift["${user.id}_$date"];
      } else {
        final ws = await cfC.getWorkShiftByUser(user.id, date);
        // final ws =
        //     await _userServices.getWorkShiftByIdUserAndDate(user.id, date);
        workShift = ws;
        mapWorkShift["${user.id}_$date"] = ws;
      }

      Map<String, HistoryTaskModel> mapWH = {};

      if (workShift != null) {
        if (workShift.status == StatusCheckInDefine.checkOut.value) {
          int logTime = 0;
          int duration = 0;
          int sumBreak = 0;

          DateTime ci = workShift.checkIn!.toDate();
          DateTime co = workShift.checkOut!.toDate();
          logTime = co.difference(ci).inMinutes.round();
          for (int i = 0; i < workShift.breakTimes.length; i++) {
            DateTime brk = workShift.breakTimes[i].toDate();
            DateTime rsm = workShift.resumeTimes[i].toDate();
            sumBreak += (rsm.difference(brk).inMinutes.round());
          }
          logTime -= sumBreak;

          // await cfC.getWorkFieldByWorkShift(workShift.id);
          final workFields = cfC.mapWFfWS[workShift.id] ?? [];
          // final workFields =
          //     await _workingService.getWorkFieldByIdWorkShift(workShift.id);
          for (var wf in workFields) {
            WorkingUnitModel work = WorkingUnitModel();
            if (mapWorkingUnit[wf.taskId] != null) {
              work = mapWorkingUnit[wf.taskId]!;
            } else {
              final workk = await _workingService
                  .getWorkingUnitByIdIgnoreClosed(wf.taskId);
              work = workk ?? WorkingUnitModel();
              mapWorkingUnit[wf.taskId] = work;
            }
            if (work.id.isEmpty ||
                work.type != TypeAssignmentDefine.subtask.title) continue;

            duration = duration +
                max(
                    // (getDurationFromStatus(wf.toStatus) -
                    //         getDurationFromStatus(wf.fromStatus)) ~/
                    //     100 *
                    //     work.duration,
                    wf.duration,
                    0);
            if (wf.fromStatus != wf.toStatus) {
              WorkingUnitModel? workPar;
              if (mapWorkingUnit.containsKey(work.parent)) {
                workPar = mapWorkingUnit[work.parent];
              } else {
                workPar = await _workingService
                    .getWorkingUnitByIdIgnoreClosed(work.parent);
                if (workPar != null) {
                  mapWorkingUnit[work.parent] = workPar;
                }
              }
              if(workPar == null) {
                workPar = WorkingUnitModel(title: AppText.textUnknown.text);
              }

              debugPrint("=====> check WHC: ${work.id} - ${workPar.title}");

              HistoryTaskModel tmp = HistoryTaskModel(
                  date: date,
                  work: workPar,
                  workingTime: max(
                      // (getDurationFromStatus(wf.toStatus) -
                      //         getDurationFromStatus(wf.fromStatus)) ~/
                      //     100 *
                      //     work.duration,
                      wf.duration,
                      0),
                  subtask: 1,
                  workingPoint: max(
                          (getDurationFromStatus(wf.toStatus) -
                                  getDurationFromStatus(wf.fromStatus)) ~/
                              100 *
                              work.workingPoint,
                          0) *
                      work.workingPoint);
              int index =
                  listWorkSyn.indexWhere((item) => item.work.id == workPar!.id);

              if (index != -1) {
                final temp = listWorkSyn[index];
                final newWorkSyn = temp.copyWith(
                    workingTime: temp.workingTime + tmp.workingTime,
                    workingPoint: temp.workingPoint + tmp.workingPoint,
                    toStatus: wf.toStatus);
                listWorkSyn[index] = newWorkSyn;
              } else {
                listWorkSyn.add(WorkHistorySynthetic(workPar, tmp.workingTime,
                    tmp.workingPoint, wf.fromStatus, wf.toStatus));
              }
              if (mapChildWHS[workPar.id] == null) {
                mapChildWHS[workPar.id] = [];
              }
              final tmp1 = mapChildWHS[workPar.id]!;
              final index2 = tmp1.indexWhere((item) => item.work.id == work.id);
              WorkHistorySynthetic? tempp;
              if (index2 != -1) {
                final temp = tmp1[index2];
                tempp = temp.copyWith(
                    workingTime: temp.workingTime + tmp.workingTime,
                    workingPoint: temp.workingPoint + tmp.workingPoint,
                    toStatus: wf.toStatus);
                tmp1[index2] = tempp;
              } else {
                tmp1.add(WorkHistorySynthetic(work, tmp.workingTime,
                    tmp.workingPoint, wf.fromStatus, wf.toStatus));
              }

              mapChildWHS[workPar.id] = tmp1;

              if (mapWH.containsKey(workPar.id)) {
                final newDT = mapWH[workPar.id]!;
                mapWH[workPar.id] = newDT.copyWith(
                    workingTime: newDT.workingTime + tmp.workingTime,
                    subtask: newDT.subtask + 1,
                    workingPoint: newDT.workingPoint + tmp.workingPoint);
              } else {
                mapWH[workPar.id] = tmp;
              }
            }
          }

          WorkHistoryData whd = WorkHistoryData(
              DateTimeUtils.formatDateDayMonthYear(date),
              DateTimeUtils.formatDuration(logTime),
              "$duration",
              mapWH.length,
              DateTimeUtils.convertTimestampToTime(workShift.checkIn!),
              DateTimeUtils.convertTimestampToTime(workShift.checkOut!),
              DateTimeUtils.formatDuration(sumBreak),
              Colors.white);
          if (curRequest != request) return;
          listHistory.add(whd);
          mapWorkHistory[whd.date] = whd;

          mapHistoryTask[idDate] = [];
          mapWH.forEach((key, value) {
            mapHistoryTask[idDate]!.add(value);
          });
        } else {
          if (date == DateTimeUtils.getCurrentDate()) {
            WorkHistoryData whd = WorkHistoryData(
                DateTimeUtils.formatDateDayMonthYear(date),
                workShift.status == StatusCheckInDefine.breakTime.value
                    ? AppText.textBreakTime.text
                    : AppText.titleDoing.text,
                "0",
                0,
                DateTimeUtils.convertTimestampToTime(workShift.checkIn!),
                "",
                "",
                Color(0xFF90ff8a));
            if (curRequest != request) return;
            listHistory.add(whd);
            mapWorkHistory[whd.date] = whd;
            continue;
          }
          WorkHistoryData whd = WorkHistoryData(
              DateTimeUtils.formatDateDayMonthYear(date),
              AppText.textNotPay.text,
              "0",
              0,
              DateTimeUtils.convertTimestampToTime(workShift.checkIn!),
              "",
              "",
              Color(0xFFfa6469));
          if (curRequest != request) return;
          listHistory.add(whd);
          mapWorkHistory[whd.date] = whd;
        }
      } else {
        if (date == DateTimeUtils.getCurrentDate()) {
          WorkHistoryData whd = WorkHistoryData(
              DateTimeUtils.formatDateDayMonthYear(date),
              AppText.textHaventStartYet.text,
              "0",
              0,
              "",
              "",
              "",
              Color(0xFFFFFFFF));
          if (curRequest != request) return;
          listHistory.add(whd);
          mapWorkHistory[whd.date] = whd;
          continue;
        }
        WorkHistoryData whd = WorkHistoryData(
            DateTimeUtils.formatDateDayMonthYear(date),
            AppText.textBreakFromWork.text,
            "0",
            0,
            "",
            "",
            "",
            const Color(0xFFfaea82));
        if (curRequest != request) return;
        listHistory.add(whd);
        mapWorkHistory[whd.date] = whd;
      }
    }

    EMIT();
  }

  changeTime(BuildContext context, String mode) {
    DateTime end = DateTimeUtils.getCurrentDate();
    DateTime start = end.subtract(const Duration(days: 2));
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
    initData(start, end);
  }

  changeMode(BuildContext context, String mode) {
    modeView = mode;
    // initData(context, null, null);
    EMIT();
  }

  updateWorkShift(WorkShiftModel model) {
    if (model.user != cfC.user.id) return;
    mapWorkShift["${model.user}_${model.date}"] = model;
    initData(startTime, endTime);
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
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
}

class HistoryTaskModel {
  final DateTime date;
  final WorkingUnitModel work;
  final int workingTime;
  final int subtask;
  final int workingPoint;

  HistoryTaskModel({
    required this.date,
    required this.work,
    required this.workingTime,
    required this.subtask,
    required this.workingPoint,
  });

  HistoryTaskModel copyWith({
    DateTime? date,
    WorkingUnitModel? work,
    int? workingTime,
    int? subtask,
    int? workingPoint,
  }) {
    return HistoryTaskModel(
      date: date ?? this.date,
      work: work ?? this.work,
      workingTime: workingTime ?? this.workingTime,
      subtask: subtask ?? this.subtask,
      workingPoint: workingPoint ?? this.workingPoint,
    );
  }
}

class WorkHistorySynthetic {
  final WorkingUnitModel work;
  final int workingTime;
  final int workingPoint;
  final int fromStatus;
  final int toStatus;

  WorkHistorySynthetic(this.work, this.workingTime, this.workingPoint,
      this.fromStatus, this.toStatus);

  WorkHistorySynthetic copyWith({
    WorkingUnitModel? work,
    int? workingTime,
    int? workingPoint,
    int? fromStatus,
    int? toStatus,
  }) {
    return WorkHistorySynthetic(
      work ?? this.work,
      workingTime ?? this.workingTime,
      workingPoint ?? this.workingPoint,
      fromStatus ?? this.fromStatus,
      toStatus ?? this.toStatus,
    );
  }
}
