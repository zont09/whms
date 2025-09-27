import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/working_unit_model.dart';

class CreateSubTaskCubit extends Cubit<int> {
  CreateSubTaskCubit() : super(0);

  final TextEditingController conName = TextEditingController();
  final TextEditingController conDes = TextEditingController();
  int workingTime = 40;
  int status = 3;

  initData(WorkingUnitModel? work) {
    if(work == null) return;
    conName.text = work.title;
    conDes.text = work.description;
    workingTime = work.duration;
    status = work.status;
  }

  changeWorkingTime(int value) {
    workingTime = value;
    EMIT();
  }

  changeWorkStatus(int value) {
    status = value;
    EMIT();
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}