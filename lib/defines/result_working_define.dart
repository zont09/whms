import 'package:flutter/material.dart';
import 'package:whms/untils/app_text.dart';

enum ResultWorkingDefine {
  none,
  excellent,
  completed,
  aheadOfSchedule,
  onTime,
  overDue,

  failed,
  bad
}

extension ResultWorkingExtension on ResultWorkingDefine {
  String get title {
    switch (this) {
      case ResultWorkingDefine.none:
        return AppText.textResultNone.text;
      case ResultWorkingDefine.excellent:
        return AppText.textResultExcellent.text;
      case ResultWorkingDefine.completed:
        return AppText.textResultCompleted.text;
      case ResultWorkingDefine.onTime:
        return AppText.textResultOnTime.text;
      case ResultWorkingDefine.overDue:
        return AppText.textResultOverdue.text;
      case ResultWorkingDefine.aheadOfSchedule:
        return AppText.textResultAheadOfSchedule.text;
      case ResultWorkingDefine.failed:
        return AppText.textResultFailed.text;
      default:
        return AppText.textUnknown.text;
    }
  }

  static ResultWorkingDefine convertTo(String str) {
    if (str == AppText.textResultNone.text) {
      return ResultWorkingDefine.none;
    } else if (str == AppText.textResultExcellent.text) {
      return ResultWorkingDefine.excellent;
    } else if (str == AppText.textResultCompleted.text) {
      return ResultWorkingDefine.completed;
    } else if (str == AppText.textResultOnTime.text) {
      return ResultWorkingDefine.onTime;
    } else if (str == AppText.textResultOverdue.text) {
      return ResultWorkingDefine.overDue;
    } else if (str == AppText.textResultAheadOfSchedule.text) {
      return ResultWorkingDefine.aheadOfSchedule;
    } else if (str == AppText.textResultFailed.text) {
      return ResultWorkingDefine.failed;
    }
    return ResultWorkingDefine.none;
  }

  Color get background {
    switch (this) {
      case ResultWorkingDefine.none:
        return Colors.grey[500]!;
      case ResultWorkingDefine.excellent:
        return Colors.blue[900]!;
      case ResultWorkingDefine.completed:
        return Colors.green[700]!;
      case ResultWorkingDefine.onTime:
        return Colors.amber[900]!;
      case ResultWorkingDefine.overDue:
        return Colors.red[900]!;
      case ResultWorkingDefine.aheadOfSchedule:
        return Colors.blue[900]!;
      case ResultWorkingDefine.failed:
        return Colors.red[900]!;
      default:
        return Colors.grey[500]!;
    }
  }
}
