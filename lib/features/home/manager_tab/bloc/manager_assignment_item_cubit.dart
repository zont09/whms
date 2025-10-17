import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';

class ManagerAssignmentItemCubit extends Cubit<int> {
  ManagerAssignmentItemCubit(WorkingUnitModel model, ConfigsCubit cfC)
      : super(0) {
    wu = model;
    updateKey(wu, cfC);
  }

  WorkingUnitModel? directParent;
  List<WorkingUnitModel> address = [];
  late WorkingUnitModel wu;
  late String key = '';
  int numOfChild = -1;
  double percent = -1;

  final WorkingService _workingService = WorkingService.instance;

  updateWU(WorkingUnitModel editedModel) async {
    wu.title = editedModel.title;
    wu.description = editedModel.description;
    wu.start = editedModel.start;
    wu.deadline = editedModel.deadline;
    wu.urgent = editedModel.urgent;
    wu.priority = editedModel.priority;
    wu.workingPoint = editedModel.workingPoint;

    buildUI();
  }

  updateKey(WorkingUnitModel value, ConfigsCubit cfC) async {
    key =
        '${value.id}_${value.priority}_${value.workingPoint}_${value.status}_${value.urgent}_${value.start}_${value.deadline}_${value.level}_${value.assignees.join('-')}';

    var tmp = await _workingService.getWorkingUnitByIdParent(value.id);
    var temp = findAllDescendants(tmp, value.id);

    numOfChild = temp.length;
    calculatePercent(value.id, temp);
    percent = (percent < 0) ? 0 : percent;

    if (value.type != TypeAssignmentDefine.task.title &&
        value.type != TypeAssignmentDefine.subtask.title) {
      cfC.updateWorkingUnit(
          value.copyWith(status: int.parse('$percent')), value);
      // await _workingService.updateWorkingUnitField(
      //     value.copyWith(status: int.parse('$percent')), value, idU);
    }

    if (value.type == TypeAssignmentDefine.subtask.title) {
      directParent = await _workingService.getWorkingUnitById(value.parent);

      if (value.owner.isEmpty) {
        cfC.updateWorkingUnit(
            value.copyWith(
                owner: directParent == null ? '' : directParent!.owner),
            value);
        // await _workingService.updateWorkingUnitField(
        //     value.copyWith(
        //         owner: directParent == null ? '' : directParent!.owner),
        //     value,
        //     idU);
      }
      if(directParent != null) {
        value.owner = directParent!.owner;
      }
    }
    buildUI();
  }

  double calculatePercent(String parentId, List<WorkingUnitModel> allItems) {
    var children = allItems
        .where((item) =>
            item.parent == parentId &&
            item.type != TypeAssignmentDefine.subtask.title &&
            StatusWorkingExtension.fromValue(item.status) !=
                StatusWorkingDefine.cancelled)
        .toList();

    if (children.isEmpty) {
      for (var i in allItems) {
        if (i.id == parentId) {
          percent = i.percent;
          break;
        }
      }
      return percent;
      // return allItems.firstWhere((item) => item.id == parentId).percent;
    }

    for (var child in children) {
      child.percent = calculatePercent(child.id, allItems);
    }

    int average = children.fold<int>(
        0,
        (prev, e) =>
            prev +
            StatusWorkingExtension.fromPercent(e.status,
                isTask: e.type == TypeAssignmentDefine.task.title));
    percent = (average / (children.length)).ceilToDouble();
    for (var i in allItems) {
      if (i.id == parentId) {
        i.percent = percent;
      }
    }

    return percent;
  }

  List<WorkingUnitModel> findAllDescendants(
      List<WorkingUnitModel> allItems, String parentId) {
    final children = allItems.where((item) => item.parent == parentId).toList();

    for (var child in children) {
      children.addAll(findAllDescendants(allItems, child.id));
    }

    return children;
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
