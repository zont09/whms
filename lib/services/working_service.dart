import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/main.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/repositories/working_repository.dart';
import 'package:whms/services/notification_service.dart';

class WorkingService {
  WorkingService._privateConstructor();

  static WorkingService instance = WorkingService._privateConstructor();

  // final WorkingRepository _userRepository = WorkingRepository.instance;

  // ========= WORKING UNIT =========

  // Future<List<WorkingUnitModel>> getAllWorkingUnit() async {
  //   final result = (await WorkingRepository.instance.getAllWorkingUnit())
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getAllWorkingUnitOfUserByClosed(
  //     String iU) async {
  //   final result =
  //       (await WorkingRepository.instance.getAllWorkingUnitOfUserByClosed(iU))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getWorkingUnitClosedOfUserUpdated(
  //     DateTime date, String iU) async {
  //   final result = (await WorkingRepository.instance
  //           .getWorkingUnitClosedForUserUpdated(date, iU))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getAllWorkingUnitIgnoreEnable() async {
  //   final result =
  //       (await WorkingRepository.instance.getAllWorkingUnitIgnoreEnable())
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getAllWorkingUnitIgnoreClosed() async {
  //   final result =
  //       (await WorkingRepository.instance.getAllWorkingUnitIgnoreClosed())
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getWorkingUnitUpdateAfterDate(
  //     DateTime date) async {
  //   final result =
  //       (await WorkingRepository.instance.getWorkingUnitAfterDate(date))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  Future<List<WorkingUnitModel>> getWorkingUnitClosedForUserUpdated(
    DateTime date,
    String idU,
  ) async {
    final response = await WorkingRepository.instance
        .getWorkingUnitClosedForUserUpdated(date, idU);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<ResponseModel<List<WorkingUnitModel>>> getProjectsForUser(
    String userId,
  ) async {
    return await WorkingRepository.instance.getProjectsForUser(userId);
  }

  Future<WorkingUnitModel?> getProjectById(String projectId) async {
    return await WorkingRepository.instance.getProjectById(projectId);
  }

  Future<ResponseModel<Map<String, List<WorkingUnitModel>>>>
  getScopesAndProjectsForUser(String userId) async {
    return await WorkingRepository.instance.getScopesAndProjectsForUser(userId);
  }

  Future<List<WorkingUnitModel>> getWorkingUnitForUserUpdated(
    DateTime date,
    String idU,
  ) async {
    final response = await WorkingRepository.instance
        .getWorkingUnitForUserUpdated(date, idU);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  // Future<List<WorkingUnitModel>> getAllTaskInScopeIgnoreClosed(
  //     String scp) async {
  //   final result =
  //       (await WorkingRepository.instance.getAllTaskInScopeIgnoreClosed(scp))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  Future<List<WorkingUnitModel>>
  getAllWorkingUnitInScopeByTypeIgnoreClosedUpdate(
    DateTime date,
    String idU,
    String type,
  ) async {
    final response = await WorkingRepository.instance
        .getAllWorkingUnitInScopeByTypeIgnoreClosedUpdated(date, idU, type);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  // Future<List<WorkingUnitModel>> getAllEpicInScopeIgnoreClosed(
  //     String scp) async {
  //   final result =
  //       (await WorkingRepository.instance.getAllEpicInScopeIgnoreClosed(scp))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getAllTaskFollowing(String id) async {
  //   final result = (await WorkingRepository.instance.getAllTaskFollowing(id))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  Future<WorkingUnitModel?> getWorkingUnitById(String id) async {
    final result = (await WorkingRepository.instance.getWorkingUnitById(
      id,
    )).docs.map((e) => WorkingUnitModel.fromSnapshot(e)).firstOrNull;
    return result;
  }

  // Future<WorkingUnitModel?> getWorkingUnitByIdIgnoreEnable(String id) async {
  //   final result =
  //       (await WorkingRepository.instance.getWorkingUnitByIdIgnoreEnable(id))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .firstOrNull;
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getEpicByScopeIgnoreClosed(String id) async {
  //   final result =
  //       (await WorkingRepository.instance.getEpicByScopeIgnoreClosed(id))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  Future<List<WorkingUnitModel>> getWorkingUnitAsOkrs(
    String okrsGroup,
    String type,
  ) async {
    final result = (await WorkingRepository.instance.getWorkingUnitAsOkrs(
      okrsGroup,
      type,
    )).docs.map((e) => WorkingUnitModel.fromSnapshot(e)).toList();
    return result;
  }

  // Future<List<WorkingUnitModel>?> getWorkingUnitByIdScope(String id) async {
  //   final result =
  //       (await WorkingRepository.instance.getWorkingUnitByScopeId(id))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  Future<WorkingUnitModel?> getWorkingUnitByIdIgnoreClosed(String id) async {
    final result =
        (await WorkingRepository.instance.getWorkingUnitByIdIgnoreClosed(
          id,
        )).docs.map((e) => WorkingUnitModel.fromSnapshot(e)).firstOrNull;
    return result;
  }

  // Future<List<WorkingUnitModel>> getWorkingUnitByScopeId(String id,
  //     {bool isAll = false}) async {
  //   final result = (await WorkingRepository.instance
  //           .getWorkingUnitByScopeId(id, isAll: isAll))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getWorkingUnitByScopeId(String id,
  //     {bool isAll = false}) async {
  //   final result = (await WorkingRepository.instance
  //           .getWorkingUnitByScopeId(id, isAll: isAll))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  Future<List<WorkingUnitModel>> getWorkingUnitByScopeIdUpdated(
    DateTime date,
    String id, {
    bool isAll = false,
  }) async {
    final response = await WorkingRepository.instance
        .getWorkingUnitByScopeIdUpdated(date, id, isAll: isAll);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  // Future<List<WorkingUnitModel>> getWorkingUnitByScopeIdWithClosed(
  //     String id) async {
  //   final result =
  //       (await WorkingRepository.instance.getWorkingUnitByScopeId(id))
  //           .docs
  //           .map((e) => WorkingUnitModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getSSTByScopeIdIC(String id) async {
  //   final result = (await WorkingRepository.instance.getSSTByScopeIdIC(id))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getWorkingUnitByIdUser(String id) async {
  //   final result = (await WorkingRepository.instance.getWorkingUnitByIdUser(id))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  // Future<List<WorkingUnitModel>> getWorkingUnitByIdUserIgnoreClosed(
  //     String id) async {
  //   final result = (await WorkingRepository.instance
  //           .getWorkingUnitByIdUserIgnoreClosed(id))
  //       .docs
  //       .map((e) => WorkingUnitModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  Future<List<WorkingUnitModel>> getWorkingUnitByIdParent(String id) async {
    final result = (await WorkingRepository.instance.getWorkingUnitByParent(
      id,
    )).docs.map((e) => WorkingUnitModel.fromSnapshot(e)).toList();
    return result;
  }

  Future<List<WorkingUnitModel>> getWorkingUnitByIdParentIgnoreClosed(
    String id,
  ) async {
    final result =
        (await WorkingRepository.instance.getWorkingUnitByParentIgnoreClosed(
          id,
        )).docs.map((e) => WorkingUnitModel.fromSnapshot(e)).toList();
    return result;
  }

  Future<List<WorkingUnitModel>> getWorkingUnitByIdParentIgnoreClosedUpdated(
    DateTime date,
    String id,
  ) async {
    final response = await WorkingRepository.instance
        .getWorkingUnitByParentIgnoreClosedUpdated(date, id);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<void> addNewWorkingUnit(WorkingUnitModel model) async {
    await WorkingRepository.instance.createWorkingUnit(model);
    debugPrint("=========> Add new working unit: ${model.id} ${model.title}");
  }

  // Future<void> updateWorkingUnit(WorkingUnitModel model, String idU) async {
  //   await WorkingRepository.instance.updateWorkingUnit(model, idU);
  // }

  Future<void> updateWorkingUnitField(
    WorkingUnitModel model,
    WorkingUnitModel oldModel,
    String idU, {
    bool isGetUpdateTime = true,
    bool isUpdateAnnounces = false,
    StatusCheckInDefine? checkInStatus,
  }) async {
    // Lưu vào database trước
    await WorkingRepository.instance.updateWorkingUnitField(
      model,
      oldModel,
      idU,
      isGetUpdateTime: isGetUpdateTime,
      isUpdateAnnounces: isUpdateAnnounces,
    );

    debugPrint("=========> Update working unit: ${model.id} ${model.title}");

    // ===== XỬ LÝ THÔNG BÁO =====
    if(model.type != TypeAssignmentDefine.task.title) return;
    final uri = mainRouter.routeInformationProvider.value.uri;
    String path = '';
    if (uri.path.contains('manager') ?? false) {
      path = 'home/mainTab/204';
    } else {
      path = 'home/manager/${model.id}';
    }

    // 1. Kiểm tra thay đổi status (chỉ khi check-out)
    if (model.status != oldModel.status && checkInStatus != null) {
      await NotificationService.instance.notifyTaskStatusUpdate(
        task: model,
        updaterId: idU,
        oldStatus: oldModel.status,
        newStatus: model.status,
        checkInStatus: checkInStatus,
        path: path,
      );
    }

    // 2. Kiểm tra thay đổi assignees (gắn/gỡ người)
    if (model.assignees != oldModel.assignees) {
      // Tìm người được gắn mới
      final newAssignees = model.assignees
          .where((id) => !oldModel.assignees.contains(id))
          .toList();

      if (newAssignees.isNotEmpty) {
        await NotificationService.instance.notifyTaskAssigned(
          task: model,
          ownerId: idU,
          newAssignees: newAssignees,
          path: path,
        );
      }

      // Tìm người bị gỡ
      final removedAssignees = oldModel.assignees
          .where((id) => !model.assignees.contains(id))
          .toList();

      if (removedAssignees.isNotEmpty) {
        await NotificationService.instance.notifyTaskUnassigned(
          task: model,
          ownerId: idU,
          removedAssignees: removedAssignees,
          path: path,
        );
      }
    }
  }

  Future<String?> uploadFile(PlatformFile file, String wuId) async {
    String? url = await WorkingRepository.instance.uploadFile(file, wuId);
    return url;
  }

  Future<String?> uploadIcon(PlatformFile file, String wuId) async {
    String? url = await WorkingRepository.instance.uploadIcon(file, wuId);
    return url;
  }

  // ========= WORKING FIELD =========

  // Future<List<WorkFieldModel>> getAllWorkField() async {
  //   final result = (await WorkingRepository.instance.getAllWorkField())
  //       .docs
  //       .map((e) => WorkFieldModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }
  //
  // Future<List<WorkFieldModel>> getAllWorkFieldIgnoreEnable() async {
  //   final result =
  //       (await WorkingRepository.instance.getAllWorkFieldIgnoreEnable())
  //           .docs
  //           .map((e) => WorkFieldModel.fromSnapshot(e))
  //           .toList();
  //   return result;
  // }

  Future<List<WorkFieldModel>> getWorkFieldByIdWorkShift(String id) async {
    final result = (await WorkingRepository.instance.getWorkFieldByWorkShift(
      id,
    )).docs.map((e) => WorkFieldModel.fromSnapshot(e)).toList();
    return result;
  }

  Future<List<WorkFieldModel>> getWorkFieldByIdWorkShiftUpdated(
    DateTime date,
    String id,
  ) async {
    final result =
        (await WorkingRepository.instance.getWorkFieldByWorkShiftUpdated(
          id,
          date,
        )).docs.map((e) => WorkFieldModel.fromSnapshot(e)).toList();
    return result;
  }

  Future<WorkFieldModel?> getWorkFieldByWorkShiftAndIdWork(
    String idWS,
    String idWU,
  ) async {
    final result =
        (await WorkingRepository.instance.getWorkFieldByWorkShiftAndIdQuest(
          idWS,
          idWU,
        )).docs.map((e) => WorkFieldModel.fromSnapshot(e)).firstOrNull;
    return result;
  }

  Future<WorkFieldModel?> getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
    String idWS,
    String idWU,
  ) async {
    final result =
        (await WorkingRepository.instance
                .getWorkFieldByWorkShiftAndIdQuestIgnoreEnable(idWS, idWU))
            .docs
            .map((e) => WorkFieldModel.fromSnapshot(e))
            .firstOrNull;
    return result;
  }

  // Future<WorkFieldModel?> getWorkFieldByIdUser(String id) async {
  //   final result = (await WorkingRepository.instance.getWorkFieldById(id))
  //       .docs
  //       .map((e) => WorkFieldModel.fromSnapshot(e))
  //       .firstOrNull;
  //   return result;
  // }

  Future<void> addNewWorkField(WorkFieldModel model) async {
    await WorkingRepository.instance.createWorkField(model);
    debugPrint("=========> Add new work field: ${model.id} ${model.workShift}");
  }

  // Future<void> updateWorkField(WorkFieldModel model) async {
  //   await WorkingRepository.instance.updateWorkField(model);
  // }

  Future<void> updateWorkFieldWithField(
    WorkFieldModel model,
    WorkFieldModel preModel,
  ) async {
    await WorkingRepository.instance.updateWorkFieldWithField(model, preModel);
    debugPrint("=========> Update work field: ${model.id} ${model.workShift}");
  }
}
