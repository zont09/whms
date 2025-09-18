import 'package:whms/models/user_model.dart';

class UserOverviewData {
  final UserModel user;
  final int logTime;
  final int workingPoint;
  final int workingTime;
  final int taskDone;
  final int taskDoing;
  final int taskOther;

  UserOverviewData({
    required this.user,
    required this.logTime,
    required this.workingPoint,
    required this.workingTime,
    required this.taskDone,
    required this.taskDoing,
    required this.taskOther,
  });

  UserOverviewData copyWith({
    UserModel? user,
    int? logTime,
    int? workingPoint,
    int? workingTime,
    int? taskDone,
    int? taskDoing,
    int? taskOther,
  }) {
    return UserOverviewData(
      user: user ?? this.user,
      logTime: logTime ?? this.logTime,
      workingPoint: workingPoint ?? this.workingPoint,
      workingTime: workingTime ?? this.workingTime,
      taskDone: taskDone ?? this.taskDone,
      taskDoing: taskDoing ?? this.taskDoing,
      taskOther: taskOther ?? this.taskOther,
    );
  }
}
