import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/comment_type_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/comment_service.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/convert_utils.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/task_noti_helper.dart';

class DetailAssignCubit extends Cubit<int> {
  DetailAssignCubit(WorkingUnitModel model, UserModel u, ConfigsCubit cubit)
    : super(0) {
    wu = model;
    user = u;
    cfC = cubit;
    debugPrint("====> Load default success");
  }

  final WorkingService _workingService = WorkingService.instance;
  final ScopeService _scopeService = ScopeService.instance;
  final CommentService _commentService = CommentService.instance;

  List<UserModel> listMember = [];
  List<UserModel> selectedMembers = [];
  List<UserModel> selectedHandlers = [];
  List<ScopeModel> selectedScopes = [];
  List<UserModel> selectedFollowers = [];
  ScopeModel? ownerScope;

  Map<String, List<WorkingUnitModel>> mapWorkChild = {};

  List<CommentModel> listComments = [];
  int loadingComment = 0;

  WorkingUnitModel? directParent;
  late WorkingUnitModel wu;
  late String key = '';
  late UserModel user;
  late ConfigsCubit cfC;

  PlatformFile? avtWork;
  String? avtTask;

  init(
    List<ScopeModel> allScopes,
    Map<String, List<WorkingUnitModel>> mapChild,
  ) async {
    listMember.clear();
    updateKey(wu);
    selectedMembers.clear();
    ResponseModel response = await _scopeService.getUsersForAddingScope(0);

    if (response.status == ResponseStatus.ok) {
      listMember = response.results ?? [];
    }

    debugPrint("====> Debug 1");
    for (var i in wu.assignees) {
      for (var j in listMember) {
        if (i == j.id) {
          selectedMembers.add(j);
          break;
        }
      }
    }
    for (var i in wu.followers) {
      for (var j in listMember) {
        if (i == j.id) {
          selectedFollowers.add(j);
          break;
        }
      }
    }
    for (var i in wu.handlers) {
      for (var j in listMember) {
        if (i == j.id) {
          selectedHandlers.add(j);
          break;
        }
      }
    }

    selectedScopes = await ConvertUtils.convertStringToScope(wu, allScopes, []);
    debugPrint("====> Debug 2");
    for (var i in selectedScopes) {
      if (i.id == wu.owner) {
        ownerScope = i;
        break;
      }
    }

    if (wu.type == TypeAssignmentDefine.task.title) {
      loadComment(wu.id);
    }

    if (wu.type == TypeAssignmentDefine.epic.title && wu.icon.isNotEmpty) {
      avtWork = await CacheUtils.instance.getFileGB(wu.icon);
    }

    debugPrint("====> Debug 3");

    if (wu.type == TypeAssignmentDefine.task.title) {
      if (wu.icon.isEmpty) {
        avtTask = "";
      } else {
        avtTask = wu.icon;
      }
    }

    mapWorkChild = {...mapChild};

    List<WorkingUnitModel> tmp;

    if (mapWorkChild.containsKey(wu.parent)) {
      tmp = mapWorkChild[wu.parent]!;
    } else {
      tmp = await _workingService.getWorkingUnitByIdParent(wu.parent);
      for (var e in tmp) {
        cfC.addWorkingUnit(e, isLocal: true);
      }
    }
    if (tmp.isNotEmpty) {
      directParent = tmp.first;
    }
    debugPrint(
      "====> init detail assignment view thanh cong: $ownerScope ${wu.owner}",
    );
    buildUI();
  }

  updateDeadline(DateTime deadline) async {
    cfC.updateWorkingUnit(
      wu.copyWith(deadline: DateTimeUtils.getTimestampWithDay(deadline)),
      wu,
    );
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(deadline: DateTimeUtils.getTimestampWithDay(deadline)),
    //     wu,
    //     user.id);
    wu.deadline = DateTimeUtils.getTimestampWithDay(deadline);
  }

  updateDescription(String txt) async {
    cfC.updateWorkingUnit(wu.copyWith(description: txt), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(description: txt), wu, user.id);
    wu.description = txt;
  }

  updateTitle(String txt) async {
    cfC.updateWorkingUnit(wu.copyWith(title: txt), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(title: txt), wu, user.id);
    wu.title = txt;
  }

  updateUrgent(DateTime urgent, context) async {
    var start = DateTimeUtils.convertToDateTime(
      DateTimeUtils.convertTimestampToDateString(wu.start),
    );
    var end = DateTimeUtils.convertToDateTime(
      DateTimeUtils.convertTimestampToDateString(wu.deadline),
    );
    if ((urgent.isBefore(end) ||
        urgent.isAtSameMomentAs(end) &&
            (start.isBefore(urgent) || start.isAtSameMomentAs(urgent)))) {
      // await _workingService.updateWorkingUnitField(
      //     wu.copyWith(urgent: DateTimeUtils.getTimestampWithDay(urgent)),
      //     wu,
      //     user.id);
      cfC.updateWorkingUnit(
        wu.copyWith(urgent: DateTimeUtils.getTimestampWithDay(urgent)),
        wu,
      );
      wu.urgent = DateTimeUtils.getTimestampWithDay(urgent);
    } else {
      DialogUtils.showResultDialog(
        context,
        AppText.titleErrorNotification.text,
        AppText.txtInvalidUrgentDate.text,
        mainColor: ColorConfig.primary3,
      );
    }
  }

  updateViewer() async {
    List<String> viewers = ConvertUtils.convertUserModelToString(
      selectedFollowers,
    );
    cfC.updateWorkingUnit(wu.copyWith(followers: viewers), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(followers: viewers), wu, user.id);
    wu.followers = viewers;
    buildUI();
  }

  updateStatus(int value) async {
    cfC.updateWorkingUnit(wu.copyWith(status: value), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(status: value), wu, user.id);
    wu.status = value;
  }

  updatePriority(String title) async {
    cfC.updateWorkingUnit(wu.copyWith(priority: title), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(priority: title), wu, user.id);
    wu.priority = title;
  }

  updateMembers(BuildContext context) async {
    List<String> members = ConvertUtils.convertUserModelToString(
      selectedMembers,
    );
    TaskAssignmentHelper helper = TaskAssignmentHelper();
    // final uri =
    //     Router.of(context).routeInformationProvider?.value.uri;
    // String path = '';
    // if (uri?.path.contains('manager') ?? false) {
    //   path = 'home/mainTab/204';
    // } else {
    //   path = 'home/manager/${wu.id}';
    // }
    // helper.assignUsersToTask(
    //   task: wu,
    //   newAssigneeIds: members,
    //   ownerId: cfC.user.id,
    //   context: context, path: path,
    // );
    cfC.updateWorkingUnit(wu.copyWith(assignees: members), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(assignees: members), wu, user.id);
    if (wu.type == TypeAssignmentDefine.task.title) {
      List<WorkingUnitModel> listChild = [];
      if (mapWorkChild.containsKey(wu.id)) {
        listChild = [...mapWorkChild[wu.id]!];
      } else {
        final data = await _workingService.getWorkingUnitByIdParent(wu.id);
        listChild = [...data];
        for (var e in data) {
          cfC.addWorkingUnit(e);
        }
      }
      for (var work in listChild) {
        cfC.updateWorkingUnit(work.copyWith(assignees: members), work);
        // _workingService.updateWorkingUnitField(
        //     work.copyWith(assignees: members), work, user.id);
      }
    }
    wu.assignees = members;
    buildUI();
  }

  updateHandlers() async {
    List<String> members = ConvertUtils.convertUserModelToString(
      selectedHandlers,
    );

    updateHandlerForChild(wu, members);

    wu.handlers = members;
    buildUI();
  }

  updateHandlerForChild(WorkingUnitModel work, List<String> handlers) async {
    final updWork = work.copyWith(handlers: handlers);
    cfC.updateWorkingUnit(updWork, work);
    // _workingService.updateWorkingUnitField(updWork, work, user.id);
    List<WorkingUnitModel> child = [];
    if (mapWorkChild.containsKey(work.id)) {
      child = [...mapWorkChild[work.id]!];
    } else {
      final data = await _workingService.getWorkingUnitByIdParent(work.id);
      mapWorkChild[work.id] = [...data];
      child = [...data];
    }
    for (var e in child) {
      updateHandlerForChild(e, handlers);
    }
  }

  updateIcon(PlatformFile file) async {
    final url = await _workingService.uploadIcon(file, wu.id);
    if (url == null) return;
    CacheUtils.instance.setFileGB(url, file);
    avtWork = file;
    cfC.updateWorkingUnit(wu.copyWith(icon: url), wu);
    // _workingService.updateWorkingUnitField(wu.copyWith(icon: url), wu, user.id);
    wu.icon = url;
    buildUI();
  }

  updateIconForTask(String file) async {
    avtTask = file;
    cfC.updateWorkingUnit(wu.copyWith(icon: file), wu);
    // _workingService.updateWorkingUnitField(
    //     wu.copyWith(icon: file), wu, user.id);
    wu.icon = file;
    buildUI();
  }

  updateWP(int point) async {
    cfC.updateWorkingUnit(wu.copyWith(workingPoint: point), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(workingPoint: point), wu, user.id);
    // wu.workingPoint = point;
  }

  updateScopes(List<ScopeModel> scopes) async {
    selectedScopes = scopes;
    List<String> tmp = selectedScopes.fold([], (prev, e) => [...prev, e.id]);
    cfC.updateWorkingUnit(wu.copyWith(scope: tmp), wu);
    // await _workingService.updateWorkingUnitField(
    //     wu.copyWith(scope: tmp), wu, user.id);
    wu.scopes = tmp;
    buildUI();
  }

  updateWU(WorkingUnitModel value) async {
    wu = value;
    updateKey(wu);
    buildUI();
  }

  updateKey(WorkingUnitModel value) {
    key =
        '${value.id}_${value.title}_${value.description}_${value.priority}_${value.workingPoint}_${value.status}_${value.urgent}_${value.start}_${value.deadline}_${value.assignees.join('-')}_${value.scopes.join('-')}_${value.okrs.join('-')}_${value.followers.join('-')}';
  }

  delete(WorkingUnitModel model, {bool isTask = true}) async {
    if (isTask) {
      deleteChild(model);
    } else {
      cfC.updateWorkingUnit(model.copyWith(enable: false), model);
      // await _workingService.updateWorkingUnitField(
      //     model.copyWith(enable: false), model, user.id);
    }
    buildUI();
  }

  deleteChild(WorkingUnitModel work) async {
    cfC.updateWorkingUnit(work.copyWith(enable: false), work);
    // await _workingService.updateWorkingUnitField(
    //     work.copyWith(enable: false), work, user.id);
    List<WorkingUnitModel> listWorkChild = [];
    if (mapWorkChild.containsKey(work.id)) {
      listWorkChild = [...mapWorkChild[work.id]!];
    } else {
      final data = await _workingService.getWorkingUnitByIdParent(work.id);
      listWorkChild = [...data];
      for (var e in data) {
        cfC.addWorkingUnit(e);
      }
    }

    for (var workChild in listWorkChild) {
      deleteChild(workChild);
    }
  }

  loadComment(String idWork) async {
    loadingComment++;
    listComments.clear();
    buildUI();
    final comments = await _commentService.getCommentByPosition(
      "${CommentTypeDefine.workingUnit.title}_$idWork",
    );
    comments.sort((a, b) => b.date.compareTo(a.date));
    listComments.addAll(comments);
    loadingComment--;
    buildUI();
  }

  addNewComment(CommentModel cmt) {
    listComments.insert(0, cmt);
    buildUI();
  }

  deleteComment(CommentModel cmt) {
    int index = listComments.indexWhere((e) => e.id == cmt.id);
    if (index != -1) {
      listComments.removeAt(index);
    }
    buildUI();
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }
}
