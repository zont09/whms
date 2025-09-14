import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';

enum StatusWorkingDefine {
  none, //0
  done, //100
  fixing,
  pending, //0
  waiting, //0
  cancelled,
  failed, //0
  completed, //100
  processing,
  reworking,
  revising,
  unknown, //0
}

extension StatusWorkingExtension on StatusWorkingDefine {
  bool get isDynamic {
    return this == StatusWorkingDefine.processing ||
        this == StatusWorkingDefine.reworking ||
        this == StatusWorkingDefine.revising;
  }

  bool isInRange(int value) {
    if (this == StatusWorkingDefine.processing) {
      return value >= 100 && value <= 199;
    } else if (this == StatusWorkingDefine.reworking) {
      return value >= 200 && value <= 299;
    } else if (this == StatusWorkingDefine.revising) {
      return value >= 300 && value <= 399;
    }
    return false;
  }

  String get description {
    switch (this) {
      case StatusWorkingDefine.none:
        return AppText.textNone.text;
      case StatusWorkingDefine.done:
        return AppText.textDone.text;
      case StatusWorkingDefine.fixing:
        return AppText.textFixing.text;
      case StatusWorkingDefine.pending:
        return AppText.textPending.text;
      case StatusWorkingDefine.waiting:
        return AppText.textWaiting.text;
      case StatusWorkingDefine.cancelled:
        return AppText.textCancelled.text;
      case StatusWorkingDefine.failed:
        return AppText.textFailed.text;
      case StatusWorkingDefine.completed:
        return AppText.textCompleted.text;
      case StatusWorkingDefine.processing:
        return AppText.textProcessing.text;
      case StatusWorkingDefine.reworking:
        return AppText.textReworking.text;
      case StatusWorkingDefine.revising:
        return AppText.textRevising.text;
      case StatusWorkingDefine.unknown:
        return AppText.textUnknown.text;
    }
  }

  Color get colorTitle {
    switch (this) {
      case StatusWorkingDefine.none:
        return ColorConfig.statusPendingText;
      case StatusWorkingDefine.done:
        return ColorConfig.statusDoneText;
      case StatusWorkingDefine.fixing:
        return ColorConfig.statusFixingText;
      case StatusWorkingDefine.pending:
        return ColorConfig.statusPendingText;
      case StatusWorkingDefine.waiting:
        return ColorConfig.statusWaitingText;
      case StatusWorkingDefine.cancelled:
        return ColorConfig.statusCancelledText;
      case StatusWorkingDefine.failed:
        return ColorConfig.statusFailedText;
      case StatusWorkingDefine.completed:
        return ColorConfig.statusCompletedText;
      case StatusWorkingDefine.processing:
        return ColorConfig.statusProcessingText;
      case StatusWorkingDefine.reworking:
        return ColorConfig.statusReworkingText;
      case StatusWorkingDefine.revising:
        return ColorConfig.statusRevisingText;
      case StatusWorkingDefine.unknown:
        return ColorConfig.statusFailedText;
    }
  }

  Color get colorBackground {
    switch (this) {
      case StatusWorkingDefine.none:
        return ColorConfig.statusPendingBG;
      case StatusWorkingDefine.done:
        return ColorConfig.statusDoneBG;
      case StatusWorkingDefine.fixing:
        return ColorConfig.statusFixingBG;
      case StatusWorkingDefine.pending:
        return ColorConfig.statusPendingBG;
      case StatusWorkingDefine.waiting:
        return ColorConfig.statusWaitingBG;
      case StatusWorkingDefine.cancelled:
        return ColorConfig.statusCancelledBG;
      case StatusWorkingDefine.failed:
        return ColorConfig.statusFailedBG;
      case StatusWorkingDefine.completed:
        return ColorConfig.statusCompletedBG;
      case StatusWorkingDefine.processing:
        return ColorConfig.statusProcessingBG;
      case StatusWorkingDefine.reworking:
        return ColorConfig.statusReworkingBG;
      case StatusWorkingDefine.revising:
        return ColorConfig.statusRevisingBG;
      case StatusWorkingDefine.unknown:
        return ColorConfig.statusFailedBG;
    }
  }

  int get value {
    switch (this) {
      case StatusWorkingDefine.none:
        return -1;
      case StatusWorkingDefine.done:
        return 0;
      case StatusWorkingDefine.fixing:
        return 1;
      case StatusWorkingDefine.pending:
        return 2;
      case StatusWorkingDefine.waiting:
        return 3;
      case StatusWorkingDefine.cancelled:
        return 4;
      case StatusWorkingDefine.failed:
        return 5;
      case StatusWorkingDefine.completed:
        return 6;
      case StatusWorkingDefine.processing:
        return 100;
      case StatusWorkingDefine.reworking:
        return 200;
      case StatusWorkingDefine.revising:
        return 300;
      case StatusWorkingDefine.unknown:
        return -9;
    }
  }

  static StatusWorkingDefine fromValue(int value) {
    if (value == -1) return StatusWorkingDefine.none;
    if (value == 0) return StatusWorkingDefine.done;
    if (value == 1) return StatusWorkingDefine.fixing;
    if (value == 2) return StatusWorkingDefine.pending;
    if (value == 3) return StatusWorkingDefine.waiting;
    if (value == 4) return StatusWorkingDefine.cancelled;
    if (value == 5) return StatusWorkingDefine.failed;
    if (value == 6) return StatusWorkingDefine.completed;
    if (value >= 100 && value <= 199) return StatusWorkingDefine.processing;
    if (value >= 200 && value <= 299) return StatusWorkingDefine.reworking;
    if (value >= 300 && value <= 399) return StatusWorkingDefine.revising;
    return StatusWorkingDefine.unknown;
  }

  static int fromPercent(int value, {bool isTask = false}) {
    if ((value == 0 && isTask) ||
        (value == 6 && isTask) ||
        (value % 100 == 0 && value > 0 && !isTask)) {
      return 100;
    }
    if ((value == -1 || value == 1 || value == 2 || value == 3 || value == 5) &&
        isTask) {
      return 0;
    }
    if (isTask && value > 99) {
      return value % 100;
    }
    return value % 100;
  }

  bool get isClose {
    return this == StatusWorkingDefine.completed ||
        this == StatusWorkingDefine.failed ||
        this == StatusWorkingDefine.cancelled;
  }

  static bool isClosed(StatusWorkingDefine status) {
    return status == StatusWorkingDefine.completed ||
        status == StatusWorkingDefine.failed ||
        status == StatusWorkingDefine.cancelled;
  }

  static int getRandomStatusValue() {
    final random = Random();
    final type = random.nextInt(9); // Chọn 0-8 cho các nhóm trạng thái
    if (type == 0) return 0; // done
    if (type == 1) return 1; // fixing
    if (type == 2) return 2; // pending
    if (type == 3) return 3; // waiting
    if (type == 4) return 4; // cancelled
    if (type == 5) return 5; // failed
    if (type == 6) return 6; // completed
    if (type == 7) return 100 + random.nextInt(100);
    if (type == 8) return 200 + random.nextInt(100); // reworking (200-299)
    return 300 + random.nextInt(100); // revising (300-399)
  }

  static int toValue(StatusWorkingDefine status) {
    switch (status) {
      case StatusWorkingDefine.none:
        return -1;
      case StatusWorkingDefine.done:
        return 0;
      case StatusWorkingDefine.fixing:
        return 1;
      case StatusWorkingDefine.pending:
        return 2;
      case StatusWorkingDefine.waiting:
        return 3;
      case StatusWorkingDefine.cancelled:
        return 4;
      case StatusWorkingDefine.failed:
        return 5;
      case StatusWorkingDefine.completed:
        return 6;
      case StatusWorkingDefine.processing:
        return 100; // Or any value between 100 and 199. Choose a convention.
      //  If you need more precise encoding, you might need to add
      //  more information/parameters to your method.
      case StatusWorkingDefine.reworking:
        return 200; // Or any value between 200 and 299. Choose a convention.
      // If you need more precise encoding, you might need to add
      // more information/parameters to your method.
      case StatusWorkingDefine.revising:
        return 300; // Or any value between 300 and 399. Choose a convention.
      // If you need more precise encoding, you might need to add
      // more information/parameters to your method.
      case StatusWorkingDefine.unknown:
        return -9; // Or any suitable default value to indicate "unknown"
      default:
        return -9; // Handle unexpected cases with a suitable default
    }
  }
}
