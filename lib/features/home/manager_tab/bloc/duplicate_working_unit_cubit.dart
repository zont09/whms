import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DuplicateWorkingUnitCubit extends Cubit<int> {
  DuplicateWorkingUnitCubit(this.cfC, this.work) : super(0);

  List<WorkingUnitModel> listEpic = [];
  List<WorkingUnitModel> listSprint = [];
  List<WorkingUnitModel> listStory = [];
  List<WorkingUnitModel> listWU = [];

  List<WorkingUnitModel> listParentDup = [];
  Map<String, int> numOfDup = {};

  late WorkingUnitModel work;

  late ConfigsCubit cfC;

  initData() async {
    listEpic.clear();
    listStory.clear();
    listSprint.clear();
    List<String> listScope = [];
    for (var e in work.scopes) {
      if (cfC.allScopeMap[e] != null) {
        await cfC.getDataWorkingUnitByScopeNewest(e);
        listScope.add(e);
      }
    }
    listEpic = cfC.allWorkingUnit
        .where((e) =>
            e.scopes.any((e) => listScope.contains(e)) &&
            (e.type == TypeAssignmentDefine.epic.title ||
                e.type == TypeAssignmentDefine.okrs.title) &&
            !e.closed)
        .toList();
    listSprint = cfC.allWorkingUnit
        .where((e) =>
            e.scopes.any((e) => listScope.contains(e)) &&
            e.type == TypeAssignmentDefine.sprint.title &&
            !e.closed)
        .toList();
    listStory = cfC.allWorkingUnit
        .where((e) =>
            e.scopes.any((e) => listScope.contains(e)) &&
            e.type == TypeAssignmentDefine.story.title &&
            !e.closed)
        .toList();
    listWU.addAll([...listEpic, ...listSprint, ...listStory]);
    EMIT();
  }

  initDataParent() async {
    listParentDup.clear();
    numOfDup.clear();
    await cfC.getDataWorkingUnitByIdParentNewest(work.id);
    listWU = cfC.mapWorkChild[work.id] ?? <WorkingUnitModel>[];
  }

  selectParent(WorkingUnitModel model) {
    if (!listParentDup.contains(model)) {
      listParentDup.add(model);
      numOfDup[model.id] = 1;
    }
    EMIT();
  }

  removeParent(WorkingUnitModel model) {
    listParentDup.remove(model);
    numOfDup.remove(model.id);
    EMIT();
  }

  updateNumOfDup(WorkingUnitModel model, int num) {
    numOfDup[model.id] = num;
    EMIT();
  }

  handleDuplicate() async {
    for (var e in listParentDup) {
      for(int i = 0; i < (numOfDup[e.id] ?? 0); i++) {
        await duplicateWorkingUnitModel(work, e.id);
      }
      // final id = FirebaseFirestore.instance
      //     .collection('daily_pls_working_unit')
      //     .doc()
      //     .id;
      // WorkingUnitModel model = work.copyWith(
      //     id: id,
      //     parent: e.id,
      //     assignees: [],
      //     followers: [],
      //     handlers: [],
      //     attachments: []);
      // await cfC.addWorkingUnit(model);
    }
  }

  duplicateWorkingUnitModel(WorkingUnitModel workDup, String parent) async {
    final id = FirebaseFirestore.instance
        .collection('daily_pls_working_unit')
        .doc()
        .id;
    WorkingUnitModel model = workDup.copyWith(
        id: id,
        parent: parent,
        status: StatusWorkingDefine.none.value,
        assignees: [],
        followers: [],
        handlers: [],
        attachments: []);
    await cfC.addWorkingUnit(model);
    await cfC.getDataWorkingUnitByIdParentNewest(workDup.id);
    final listWorkChild = cfC.mapWorkChild[workDup.id] ?? <WorkingUnitModel>[];
    if (workDup.type == TypeAssignmentDefine.task.title) {
      final newDupTask = WorkingUnitModel(
          id: FirebaseFirestore.instance
              .collection('daily_pls_working_unit')
              .doc()
              .id,
          title: AppText.txtDefaultNameSubTask.text,
          description: AppText.txtDefaultNameSubTask.text,
          type: TypeAssignmentDefine.subtask.title,
          workingPoint: 1,
          priority: PriorityLevelDefine.normal.title,
          parent: id,
          status: -1,
          owner: workDup.owner,
          scopes: workDup.scopes,
          okrs: workDup.okrs);
      await cfC.addWorkingUnit(newDupTask);
      return;
    }
    for (var e in listWorkChild) {
      if (!e.closed) {
        duplicateWorkingUnitModel(e, id);
      }
    }
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
