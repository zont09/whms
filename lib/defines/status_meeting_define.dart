import 'package:whms/untils/app_text.dart';
import 'package:flutter/material.dart';

enum StatusMeetingDefine { none, isGoingOn, ended, done }

extension StatusMeetingExtension on StatusMeetingDefine {
  static StatusMeetingDefine convertToStatus(String status) {
    if (status == AppText.textStatusMeetingNone.text) {
      return StatusMeetingDefine.none;
    }
    if (status == AppText.textStatusMeetingIsGoingOn.text) {
      return StatusMeetingDefine.isGoingOn;
    }
    if (status == AppText.textStatusMeetingEnded.text) {
      return StatusMeetingDefine.ended;
    }
    if (status == AppText.textStatusMeetingDone.text) {
      return StatusMeetingDefine.done;
    }
    return StatusMeetingDefine.none;
  }

  String get title {
    switch (this) {
      case StatusMeetingDefine.none:
        return AppText.textStatusMeetingNone.text;
      case StatusMeetingDefine.isGoingOn:
        return AppText.textStatusMeetingIsGoingOn.text;
      case StatusMeetingDefine.ended:
        return AppText.textStatusMeetingEnded.text;
      case StatusMeetingDefine.done:
        return AppText.textStatusMeetingDone.text;
      default:
        return AppText.textStatusMeetingNone.text;
    }
  }

  Color get background {
    switch(this) {
      case StatusMeetingDefine.none:
        return const Color(0xFF2C6848);
      case StatusMeetingDefine.isGoingOn:
        return const Color(0xFF193C97);
      case StatusMeetingDefine.ended:
        return const Color(0xFF40711E);
      case StatusMeetingDefine.done:
        return const Color(0xFFA6A6A6);
      default:
        return const Color(0xFF2C6848);
    }
  }
}
