import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachesRepository {
  CachesRepository._private();

  static final CachesRepository instance = CachesRepository._private();
//
//   List<WorkShiftModel> allWorkShifts = [];
//   Map<String, WorkShiftModel> mapWorkShift = {};
//   Map<String, WorkShiftModel> mapWorkShiftFromUserAndDate = {};
//   List<WorkFieldModel> allWorkFields = [];
//   Map<String, WorkFieldModel> mapWorkField = {};
//   Map<String, List<WorkFieldModel>> mapWFfWS = {};
//
//   List<QuoteModel> allQuotes = [];
//   Map<String, QuoteModel> mapQuote = {};
//
//   // =================== STAFF CHECKLIST ===================
//
//   updateChecklistItem(StaffChecklistItemModel model) {
//     int index = allChecklistItems.indexWhere((e) => e.id == model.id);
//     if (index != -1) {
//       if (!model.enable) {
//         allChecklistItems.removeAt(index);
//         mapChecklistItem.remove(model.id);
//       } else {
//         allChecklistItems[index] = model;
//         mapChecklistItem[model.id] = model;
//       }
//     }
//   }
//
//   addChecklistItem(StaffChecklistItemModel model) {
//     allChecklistItems.add(model);
//     mapChecklistItem[model.id] = model;
//   }
//
//   updateChecklistTemplate(StaffChecklistTemplateModel model) {
//     int index = allChecklistTemplates.indexWhere((e) => e.id == model.id);
//     if (index != -1) {
//       if (!model.enable) {
//         allChecklistTemplates.removeAt(index);
//       } else {
//         allChecklistTemplates[index] = model;
//       }
//     }
//   }
//
//   addChecklistTemplate(StaffChecklistTemplateModel model) {
//     allChecklistTemplates.add(model);
//   }
//
//   Future<void> saveChecklistTemplates(
//       List<StaffChecklistTemplateModel> templates,
//       SharedPreferences prefs) async {
//     final List<String> jsonList =
//         templates.map((template) => jsonEncode(template.toJson())).toList();
//     await prefs.setStringList('staff_checklist_templates', jsonList);
//   }
//
//   Future<void> loadChecklistTemplates(SharedPreferences prefs) async {
//     final List<String>? jsonList =
//         prefs.getStringList('staff_checklist_templates');
//     if (jsonList == null || jsonList.isEmpty) {
//       return;
//     }
//     final data = jsonList
//         .map((jsonString) =>
//             StaffChecklistTemplateModel.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     allChecklistTemplates.clear();
//     allChecklistTemplates.addAll(data);
//   }
//
//   Future<void> saveChecklistItems(
//       List<StaffChecklistItemModel> templates, SharedPreferences prefs) async {
//     final List<String> jsonList =
//         templates.map((template) => jsonEncode(template.toJson())).toList();
//
//     await prefs.setStringList('staff_checklist_items', jsonList);
//   }
//
//   Future<void> loadChecklistItems(SharedPreferences prefs) async {
//     final List<String>? jsonList = prefs.getStringList('staff_checklist_items');
//
//     if (jsonList == null || jsonList.isEmpty) {
//       return;
//     }
//     final data = jsonList
//         .map((jsonString) =>
//             StaffChecklistItemModel.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     for (var e in data) {
//       mapChecklistItem[e.id] = e;
//     }
//     allChecklistItems.clear();
//     allChecklistItems.addAll(data);
//   }
//
// // =================== PROCESS ===================
//   updateProcess(ProcessModel model) {
//     int index = allProcess.indexWhere((e) => e.id == model.id);
//     if (index != -1) {
//       if (!model.enable) {
//         allProcess.removeAt(index);
//       } else {
//         allProcess[index] = model;
//       }
//     }
//   }
//
//   addProcess(ProcessModel model) {
//     if(model.enable) {
//       allProcess.add(model);
//     }
//   }
//
//   Future<void> saveProcess(
//       List<ProcessModel> process, SharedPreferences prefs) async {
//     final List<String> jsonList =
//         process.map((e) => jsonEncode(e.toJson())).toList();
//     await prefs.setStringList('process', jsonList);
//   }
//
//   Future<void> loadProcess(SharedPreferences prefs) async {
//     final List<String>? jsonList =
//         prefs.getStringList('process');
//     if (jsonList == null || jsonList.isEmpty) {
//       return;
//     }
//     final data = jsonList
//         .map((jsonString) =>
//             ProcessModel.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     allProcess.clear();
//     allProcess.addAll(data);
//   }
//
//   updateProcessItems(ProcessItemModel model) {
//     int index = allProcessItems.indexWhere((e) => e.id == model.id);
//     if (index != -1) {
//       if (!model.enable) {
//         allProcessItems.removeAt(index);
//       } else {
//         allProcessItems[index] = model;
//       }
//     }
//   }
//
//   addProcessItem(ProcessItemModel model) {
//     if(model.enable) {
//       allProcessItems.add(model);
//     }
//   }
//
//   Future<void> saveProcessItem(
//       List<ProcessItemModel> process, SharedPreferences prefs) async {
//     final List<String> jsonList =
//     process.map((e) => jsonEncode(e.toJson())).toList();
//     await prefs.setStringList('process_item', jsonList);
//   }
//
//   Future<void> loadProcessItem(SharedPreferences prefs) async {
//     final List<String>? jsonList =
//     prefs.getStringList('process_item');
//     if (jsonList == null || jsonList.isEmpty) {
//       return;
//     }
//     final data = jsonList
//         .map((jsonString) =>
//         ProcessItemModel.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     allProcessItems.clear();
//     allProcessItems.addAll(data);
//   }
//
//   updateProcessResults(ProcessResultModel model) {
//     int index = allProcessResult.indexWhere((e) => e.id == model.id);
//     if (index != -1) {
//       if (!model.enable) {
//         allProcessResult.removeAt(index);
//       } else {
//         allProcessResult[index] = model;
//       }
//     }
//   }
//
//   addProcessResult(ProcessResultModel model) {
//     if(model.enable) {
//       allProcessResult.add(model);
//     }
//   }
//
//   Future<void> saveProcessResult(
//       List<ProcessResultModel> process, SharedPreferences prefs) async {
//     final List<String> jsonList =
//     process.map((e) => jsonEncode(e.toJson())).toList();
//     await prefs.setStringList('process_result', jsonList);
//   }
//
//   Future<void> loadProcessResult(SharedPreferences prefs) async {
//     final List<String>? jsonList =
//     prefs.getStringList('process_result');
//     if (jsonList == null || jsonList.isEmpty) {
//       return;
//     }
//     final data = jsonList
//         .map((jsonString) =>
//         ProcessResultModel.fromJson(jsonDecode(jsonString)))
//         .toList();
//
//     allProcessResult.clear();
//     allProcessResult.addAll(data);
//   }
//
//   // =================== WORKING UNIT ===================
//   addWorkingUnit(WorkingUnitModel model) {
//     if(model.enable && !allWorkingUnit.any((e) => e.id == model.id)) {
//       allWorkingUnit.add(model);
//       mapWorkingUnit[model.id] = model;
//       if(model.parent.isEmpty) return;
//       List<WorkingUnitModel> tmp = mapWorkChild[model.parent] ?? [];
//       mapWorkChild[model.parent] = [...tmp, model];
//     }
//   }
//
//   updateWorkingUnit(WorkingUnitModel model) {
//     int index = allWorkingUnit.indexWhere((e) => e.id == model.id);
//     if(index != -1) {
//       if(model.enable) {
//         allWorkingUnit[index] = model;
//         mapWorkingUnit[model.id] = model;
//         List<WorkingUnitModel> tmp = mapWorkChild[model.id] ?? [];
//         int idx2 = tmp.indexWhere((e) => e.id == model.id);
//         if(idx2 != -1) {
//           tmp[idx2] = model;
//           mapWorkChild[model.parent] = [...tmp];
//         }
//       } else {
//         allWorkingUnit.removeAt(index);
//         mapWorkingUnit.remove(model.id);
//         if(model.parent.isEmpty) return;
//         List<WorkingUnitModel> tmp = mapWorkChild[model.id] ?? [];
//         int idx2 = tmp.indexWhere((e) => e.id == model.id);
//         if(idx2 != -1) {
//           tmp.removeAt(idx2);
//         }
//         mapWorkChild[model.parent] = [...tmp];
//       }
//     }
//   }
//
//   // =================== WORKING SHIFT ===================
//
//   addWorkingShift(WorkShiftModel model) {
//     if(!allWorkShifts.any((e) => e.id == model.id)) {
//       allWorkShifts.add(model);
//       mapWorkShift["${model.user}_${model.date}"] = model;
//       mapWorkShiftFromUserAndDate["${model.user}_${model.date}"] = model;
//     }
//   }
//
//   updateWorkingShift(WorkShiftModel model) {
//     int index = allWorkShifts.indexWhere((e) => e.id == model.id);
//     if(index != -1) {
//       allWorkShifts[index] = model;
//       mapWorkShift["${model.user}_${model.date}"] = model;
//       mapWorkShiftFromUserAndDate["${model.user}_${model.date}"] = model;
//     }
//   }
//
//   // =================== WORKING FIELD ===================
//
//   addWorkingField(WorkFieldModel model) {
//     if(model.enable && !allWorkFields.any((e) => e.id == model.id)) {
//       allWorkFields.add(model);
//       mapWorkField[model.id] = model;
//       if(model.workShift.isEmpty) return;
//       List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
//       mapWFfWS[model.workShift] = [...tmp, model];
//     }
//   }
//
//   updateWorkingField(WorkFieldModel model) {
//     int index = allWorkFields.indexWhere((e) => e.id == model.id);
//     if(index != -1) {
//       if(model.enable) {
//         allWorkFields[index] = model;
//         mapWorkField[model.id] = model;
//         List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
//         int idx2 = tmp.indexWhere((e) => e.id == model.id);
//         if(idx2 != -1) {
//           tmp[idx2] = model;
//           mapWFfWS[model.workShift] = [...tmp];
//         }
//       } else {
//         allWorkFields.removeAt(index);
//         mapWorkField.remove(model.id);
//         if(model.workShift.isEmpty) return;
//         List<WorkFieldModel> tmp = mapWFfWS[model.workShift] ?? [];
//         int idx2 = tmp.indexWhere((e) => e.id == model.id);
//         if(idx2 != -1) {
//           tmp.removeAt(idx2);
//         }
//         mapWFfWS[model.workShift] = [...tmp];
//       }
//     }
//   }
//
//   // =================== QUOTE ===================
//
//   addQuote(QuoteModel model) {
//     if(model.enable && !allQuotes.any((e) => e.id == model.id)) {
//       allQuotes.add(model);
//       mapQuote[model.id] = model;
//     }
//   }
//
//   updateQuote(QuoteModel model) {
//     int index = allQuotes.indexWhere((e) => e.id == model.id);
//     if(index != -1) {
//       if(model.enable) {
//         allQuotes[index] = model;
//         mapQuote[model.id] = model;
//       } else {
//         allQuotes.removeAt(index);
//         mapQuote.remove(model.id);
//       }
//     }
//   }

}
