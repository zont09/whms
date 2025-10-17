import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';

class ChooseParentPopupCubit extends Cubit<int> {
  ChooseParentPopupCubit() : super(0);

  late WorkingUnitModel wu;
  List<WorkingUnitModel> wus = [];
  WorkingUnitModel? newParent;

  init(WorkingUnitModel model, List<WorkingUnitModel> list) async {
    await Future.delayed((const Duration(milliseconds: 200)));
    wus.clear();
    wus = list;
    wu = model;
    newParent = model.family;
    emit(state + 1);
  }

  submitParent(BuildContext context) async {
    ConfigsCubit.fromContext(context)
        .updateWorkingUnit(wu.copyWith(parent: newParent!.id), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(parent: newParent!.id), wu, idU);
  }

  reset(WorkingUnitModel model) {
    newParent!.children.removeWhere((e) => e.id == wu.id);
    model.children.add(wu);
    final seenIds = <String>{};
    model.children.retainWhere((item) => seenIds.add(item.id));
    model.children.sort((a, b) => a.createAt.compareTo(b.createAt));
    emit(state + 1);
  }
}
