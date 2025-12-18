import 'package:flutter/material.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/recommend_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/recommend_service.dart';
import 'package:whms/untils/cache_utils.dart';

class EmployeeRecommendationDialog extends StatefulWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers;
  final Function(String selectedUserId)? onUserSelected; // Đổi thành chọn 1
  final String? apiUrl;
  final Widget Function(String employeeId)? avatarBuilder; // Hàm build avatar

  const EmployeeRecommendationDialog({
    Key? key,
    required this.task,
    this.availableUsers,
    this.onUserSelected,
    this.apiUrl,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  State<EmployeeRecommendationDialog> createState() =>
      _EmployeeRecommendationDialogState();
}

class _EmployeeRecommendationDialogState
    extends State<EmployeeRecommendationDialog> {
  static const Color primary1 = Color(0xFF0448db);
  static const Color primary2 = Color(0xFF006df5);
  static const Color primary3 = Color(0xFF0086f3);
  static const Color primary4 = Color(0xFF0099d8);
  static const Color primary5 = Color(0xFFabc5ff);

  final _service = RecommendationService();

  bool _isLoading = false;
  String? _error;
  RecommendationResponseModel? _response;
  String? _selectedUserId; // Chỉ chọn 1
  late final Map<String, UserModel> mapUser;

  @override
  void initState() {
    super.initState();
    mapUser = ConfigsCubit.fromContext(context).usersMap;
    if (widget.apiUrl != null) {
      _service.baseUrl = widget.apiUrl!;
    }
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _service.recommendEmployees(
        title: widget.task.title,
        description: widget.task.description,
        type: widget.task.type,
        parent: widget.task.parent,
        topK: 10,
      );

      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary2, primary3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gợi ý nhân sự',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(child: _buildBody()),

            // Footer with actions
            if (_response != null && _response!.recommendations.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedUserId != null
                          ? 'Đã chọn 1 ứng viên'
                          : 'Chưa chọn',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedUserId != null
                            ? primary2
                            : Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectedUserId == null
                              ? null
                              : () {
                                  widget.onUserSelected?.call(_selectedUserId!);
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary2,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primary3),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary5.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.psychology, color: primary2, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Đang phân tích và tìm nhân sự phù hợp...',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Không thể tải gợi ý',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary2,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_response == null || _response!.recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Không tìm thấy nhân sự phù hợp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống chưa có đủ dữ liệu để gợi ý',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary5.withOpacity(0.3), primary5.withOpacity(0.1)],
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: primary2, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tìm thấy ${_response!.recommendations.length} nhân sự phù hợp '
                  '(từ ${_response!.totalCandidates} ứng viên)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primary1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _response!.recommendations.length,
            itemBuilder: (context, index) {
              final rec = _response!.recommendations[index];
              final isSelected = _selectedUserId == rec.employeeId;

              return _buildRecommendationCard(rec, index + 1, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    EmployeeRecommendationModel rec,
    int rank,
    bool isSelected,
  ) {
    final scorePercent = (rec.finalScore * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primary2 : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary5.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedUserId = isSelected ? null : rec.employeeId;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        widget.avatarBuilder != null &&
                                mapUser[rec.employeeId] != null &&
                                mapUser[rec.employeeId]!.avt.isNotEmpty
                            ? widget.avatarBuilder!(
                                mapUser[rec.employeeId]!.avt,
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primary2, primary4],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    rec.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        // Rank badge
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getRankColor(rank),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Name and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (rec.major.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.school, size: 14, color: primary3),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    rec.major,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Radio button
                    Radio<String>(
                      value: rec.employeeId,
                      groupValue: _selectedUserId,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                      activeColor: primary2,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Score card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary5.withOpacity(0.2),
                        primary5.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.stars,
                        'Độ phù hợp',
                        '$scorePercent%',
                        primary2,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem(
                        Icons.work_outline,
                        'Đang làm',
                        '${rec.currentWorkload}',
                        primary3,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildStatItem(
                        Icons.history,
                        'Đã hoàn thành',
                        '${rec.matchingTasksCount}',
                        primary4,
                      ),
                    ],
                  ),
                ),

                // Expandable breakdown
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 16,
                          color: primary2,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Chi tiết điểm số',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      const SizedBox(height: 8),
                      _buildScoreBar(
                        'Độ tương đồng',
                        rec.breakdown.similarityScore,
                        primary2,
                      ),
                      _buildScoreBar(
                        'Cùng dự án',
                        rec.breakdown.hierarchyBonus,
                        primary3,
                      ),
                      _buildScoreBar(
                        'Khối lượng công việc',
                        rec.breakdown.workloadPenalty,
                        primary4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(score * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return primary2;
  }
}
