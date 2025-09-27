
import 'package:whms/untils/app_text.dart';

enum SortedListNameDefine {
  task_today,
  task_doing,
  task_FTF,
  task_urgent,
  task_personal,
  task_assign,
  task,
  subtask,
  managerEpic,
  managerSprint,
  managerStory,
  managerTask,
  note,
  meeting,
  process,
}

extension SortedListNameExtension on SortedListNameDefine {
  static SortedListNameDefine convertToTypeIssue(String type) {
    if (type == AppText.textSortedTaskToday.text) {
      return SortedListNameDefine.task_today;
    }
    if (type == AppText.textSortedTaskDoing.text) {
      return SortedListNameDefine.task_doing;
    }
    if (type == AppText.textSortedTaskFTF.text) {
      return SortedListNameDefine.task_FTF;
    }
    if (type == AppText.textSortedTaskUrgent.text) {
      return SortedListNameDefine.task_urgent;
    }
    if (type == AppText.textSortedTaskPersonal.text) {
      return SortedListNameDefine.task_personal;
    }
    if (type == AppText.textSortedTaskAssign.text) {
      return SortedListNameDefine.task_assign;
    }
    if (type == AppText.textSortedSubtask.text) {
      return SortedListNameDefine.subtask;
    }
    if (type == AppText.textSortedNote.text) {
      return SortedListNameDefine.note;
    }
    if (type == AppText.textSortedMeeting.text) {
      return SortedListNameDefine.meeting;
    }
    if (type == AppText.textSortedProcess.text) {
      return SortedListNameDefine.process;
    }
    return SortedListNameDefine.subtask;
  }

  String get title {
    switch (this) {
      case SortedListNameDefine.task_today:
        return AppText.textSortedTaskToday.text;
      case SortedListNameDefine.task_doing:
        return AppText.textSortedTaskDoing.text;
      case SortedListNameDefine.task_FTF:
        return AppText.textSortedTaskFTF.text;
      case SortedListNameDefine.task_urgent:
        return AppText.textSortedTaskUrgent.text;
      case SortedListNameDefine.task_personal:
        return AppText.textSortedTaskPersonal.text;
      case SortedListNameDefine.task_assign:
        return AppText.textSortedTaskAssign.text;
      case SortedListNameDefine.task:
        return AppText.textSortedTask.text;
      case SortedListNameDefine.subtask:
        return AppText.textSortedSubtask.text;
      case SortedListNameDefine.managerEpic:
        return AppText.txtSortedManagerEpic.text;
      case SortedListNameDefine.managerSprint:
        return AppText.txtSortedManagerSprint.text;
      case SortedListNameDefine.managerStory:
        return AppText.txtSortedManagerStory.text;
      case SortedListNameDefine.managerTask:
        return AppText.txtSortedManagerTask.text;
      case SortedListNameDefine.note:
        return AppText.textSortedNote.text;
      case SortedListNameDefine.meeting:
        return AppText.textSortedMeeting.text;
      case SortedListNameDefine.process:
        return AppText.textSortedProcess.text;
      default:
        return AppText.textSortedSubtask.text;
    }
  }

// Color get background {
//   switch (this) {
//     case SortedListNameDefine.all:
//       return ColorConfig.issueNew;
//     case SortedListNameDefine.bug:
//       return ColorConfig.issueBug;
//     case SortedListNameDefine.problem:
//       return ColorConfig.issueProblem;
//     case SortedListNameDefine.improvement:
//       return ColorConfig.issueImprove;
//     case SortedListNameDefine.consideration:
//       return ColorConfig.issueConsidering;
//     case SortedListNameDefine.complaint:
//       return ColorConfig.issueComplaint;
//     case SortedListNameDefine.proposal:
//       return ColorConfig.issueRecommend;
//     case SortedListNameDefine.feedback:
//       return ColorConfig.issueFeedback;
//     default:
//       return ColorConfig.issueOther;
//   }
// }
}
