import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/status_meeting_define.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/meeting_service.dart';

class CreateMeetingCubit extends Cubit<int> {
  CreateMeetingCubit() : super(0);

  List<UserModel> listAllUsers = [];

  List<ScopeModel> listScopeMeeting = [];
  List<UserModel> listMemberMeeting = [];
  UserModel ownerMeeting = UserModel();
  DateTime? timeMeeting;
  DateTime timeReminder = DateTime.now();
  final TextEditingController conTitle = TextEditingController();
  final TextEditingController conDes = TextEditingController();

  initData(UserModel u, List<UserModel> lu) {
    ownerMeeting = u;
    listAllUsers.clear();
    listAllUsers.addAll(lu);
    EMIT();
  }

  addMember(UserModel u) {
    if(listMemberMeeting.contains(u)) {
      listMemberMeeting.remove(u);
    } else {
      listMemberMeeting.add(u);
    }
    EMIT();
  }

  addScope(ScopeModel s) {
    if(listScopeMeeting.contains(s)) {
      listScopeMeeting.remove(s);
      for(var e in listAllUsers) {
        if(e.scopes.contains(s.id)) {
          listMemberMeeting.remove(e);
        }
      }
    } else {
      listScopeMeeting.add(s);
      for(var e in listAllUsers) {
        if(e.scopes.contains(s.id) && !listMemberMeeting.contains(e)) {
          listMemberMeeting.add(e);
        }
      }
    }
    EMIT();
  }

  changeTimeMeeting(DateTime d) {
    timeMeeting = d;
    EMIT();
  }

  changeTimeReminder(DateTime d) {
    timeReminder = d;
    EMIT();
  }

  changeOwner(UserModel u) {
    ownerMeeting = u;
    EMIT();
  }

  createMeeting() {
    final MeetingModel model = MeetingModel(
      id: FirebaseFirestore.instance.collection("pls_daily_meeting").doc().id,
      title: conTitle.text,
      description: conDes.text,
      members: listMemberMeeting.map((e) => e.id).toList(),
      scopes: listScopeMeeting.map((e) => e.id).toList(),
      owner: ownerMeeting.id,
      time: timeMeeting,
      reminderTime: timeReminder,
      status: StatusMeetingDefine.none.title,
    );
    MeetingService.instance.addNewMeeting(model);
    return model;
  }

  EMIT() {
    if(!isClosed) {
      emit(state + 1);
    }
  }
}