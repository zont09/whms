import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/widgets/task/recommend/recommendation_dialog.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/widgets/avatar_item.dart';

class EmployeeRecommendationButton extends StatelessWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers;
  final Function(String selectedUserIds)? onUsersSelected;
  final String? apiUrl;

  const EmployeeRecommendationButton({
    Key? key,
    required this.task,
    this.availableUsers,
    this.onUsersSelected,
    this.apiUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRecommendationDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.psychology_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EmployeeRecommendationDialog(
        task: task,
        availableUsers: availableUsers,
        onUserSelected: onUsersSelected,
        apiUrl: apiUrl,
        avatarBuilder: (v) {
          return AvatarItem(v, size: 56);
        },
      ),
    );
  }
}
/// Icon button version - nhỏ gọn hơn
class EmployeeRecommendationIconButton extends StatelessWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers;
  final Function(String selectedUserIds)? onUsersSelected;
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
        onUserSelected: onUsersSelected,
        apiUrl: apiUrl,
        avatarBuilder: (v) {
          return AvatarItem(v, size: 56);
        },
      ),
    );
  }
}