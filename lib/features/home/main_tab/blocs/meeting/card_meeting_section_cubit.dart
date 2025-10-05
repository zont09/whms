import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/meeting_section_model.dart';

class CardMeetingSectionCubit extends Cubit<int> {
  CardMeetingSectionCubit(MeetingSectionModel s) : super(0) {
    section = s;
  }

  late MeetingSectionModel section;

  final TextEditingController conTitle = TextEditingController();
  final TextEditingController conDes = TextEditingController();

  initData() {
    conTitle.text = section.title;
    conDes.text = section.description;
    EMIT();
  }



  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}