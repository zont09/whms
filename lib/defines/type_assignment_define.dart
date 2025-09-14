import 'package:flutter/material.dart';
import 'package:whms/untils/app_text.dart';

enum TypeAssignmentDefine { epic, sprint, story, task, subtask, okrs }

extension TypeAssignmentDefineExtension on TypeAssignmentDefine {
  String get title {
    switch (this) {
      case TypeAssignmentDefine.epic:
        return AppText.txtEpic.text;
      case TypeAssignmentDefine.sprint:
        return AppText.txtSprint.text;
      case TypeAssignmentDefine.story:
        return AppText.txtStory.text;
      case TypeAssignmentDefine.subtask:
        return AppText.txtSubTask.text;
      case TypeAssignmentDefine.okrs:
        return AppText.titleOKR.text;
      default:
        return AppText.txtTask.text;
    }
  }

  static int priority(String type) {
    if (type == TypeAssignmentDefine.okrs.title ||
        type == TypeAssignmentDefine.epic.title) {
      return 1;
    }
    if (type == TypeAssignmentDefine.sprint.title) {
      return 2;
    }
    if (type == TypeAssignmentDefine.story.title) {
      return 3;
    }
    if (type == TypeAssignmentDefine.task.title) {
      return 4;
    }
    return 5;
  }

  static Color color(String type) {
    if (type == TypeAssignmentDefine.okrs.title ||
        type == TypeAssignmentDefine.epic.title) {
      return const Color(0xFFffd900);
    }
    if (type == TypeAssignmentDefine.sprint.title) {
      return const Color(0xFFc300ff);
    }
    if (type == TypeAssignmentDefine.story.title) {
      return const Color(0xFF0091ff);
    }
    if (type == TypeAssignmentDefine.task.title) {
      return const Color(0xFF22e300);
    }
    return const Color(0xFF8a8a8a);
  }

  static TypeAssignmentDefine types(String type) {
    if (type == AppText.txtEpic.text) {
      return TypeAssignmentDefine.epic;
    }
    if (type == AppText.txtSprint.text) {
      return TypeAssignmentDefine.sprint;
    }
    if (type == AppText.txtStory.text) {
      return TypeAssignmentDefine.story;
    }
    if (type == AppText.txtTask.text) {
      return TypeAssignmentDefine.task;
    }
    if (type == AppText.titleOKR.text) {
      return TypeAssignmentDefine.okrs;
    }
    return TypeAssignmentDefine.subtask;
  }

  static List<TypeAssignmentDefine> listType(int typeAssignment) {
    switch (typeAssignment) {
      case 0:
        return TypeAssignmentDefine.values;
      case 1: // epic sprint story task
        return [
          TypeAssignmentDefine.epic,
          TypeAssignmentDefine.sprint,
          TypeAssignmentDefine.story,
          TypeAssignmentDefine.task,
        ];
      case 2: // sprint story task
        return [
          TypeAssignmentDefine.sprint,
          TypeAssignmentDefine.story,
          TypeAssignmentDefine.task
        ];
      case 3:
        return [TypeAssignmentDefine.story, TypeAssignmentDefine.task];
      case 4:
        return [TypeAssignmentDefine.epic];
      case 5:
        return [TypeAssignmentDefine.sprint];
      case 6:
        return [TypeAssignmentDefine.story];
      case 9:
        return [TypeAssignmentDefine.okrs];
      default:
        return [TypeAssignmentDefine.task];
    }
  }
}
