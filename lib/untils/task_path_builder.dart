import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';

/// Helper class để xây dựng đường dẫn từ root đến task
class TaskPathBuilder {
  final WorkingService _workingService = WorkingService.instance;

  /// Xây dựng đường dẫn từ root đến task
  /// Trả về list các ID từ root (project/scope) đến task hiện tại
  /// Ví dụ: [projectId, epicId, storyId, taskId]
  Future<List<String>> buildPathToTask(WorkingUnitModel task) async {
    final path = <String>[];
    WorkingUnitModel? currentTask = task;

    // Traverse từ task lên đến root
    while (currentTask != null) {
      path.insert(0, currentTask.id);

      // Nếu có parent, lấy parent task
      if (currentTask.parent.isNotEmpty) {
        currentTask = await _getTaskById(currentTask.parent);
      } else {
        // Đã đến root (không có parent)
        break;
      }
    }

    return path;
  }

  /// Xây dựng đường dẫn với thông tin chi tiết
  /// Trả về list các object chứa ID và title
  Future<List<TaskPathNode>> buildDetailedPathToTask(WorkingUnitModel task) async {
    final path = <TaskPathNode>[];
    WorkingUnitModel? currentTask = task;

    // Traverse từ task lên đến root
    while (currentTask != null) {
      path.insert(0, TaskPathNode(
        id: currentTask.id,
        title: currentTask.title,
        type: currentTask.type,
      ));

      // Nếu có parent, lấy parent task
      if (currentTask.parent.isNotEmpty) {
        currentTask = await _getTaskById(currentTask.parent);
      } else {
        // Đã đến root
        break;
      }
    }

    return path;
  }

  /// Xây dựng breadcrumb string
  /// Ví dụ: "Project A > Epic B > Story C > Task D"
  Future<String> buildBreadcrumb(WorkingUnitModel task, {String separator = ' > '}) async {
    final detailedPath = await buildDetailedPathToTask(task);
    return detailedPath.map((node) => node.title).join(separator);
  }

  /// Helper method để lấy task theo ID
  Future<WorkingUnitModel?> _getTaskById(String id) async {
    try {
      return await _workingService.getWorkingUnitById(id);
    } catch (e) {
      print('Error getting task by ID: $e');
      return null;
    }
  }

  /// Validate path - kiểm tra xem path có hợp lệ không
  Future<bool> validatePath(List<String> path) async {
    if (path.isEmpty) return false;

    for (int i = 0; i < path.length; i++) {
      final task = await _getTaskById(path[i]);
      if (task == null) return false;

      // Kiểm tra parent relationship (trừ node đầu tiên)
      if (i > 0) {
        if (task.parent != path[i - 1]) {
          return false;
        }
      }
    }

    return true;
  }

  /// Lấy task cuối cùng trong path (leaf task)
  Future<WorkingUnitModel?> getLeafTask(List<String> path) async {
    if (path.isEmpty) return null;
    return await _getTaskById(path.last);
  }

  /// Lấy task root trong path
  Future<WorkingUnitModel?> getRootTask(List<String> path) async {
    if (path.isEmpty) return null;
    return await _getTaskById(path.first);
  }
}

/// Class đại diện cho một node trong path
class TaskPathNode {
  final String id;
  final String title;
  final String type;

  TaskPathNode({
    required this.id,
    required this.title,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
  };

  factory TaskPathNode.fromJson(Map<String, dynamic> json) => TaskPathNode(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    type: json['type'] ?? '',
  );

  @override
  String toString() => '$type: $title ($id)';
}
