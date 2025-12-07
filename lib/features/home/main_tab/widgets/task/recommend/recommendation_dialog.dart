import 'package:flutter/material.dart';
import 'package:whms/models/recommend_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/recommend_service.dart';

class EmployeeRecommendationDialog extends StatefulWidget {
  final WorkingUnitModel task;
  final List<UserModel>? availableUsers;
  final Function(List<String> selectedUserIds)? onUsersSelected;
  final String? apiUrl;

  const EmployeeRecommendationDialog({
    Key? key,
    required this.task,
    this.availableUsers,
    this.onUsersSelected,
    this.apiUrl,
  }) : super(key: key);

  @override
  State<EmployeeRecommendationDialog> createState() =>
      _EmployeeRecommendationDialogState();
}

class _EmployeeRecommendationDialogState
    extends State<EmployeeRecommendationDialog> {
  final _service = RecommendationService();

  bool _isLoading = false;
  String? _error;
  RecommendationResponseModel? _response;
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    // Set custom API URL if provided
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_search, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
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
            Expanded(
              child: _buildBody(),
            ),

            // Footer with actions
            if (_response != null && _response!.recommendations.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã chọn: ${_selectedUserIds.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectedUserIds.isEmpty
                              ? null
                              : () {
                            widget.onUsersSelected
                                ?.call(_selectedUserIds.toList());
                            Navigator.pop(context);
                          },
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang phân tích và tìm nhân sự phù hợp...'),
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải gợi ý',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_response == null || _response!.recommendations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy nhân sự phù hợp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Hệ thống chưa có đủ dữ liệu để gợi ý',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tìm thấy ${_response!.recommendations.length} nhân sự phù hợp '
                      '(từ ${_response!.totalCandidates} ứng viên)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
              final isSelected = _selectedUserIds.contains(rec.employeeId);

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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedUserIds.remove(rec.employeeId);
            } else {
              _selectedUserIds.add(rec.employeeId);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rec.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedUserIds.add(rec.employeeId);
                        } else {
                          _selectedUserIds.remove(rec.employeeId);
                        }
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  _buildStatChip(
                    Icons.score,
                    'Điểm: $scorePercent%',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.work_outline,
                    'Đang làm: ${rec.currentWorkload}',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.history,
                    'Đã làm: ${rec.matchingTasksCount}',
                    Colors.green,
                  ),
                ],
              ),

              if (rec.major.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Chuyên môn: ${rec.major}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],

              // Expandable breakdown
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Chi tiết điểm số',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                children: [
                  const SizedBox(height: 8),
                  _buildScoreBar(
                    'Độ tương đồng',
                    rec.breakdown.similarityScore,
                    Colors.blue,
                  ),
                  _buildScoreBar(
                    'Cùng dự án',
                    rec.breakdown.hierarchyBonus,
                    Colors.green,
                  ),
                  _buildScoreBar(
                    'Khối lượng công việc',
                    rec.breakdown.workloadPenalty,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                '${(score * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }
}