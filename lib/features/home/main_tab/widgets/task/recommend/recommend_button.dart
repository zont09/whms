import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/widgets/task/recommend/recommendation_dialog.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/models/user_model.dart';

/// Widget button để gợi ý nhân sự
/// Chỉ cần truyền WorkingUnitModel và danh sách users
class EmployeeRecommendationButton extends StatelessWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers; // Null = lấy từ API
  final Function(List<String> selectedUserIds)? onUsersSelected;
  final String? apiUrl; // Tùy chọn: override API URL

  const EmployeeRecommendationButton({
    Key? key,
    required this.task,
    this.availableUsers,
    this.onUsersSelected,
    this.apiUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showRecommendationDialog(context),
      icon: const Icon(Icons.person_search, size: 20),
      label: const Text('Gợi ý nhân sự'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EmployeeRecommendationDialog(
        task: task,
        availableUsers: availableUsers,
        onUsersSelected: onUsersSelected,
        apiUrl: apiUrl,
      ),
    );
  }
}

/// Icon button version - nhỏ gọn hơn
class EmployeeRecommendationIconButton extends StatelessWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers;
  final Function(List<String> selectedUserIds)? onUsersSelected;
  final String? apiUrl;

  const EmployeeRecommendationIconButton({
    Key? key,
    required this.task,
    this.availableUsers,
    this.onUsersSelected,
    this.apiUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showRecommendationDialog(context),
      icon: const Icon(Icons.person_search),
      tooltip: 'Gợi ý nhân sú',
    );
  }

  void _showRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EmployeeRecommendationDialog(
        task: task,
        availableUsers: availableUsers,
        onUsersSelected: onUsersSelected,
        apiUrl: apiUrl,
      ),
    );
  }
}