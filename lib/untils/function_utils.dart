import 'package:collection/collection.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';

class FunctionUtils {
  static int getLogTimeFromWorkShift(WorkShiftModel? ws) {
    int logTime = 0;
    if (ws != null && ws.status == StatusCheckInDefine.checkOut.value) {
      DateTime ci = ws.checkIn!.toDate();
      DateTime co = ws.checkOut!.toDate();
      logTime += co.difference(ci).inMinutes.round();
      int sumBreak = 0;
      for (int i = 0; i < ws.breakTimes.length; i++) {
        DateTime brk = ws.breakTimes[i].toDate();
        DateTime rsm = ws.resumeTimes[i].toDate();
        sumBreak += (rsm.difference(brk).inMinutes.round());
      }
      logTime -= sumBreak;
    }
    return logTime;
  }

  static int getDurationFromStatus(int status, String type) {
    if (type != TypeAssignmentDefine.task.title &&
        type != TypeAssignmentDefine.subtask.title) return status;
    if (StatusWorkingExtension.fromValue(status).isDynamic) {
      return status % 100;
    }
    if (status == StatusWorkingDefine.done.value) {
      return 100;
    }
    return 0;
  }

  static String formatStringVN(String input) {
    const vietnameseChars =
        'ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơỲÝỴỶỸỳýỵỷỹƯỨỰỪỬỮưứựừửữÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜèéêëìíîïòóôõöùúûüÇç';
    const asciiChars =
        'AAAAEEEIIOOOOUUADIOUaaaaeeeiioooouuadioUYYYYyyyyUUUUuuuuuEEEEIIIIOOOOOUUUUeeeeiiiiooooouuuuCc';

    String normalized = input.split('').map((char) {
      int index = vietnameseChars.indexOf(char);
      return index != -1 ? asciiChars[index] : char;
    }).join('');

    return normalized.toLowerCase();
  }

  static int getStatusTaskToday(WorkingUnitModel task,
      List<WorkingUnitModel> lisSub, List<WorkFieldModel> listWFToday) {
    for (var e in listWFToday) {
      int index = lisSub.indexWhere((s) => s.id == e.taskId);
      if (index != -1) {
        lisSub[index] = lisSub[index].copyWith(status: e.toStatus);
      }
    }
    int cnt = 0;
    int done = 0;
    int mandatory = -9;

    for (var st in lisSub) {
      int status = st.status;
      print('====> calc status today: ${st.id} - ${st.title} - $status');
      if (status != StatusWorkingDefine.cancelled.value) cnt++;
      if (status == StatusWorkingDefine.done.value) done++;
      if (st.owner.isEmpty &&
          (status == StatusWorkingDefine.cancelled.value ||
              status == StatusWorkingDefine.failed.value)) {
        mandatory = st.status;
      }
    }

    int finalStatus = 0;

    if (mandatory != -9) {
      finalStatus = mandatory;
    } else if (cnt == done) {
      finalStatus = StatusWorkingDefine.done.value;
    } else {
      finalStatus = StatusWorkingDefine.processing.value + (done * 100) ~/ cnt;
    }

    return finalStatus;
  }

  static bool isEqualList(List<dynamic> l1, List<dynamic> l2) {
    return const ListEquality().equals(l1, l2);
  }

  static CompareListModel<T> compareList<T>(
      List<T> newL, List<T> oldL, bool Function(T, T) checkUpdate) {
    List<T> add = [];
    List<T> update = [];
    List<T> remove = [];

    for (var e in newL) {
      if (!oldL.contains(e)) {
        add.add(e);
      }
    }

    for (var e in oldL) {
      if (!newL.contains(e)) {
        remove.add(e);
      }
    }

    for (var e in newL) {
      for (var f in oldL) {
        if (checkUpdate(e, f)) {
          update.add(e);
          break;
        }
      }
    }

    return CompareListModel(add: add, update: update, remove: remove);
  }
}

class CompareListModel<T> {
  final List<T> add;
  final List<T> update;
  final List<T> remove;

  CompareListModel({
    required this.add,
    required this.update,
    required this.remove,
  });
}
