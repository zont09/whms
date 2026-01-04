import 'package:flutter/material.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/notification_service.dart';
import 'package:whms/services/working_service.dart';

/// Helper class để xử lý việc gán/gỡ người làm task với thông báo
class TaskAssignmentHelper {
  final WorkingService _workingService = WorkingService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  /// Gán người làm vào task
  /// [task] - Task cần gán người
  /// [newAssigneeIds] - List ID của người được gán thêm
  /// [ownerId] - ID của owner (người thực hiện gán)
  /// [context] - BuildContext để cập nhật UI
  Future<bool> assignUsersToTask({
    required WorkingUnitModel task,
    required List<String> newAssigneeIds,
    required String ownerId,
    required BuildContext context,
    required String path,
  }) async {
    if(task.type != TypeAssignmentDefine.task.title) return false;
    debugPrint("[THINK] ====> create noti in here: ${path}");
    try {
      // Lưu lại danh sách assignees cũ
      final oldTask = task.copyWith();

      // Tạo danh sách assignees mới (merge với list cũ, loại bỏ duplicate)
      final updatedAssignees = [
        ...task.assignees,
        ...newAssigneeIds.where((id) => !task.assignees.contains(id)),
      ];

      // Tạo task mới với assignees đã cập nhật
      final updatedTask = task.copyWith(assignees: updatedAssignees);

      // Cập nhật vào ConfigsCubit (local state)
      if (context.mounted) {
        final configsCubit = ConfigsCubit.fromContext(context);
        configsCubit.updateWorkingUnit(updatedTask, oldTask);
      }

      // Gửi thông báo cho những người được gán mới
      await _notificationService.notifyTaskAssigned(
        task: updatedTask,
        ownerId: ownerId,
        newAssignees: newAssigneeIds, path: path,
      );

      debugPrint(
          "=========> Assigned ${newAssigneeIds.length} users to task: ${task.title}");
      return true;
    } catch (e) {
      debugPrint("Error assigning users to task: $e");
      return false;
    }
  }

  /// Gỡ người làm khỏi task
  /// [task] - Task cần gỡ người
  /// [removeAssigneeIds] - List ID của người bị gỡ
  /// [ownerId] - ID của owner (người thực hiện gỡ)
  /// [context] - BuildContext để cập nhật UI
  Future<bool> removeUsersFromTask({
    required WorkingUnitModel task,
    required List<String> removeAssigneeIds,
    required String ownerId,
    required BuildContext context,
    required String path,
  }) async {
    try {
      // Lưu lại danh sách assignees cũ
      final oldTask = task.copyWith();

      // Tạo danh sách assignees mới (loại bỏ những người bị gỡ)
      final updatedAssignees = task.assignees
          .where((id) => !removeAssigneeIds.contains(id))
          .toList();

      // Tạo task mới với assignees đã cập nhật
      final updatedTask = task.copyWith(assignees: updatedAssignees);

      // Cập nhật vào ConfigsCubit (local state)
      if (context.mounted) {
        final configsCubit = ConfigsCubit.fromContext(context);
        configsCubit.updateWorkingUnit(updatedTask, oldTask);
      }

      // Gửi thông báo cho những người bị gỡ
      await _notificationService.notifyTaskUnassigned(
        task: updatedTask,
        ownerId: ownerId,
        removedAssignees: removeAssigneeIds, path: path,
      );

      debugPrint(
          "=========> Removed ${removeAssigneeIds.length} users from task: ${task.title}");
      return true;
    } catch (e) {
      debugPrint("Error removing users from task: $e");
      return false;
    }
  }

  /// Thay đổi toàn bộ danh sách assignees (xử lý cả assign và unassign)
  /// [task] - Task cần cập nhật
  /// [newAssigneeIds] - Danh sách assignees mới hoàn chỉnh
  /// [ownerId] - ID của owner
  /// [context] - BuildContext để cập nhật UI
  // Future<bool> updateTaskAssignees({
  //   required WorkingUnitModel task,
  //   required List<String> newAssigneeIds,
  //   required String ownerId,
  //   required BuildContext context,
  //   required String path,
  // }) async {
  //   try {
  //     // Lưu lại danh sách assignees cũ
  //     final oldTask = task.copyWith();
  //
  //     // Tìm người được gán mới
  //     final addedAssignees = newAssigneeIds
  //         .where((id) => !task.assignees.contains(id))
  //         .toList();
  //
  //     // Tìm người bị gỡ
  //     final removedAssignees = task.assignees
  //         .where((id) => !newAssigneeIds.contains(id))
  //         .toList();
  //
  //     // Tạo task mới với assignees đã cập nhật
  //     final updatedTask = task.copyWith(assignees: newAssigneeIds);
  //
  //     // Cập nhật vào ConfigsCubit (local state)
  //     if (context.mounted) {
  //       final configsCubit = ConfigsCubit.fromContext(context);
  //       configsCubit.updateWorkingUnit(updatedTask, oldTask);
  //     }
  //
  //     // Gửi thông báo cho người được gán mới
  //     if (addedAssignees.isNotEmpty) {
  //       await _notificationService.notifyTaskAssigned(
  //         task: updatedTask,
  //         ownerId: ownerId,
  //         newAssignees: addedAssignees,
  //         path: path,
  //       );
  //     }
  //
  //     // Gửi thông báo cho người bị gỡ
  //     if (removedAssignees.isNotEmpty) {
  //       await _notificationService.notifyTaskUnassigned(
  //         task: updatedTask,
  //         ownerId: ownerId,
  //         removedAssignees: removedAssignees,
  //         path: path,
  //       );
  //     }
  //
  //     debugPrint(
  //         "=========> Updated assignees for task: ${task.title} (+${addedAssignees.length}, -${removedAssignees.length})");
  //     return true;
  //   } catch (e) {
  //     debugPrint("Error updating task assignees: $e");
  //     return false;
  //   }
  // }
  //
  // /// Gán một người vào task (shorthand)
  // Future<bool> assignSingleUser({
  //   required WorkingUnitModel task,
  //   required String assigneeId,
  //   required String ownerId,
  //   required BuildContext context,
  //   required String path,
  // }) async {
  //   return await assignUsersToTask(
  //     task: task,
  //     newAssigneeIds: [assigneeId],
  //     ownerId: ownerId,
  //     context: context,
  //     path: path,
  //   );
  // }
  //
  // /// Gỡ một người khỏi task (shorthand)
  // Future<bool> removeSingleUser({
  //   required WorkingUnitModel task,
  //   required String assigneeId,
  //   required String ownerId,
  //   required BuildContext context,
  //   required String path,
  // }) async {
  //   return await removeUsersFromTask(
  //     task: task,
  //     removeAssigneeIds: [assigneeId],
  //     ownerId: ownerId,
  //     context: context,
  //     path: path,
  //   );
  // }
}
