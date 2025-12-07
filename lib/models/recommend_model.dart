class RecommendationBreakdownModel {
  final double similarityScore;
  final double hierarchyBonus;
  final double workloadPenalty;

  RecommendationBreakdownModel({
    required this.similarityScore,
    required this.hierarchyBonus,
    required this.workloadPenalty,
  });

  factory RecommendationBreakdownModel.fromJson(Map<String, dynamic> json) =>
      RecommendationBreakdownModel(
        similarityScore: (json['similarity_score'] ?? 0).toDouble(),
        hierarchyBonus: (json['hierarchy_bonus'] ?? 0).toDouble(),
        workloadPenalty: (json['workload_penalty'] ?? 0).toDouble(),
      );
}

class EmployeeRecommendationModel {
  final String employeeId;
  final String name;
  final String email;
  final String major;
  final double finalScore;
  final RecommendationBreakdownModel breakdown;
  final int matchingTasksCount;
  final int currentWorkload;

  EmployeeRecommendationModel({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.major,
    required this.finalScore,
    required this.breakdown,
    required this.matchingTasksCount,
    required this.currentWorkload,
  });

  factory EmployeeRecommendationModel.fromJson(Map<String, dynamic> json) =>
      EmployeeRecommendationModel(
        employeeId: json['employee_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        major: json['major'] ?? '',
        finalScore: (json['final_score'] ?? 0).toDouble(),
        breakdown: RecommendationBreakdownModel.fromJson(json['breakdown'] ?? {}),
        matchingTasksCount: json['matching_tasks_count'] ?? 0,
        currentWorkload: json['current_workload'] ?? 0,
      );
}

class RecommendationResponseModel {
  final List<EmployeeRecommendationModel> recommendations;
  final int totalCandidates;

  RecommendationResponseModel({
    required this.recommendations,
    required this.totalCandidates,
  });

  factory RecommendationResponseModel.fromJson(Map<String, dynamic> json) =>
      RecommendationResponseModel(
        recommendations: (json['recommendations'] as List?)
            ?.map((e) => EmployeeRecommendationModel.fromJson(e))
            .toList() ??
            [],
        totalCandidates: json['total_candidates'] ?? 0,
      );
}
