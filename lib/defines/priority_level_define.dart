import 'package:flutter/material.dart';
import 'package:whms/untils/app_text.dart';

enum PriorityLevelDefine { top, high, normal, low }

extension PriorityLevelExtension on PriorityLevelDefine {
  static PriorityLevelDefine convertToPriority(String priority) {
    if (priority == AppText.txtPriorityTop.text) {
      return PriorityLevelDefine.top;
    }
    if (priority == AppText.txtPriorityHigh.text) {
      return PriorityLevelDefine.high;
    }
    if (priority == AppText.txtPriorityNormal.text) {
      return PriorityLevelDefine.normal;
    }
    return PriorityLevelDefine.low;
  }

  String get title {
    switch (this) {
      case PriorityLevelDefine.top:
        return AppText.txtPriorityTop.text;
      case PriorityLevelDefine.high:
        return AppText.txtPriorityHigh.text;
      case PriorityLevelDefine.normal:
        return AppText.txtPriorityNormal.text;
      default:
        return AppText.txtPriorityLow.text;
    }
  }

  Color get background {
    switch (this) {
      case PriorityLevelDefine.top:
        return const Color(0xFFFFC1C1);
      case PriorityLevelDefine.high:
        return const Color(0xFFffcab8);
      case PriorityLevelDefine.normal:
        return const Color(0xFFfff5c7);
      default:
        return const Color(0xFFE1EAFF);
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevelDefine.top:
        return const Color(0xFFFF474E);
      case PriorityLevelDefine.high:
        return const Color(0xFFff5214);
      case PriorityLevelDefine.normal:
        return const Color(0xFFd4b002);
      default:
        return const Color(0xFF0F3A9D);
    }
  }
}
