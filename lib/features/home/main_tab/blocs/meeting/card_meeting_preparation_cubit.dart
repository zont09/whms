import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/meeting_preparation_model.dart';

class CardMeetingPreparationCubit extends Cubit<int> {
  CardMeetingPreparationCubit(MeetingPreparationModel s) : super(0) {
    prepare = s;
  }

  late MeetingPreparationModel prepare;

  final TextEditingController conDes = TextEditingController();

  initData() {
    conDes.text = prepare.content;
    EMIT();
  }


  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}