import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';

class CachesRepository {
  CachesRepository._private();

  static final CachesRepository instance = CachesRepository._private();

  List<WorkingUnitModel> allWorkingUnit = [];
  Map<String, WorkingUnitModel> mapWorkingUnit = {};
  Map<String, List<WorkingUnitModel>> mapWorkChild = {};
//
  List<WorkShiftModel> allWorkShifts = [];
  Map<String, WorkShiftModel> mapWorkShift = {};
  Map<String, WorkShiftModel> mapWorkShiftFromUserAndDate = {};
  List<WorkFieldModel> allWorkFields = [];
  Map<String, WorkFieldModel> mapWorkField = {};
  Map<String, List<WorkFieldModel>> mapWFfWS = {};

  // =================== WORKING UNIT ===================
  addWorkingUnit(WorkingUnitModel model) {
    if(model.enable && !allWorkingUnit.any((e) => e.id == model.id)) {
      allWorkingUnit.add(model);
      mapWorkingUnit[model.id] = model;
      if(model.parent.isEmpty) return;
      List<WorkingUnitModel> tmp = mapWorkChild[model.parent] ?? [];
      mapWorkChild[model.parent] = [...tmp, model];
    }
  }

  updateWorkingUnit(WorkingUnitModel model) {
    int index = allWorkingUnit.indexWhere((e) => e.id == model.id);
    if(index != -1) {
      if(model.enable) {
        allWorkingUnit[index] = model;
        mapWorkingUnit[model.id] = model;
        List<WorkingUnitModel> tmp = mapWorkChild[model.id] ?? [];
        int idx2 = tmp.indexWhere((e) => e.id == model.id);
        if(idx2 != -1) {
          tmp[idx2] = model;
          mapWorkChild[model.parent] = [...tmp];
        }
      } else {
        allWorkingUnit.removeAt(index);
        mapWorkingUnit.remove(model.id);
        if(model.parent.isEmpty) return;
        List<WorkingUnitModel> tmp = mapWorkChild[model.id] ?? [];
        int idx2 = tmp.indexWhere((e) => e.id == model.id);
        if(idx2 != -1) {
          tmp.removeAt(idx2);
        }
        mapWorkChild[model.parent] = [...tmp];
      }
    }
  }

  // =================== WORKING SHIFT ===================

  addWorkingShift(WorkShiftModel model) {
    if(!allWorkShifts.any((e) => e.id == model.id)) {
      allWorkShifts.add(model);
      mapWorkShift["${model.user}_${model.date}"] = model;
      mapWorkShiftFromUserAndDate["${model.user}_${model.date}"] = model;
    }
  }

  updateWorkingShift(WorkShiftModel model) {
    int index = allWorkShifts.indexWhere((e) => e.id == model.id);
    if(index != -1) {
      allWorkShifts[index] = model;
      mapWorkShift["${model.user}_${model.date}"] = model;
      mapWorkShiftFromUserAndDate["${model.user}_${model.date}"] = model;
    }
  }

  // =================== WORKING FIELD ===================

  addWorkingField(WorkFieldModel model) {
    if(model.enable && !allWorkFields.any((e) => e.id == model.id)) {
      allWorkFields.add(model);
      mapWorkField[model.id] = model;
      if(model.workShift.isEmpty) return;
      List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
      mapWFfWS[model.workShift] = [...tmp, model];
    }
  }

  updateWorkingField(WorkFieldModel model) {
    int index = allWorkFields.indexWhere((e) => e.id == model.id);
    if(index != -1) {
      if(model.enable) {
        allWorkFields[index] = model;
        mapWorkField[model.id] = model;
        List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
        int idx2 = tmp.indexWhere((e) => e.id == model.id);
        if(idx2 != -1) {
          tmp[idx2] = model;
          mapWFfWS[model.workShift] = [...tmp];
        }
      } else {
        allWorkFields.removeAt(index);
        mapWorkField.remove(model.id);
        if(model.workShift.isEmpty) return;
        List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
        int idx2 = tmp.indexWhere((e) => e.id == model.id);
        if(idx2 != -1) {
          tmp.removeAt(idx2);
        }
        mapWFfWS[model.workShift] = [...tmp];
      }
    }
  }

}
