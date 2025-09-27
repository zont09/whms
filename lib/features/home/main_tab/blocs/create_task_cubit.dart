import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/working_unit_model.dart';

class CreateTaskCubit extends Cubit<int> {
  CreateTaskCubit() : super(0);

  int tab = 0;
  final TextEditingController conName = TextEditingController();
  final TextEditingController conDes = TextEditingController();
  WorkingUnitModel? workSelected;
  int workingTime = 40;

  changeTab(int newTab) {
    if(newTab == tab) return;
    tab = newTab;
    EMIT();
  }

  changeWorkPar(WorkingUnitModel? work) {
    workSelected = work;
    EMIT();
  }

  changeWorkingTime(int newTime) {
    if(newTime == workingTime) return;
    workingTime = newTime;
    EMIT();
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}