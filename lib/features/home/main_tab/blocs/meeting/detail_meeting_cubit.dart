import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailMeetingCubit extends Cubit<int> {
  DetailMeetingCubit(MeetingModel m, UserModel u) : super(0){
    meeting = m;
    user = u;
  }

  late MeetingModel meeting;
  late UserModel user;
  String tab = AppText.textMeetingContent.text;
  List<ScopeModel> listScopeMeeting = [];


  initData(Map<String, ScopeModel> mapScp) async {
    for(var e in meeting.scopes) {
      if(mapScp.containsKey(e)) {
        listScopeMeeting.add(mapScp[e]!);
      }
    }
    EMIT();
  }

  updateMeeting(MeetingModel meet) {
    meeting = meet;
    EMIT();
  }

  updateListScope(ScopeModel s) {
    if(listScopeMeeting.contains(s)) {
      listScopeMeeting.remove(s);
    } else {
      listScopeMeeting.add(s);
    }
    EMIT();
  }

  changeTimeMeeting(DateTime newTime) {
    meeting = meeting.copyWith(time: newTime);
    // _meetingService.updateMeeting(meeting, user.id);
    EMIT();
  }

  changeTimeReminder(DateTime newTime) {
    meeting = meeting.copyWith(reminderTime: newTime);
    // _meetingService.updateMeeting(meeting, user.id);
    EMIT();
  }

  changeStatus(String newS) {
    meeting = meeting.copyWith(status: newS);
    // _meetingService.updateMeeting(meeting, user.id);
    EMIT();
  }

  changeTab(String newTab) {
    tab = newTab;
    EMIT();
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}