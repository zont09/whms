import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/main.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/convert_utils.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';

class AssignmentPopupCubit extends Cubit<int> {
  AssignmentPopupCubit(bool isSubtask, this.cfC) : super(0);

  TextEditingController conName = TextEditingController(text: '');
  TextEditingController conDes = TextEditingController(text: "");
  TextEditingController conStartDate = TextEditingController(text: "");
  TextEditingController conEndDate = TextEditingController(text: "");
  TextEditingController conExecuteDate = TextEditingController(text: "");

  TypeAssignmentDefine selectedType = TypeAssignmentDefine.epic;
  PriorityLevelDefine selectedPriority = PriorityLevelDefine.top;
  int statusWorking = StatusWorkingDefine.none.value;
  int selectedWP = 1;
  String ancestry = '';
  bool isTaskPersonal = false;
  List<ScopeModel> selectedScope = [];

  List<ScopeModel> get listScope =>
      getIt<ConfigsCubit>().allScopeByUserId.values.toList();

  late ConfigsCubit cfC;

  load(bool isSubtask, int typeAssignment, {WorkingUnitModel? model}) async {
    conName = TextEditingController(text: model == null ? '' : model.title);
    if (typeAssignment == 1000) {
      isTaskPersonal = true;
    }
    conDes =
        TextEditingController(text: model == null ? '' : model.description);
    conStartDate = TextEditingController(
        text: model == null
            ? DateTimeUtils.formatDateDayMonthYear(DateTime.now())
            : DateTimeUtils.convertTimestampToDateString(model.start));
    conEndDate = TextEditingController(
        text: model == null
            ? DateTimeUtils.formatDateDayMonthYear(DateTime.now())
            : DateTimeUtils.convertTimestampToDateString(model.deadline));
    selectedPriority = model == null
        ? PriorityLevelDefine.normal
        : PriorityLevelExtension.convertToPriority(model.priority);
    statusWorking = model == null ? -1 : model.status;
    conExecuteDate = TextEditingController(
        text: model == null
            ? '${AppText.textTime.text} ${AppText.titleUrgent.text}'
            : DateTimeUtils.convertTimestampToDateString(model.urgent));
    selectedWP = model == null ? -1 : model.workingPoint;
    selectedType = model == null
        ? TypeAssignmentDefineExtension.listType(typeAssignment).first
        : TypeAssignmentDefineExtension.types(model.type);

    if (isSubtask) {
      selectedType = TypeAssignmentDefine.subtask;
    }

    if (model != null) {

      final idsSelectedScopes = selectedScope.map((e) => e.id).toSet();

      for (var item in listScope) {
        if (idsSelectedScopes.contains(item.id)) {
          item.isSelected = true;
        }
      }
    }
  }

  updateAssignment(WorkingUnitModel model, context) async {
    var start = DateTimeUtils.convertToDateTime(conStartDate.text);
    var end = DateTimeUtils.convertToDateTime(conEndDate.text);
    var urgent = DateTimeUtils.convertToDateTime(conExecuteDate.text);
    if (start.isBefore(end) || start.isAtSameMomentAs(end)) {
      if ((urgent.isBefore(end) ||
          urgent.isAtSameMomentAs(end) &&
              (start.isBefore(urgent) || start.isAtSameMomentAs(urgent)))) {
        var startStamp = DateTimeUtils.getTimestampWithDay(start);
        var endStamp = DateTimeUtils.getTimestampWithDay(end);
        var urgentStamp = DateTimeUtils.getTimestampWithDay(urgent);
        DialogUtils.showLoadingDialog(context);
        ConfigsCubit.fromContext(context).updateWorkingUnit(model.copyWith(
            title: conName.text,
            description: conDes.text,
            start: startStamp,
            deadline: endStamp,
            priority: selectedPriority.title,
            status: statusWorking,
            urgent: urgentStamp,
            workingPoint: selectedWP,
            type: selectedType.title),
          model);
        // await _workingService.updateWorkingUnitField(
        //     model.copyWith(
        //         title: conName.text,
        //         description: conDes.text,
        //         start: startStamp,
        //         deadline: endStamp,
        //         priority: selectedPriority.title,
        //         status: statusWorking,
        //         okr: okrs,
        //         urgent: urgentStamp,
        //         workingPoint: selectedWP,
        //         type: selectedType.title),
        //     model,
        //     ConfigsCubit.fromContext(context).user.id);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        DialogUtils.showResultDialog(
            context,
            AppText.titleErrorNotification.text,
            AppText.txtInvalidUrgentDate.text,
            mainColor: ColorConfig.primary3);
      }
    } else {
      DialogUtils.showResultDialog(context, AppText.titleErrorNotification.text,
          AppText.txtInvalidStartEndDate.text,
          mainColor: ColorConfig.primary3);
    }
  }

  createNewAssignment(WorkingUnitModel model, List<String> users,
      List<String> scopes, String userId, bool isSub, context,
      {required Function(WorkingUnitModel) reload}) async {
    List<String> list = (selectedType == TypeAssignmentDefine.task ? [] : users)
        .fold([], (prev, e) => [...prev, e]);
    // list.add(userId);
    var start = DateTimeUtils.convertToDateTime(conStartDate.text);
    var end = DateTimeUtils.convertToDateTime(conEndDate.text);
    var urgent = conExecuteDate.text ==
            '${AppText.textTime.text} ${AppText.titleUrgent.text}'
        ? DateTimeUtils.convertToDateTime(conEndDate.text)
        : DateTimeUtils.convertToDateTime(conExecuteDate.text);

    var startStamp = DateTimeUtils.getTimestampWithDay(start);
    var endStamp = DateTimeUtils.getTimestampWithDay(end);
    var urgentStamp = DateTimeUtils.getTimestampWithDay(urgent);
    final db = FirebaseFirestore.instance;
    var newDoc = db.collection('whms_pls_working_unit').doc();
    // List<String> okrs = ConvertUtils.convertOKRSGroupToString(models);
    if (selectedType == TypeAssignmentDefine.okrs) {
      scopes = ConvertUtils.convertScopeToString(selectedScope);
    }

    List<String> assignees =
        selectedScope.fold([], (prev, e) => [...prev, ...e.members]);
    var assignment = WorkingUnitModel(
        id: newDoc.id,
        title: conName.text,
        description: conDes.text,
        type: selectedType.title,
        workingPoint: selectedWP,
        parent: isSub && model.id != "" ? model.id : '',
        handlers: model.handlers,
        status: statusWorking,
        priority: selectedType == TypeAssignmentDefine.task
            ? selectedPriority.title
            : '',
        scopes: scopes,
        okrs: model.okrs,
        urgent: selectedType != TypeAssignmentDefine.epic &&
                selectedType != TypeAssignmentDefine.okrs
            ? urgentStamp
            : Timestamp(0, 0),
        owner: userId,
        assignees: isTaskPersonal
            ? users
            : selectedType == TypeAssignmentDefine.okrs
                ? assignees
                : list,
        start: selectedType != TypeAssignmentDefine.epic &&
                selectedType != TypeAssignmentDefine.okrs
            ? startStamp
            : Timestamp(0, 0),
        deadline: selectedType != TypeAssignmentDefine.epic &&
                selectedType != TypeAssignmentDefine.okrs
            ? endStamp
            : Timestamp(0, 0));
    if (selectedType == TypeAssignmentDefine.epic ||
        selectedType == TypeAssignmentDefine.story ||
        selectedType == TypeAssignmentDefine.okrs) {
      DialogUtils.showLoadingDialog(context);
      await addNewAssignment(assignment);
      Navigator.pop(context);
      Navigator.pop(context);
      reload(assignment);
    }

    if (selectedType == TypeAssignmentDefine.sprint) {
      if (start.isBefore(end) || start.isAtSameMomentAs(end)) {
        DialogUtils.showLoadingDialog(context);
        await addNewAssignment(assignment);
        Navigator.pop(context);
        Navigator.pop(context);
        reload(assignment);
      } else {
        DialogUtils.showResultDialog(
            context,
            AppText.titleErrorNotification.text,
            AppText.txtInvalidStartEndDate.text,
            mainColor: ColorConfig.primary3);
      }
    }

    if (selectedType == TypeAssignmentDefine.task) {
      if (start.isBefore(end) || start.isAtSameMomentAs(end)) {
        if ((urgent.isBefore(end) ||
            urgent.isAtSameMomentAs(end) &&
                (start.isBefore(urgent) || start.isAtSameMomentAs(urgent)))) {
          final db1 = FirebaseFirestore.instance;
          var newDoc1 = db1.collection('whms_pls_working_unit').doc();
          DialogUtils.showLoadingDialog(context);
          await addNewAssignment(assignment);
          await addNewAssignment(WorkingUnitModel(
              id: newDoc1.id,
              title: AppText.txtDefaultNameSubTask.text,
              description: AppText.txtDefaultNameSubTask.text,
              type: TypeAssignmentDefine.subtask.title,
              workingPoint: 1,
              parent: assignment.id,
              status: statusWorking,
              priority: PriorityLevelDefine.normal.title,
              urgent: urgentStamp,
              owner: assignment.owner,
              scopes: scopes,
              okrs: assignment.okrs,
              assignees: isTaskPersonal ? users : list,
              start: assignment.start,
              deadline: assignment.deadline));
          Navigator.pop(context);
          Navigator.pop(context);
          reload(assignment);
        } else {
          DialogUtils.showResultDialog(
              context,
              AppText.titleErrorNotification.text,
              AppText.txtInvalidUrgentDate.text,
              mainColor: ColorConfig.primary3);
        }
      } else {
        DialogUtils.showResultDialog(
            context,
            AppText.titleErrorNotification.text,
            AppText.txtInvalidStartEndDate.text,
            mainColor: ColorConfig.primary3);
      }
    }
    return assignment;
  }

  addNewAssignment(WorkingUnitModel model) async {
    cfC.addWorkingUnit(model);
    // await _workingService.addNewWorkingUnit(model);
  }

  choosePriority(PriorityLevelDefine priority) {
    selectedPriority = priority;

    buildUI();
  }

  chooseWP(int point) {
    selectedWP = point;
    buildUI();
  }

  chooseType(TypeAssignmentDefine type) {
    selectedType = type;

    buildUI();
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
