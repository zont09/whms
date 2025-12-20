import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/views/meeting/meeting_online.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/services/meeting_service.dart';

// Import model và các file cần thiết
// import 'meeting_model.dart';
// import 'improved_video_call.dart';

class MeetingJoinPage extends StatefulWidget {
  final String roomId;
  final String userId;

  const MeetingJoinPage({
    super.key,
    required this.roomId,
    required this.userId,
  });

  @override
  State<MeetingJoinPage> createState() => _MeetingJoinPageState();
}

class _MeetingJoinPageState extends State<MeetingJoinPage> {
  bool _isLoading = true;
  bool _isValid = false;
  String _errorMessage = '';
  MeetingModel? _meeting;

  @override
  void initState() {
    super.initState();
    _validateMeeting();
  }

  Future<void> _validateMeeting() async {
    try {
      // Lấy thông tin meeting
      final meeting = await MeetingService.instance.getMeetingById(
        widget.roomId,
      );
      _meeting = meeting;

      // Validate 1: Kiểm tra meeting có enable không
      if (meeting?.enable != true) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = 'Cuộc họp này đã bị vô hiệu hóa';
        });
        debugPrint('[MEETING_ERROR] Meeting disabled: ${widget.roomId}');
        return;
      }

      // Validate 2: Kiểm tra userId có trong members không
      if (meeting == null || !meeting.members.contains(widget.userId)) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = 'Bạn không có quyền tham gia cuộc họp này';
        });
        debugPrint(
          '[MEETING_ERROR] User not in members: userId=${widget.userId}, members=${meeting?.members}',
        );
        return;
      }

      // Validate 3: Kiểm tra thời gian họp
      final now = DateTime.now();
      final meetingTime = meeting.time;

      // Cho phép vào sớm 15 phút trước giờ họp
      final allowedStartTime = meetingTime.subtract(Duration(minutes: 15));

      if (now.isBefore(allowedStartTime)) {
        final duration = allowedStartTime.difference(now);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;

        String timeMessage;
        if (hours > 0) {
          timeMessage = '$hours giờ $minutes phút';
        } else {
          timeMessage = '$minutes phút';
        }

        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage =
              'Cuộc họp chưa đến giờ.\nCòn $timeMessage nữa mới có thể tham gia';
        });
        debugPrint(
          '[MEETING_ERROR] Too early: now=$now, meetingTime=$meetingTime',
        );
        return;
      }

      // Validate 4: Kiểm tra cuộc họp đã kết thúc chưa (optional)
      // Giả sử cuộc họp kéo dài 2 giờ, có thể điều chỉnh
      final meetingEndTime = meetingTime.add(Duration(hours: 2));
      if (now.isAfter(meetingEndTime)) {
        setState(() {
          _isLoading = false;
          _isValid = false;
          _errorMessage = 'Cuộc họp đã kết thúc';
        });
        debugPrint(
          '[MEETING_ERROR] Meeting ended: now=$now, endTime=$meetingEndTime',
        );
        return;
      }

      // Tất cả validation đều pass
      setState(() {
        _isLoading = false;
        _isValid = true;
      });
      debugPrint(
        '[MEETING_SUCCESS] User can join: userId=${widget.userId}, roomId=${widget.roomId}',
      );

      // Chuyển sang màn hình video call sau 500ms
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        _navigateToVideoCall();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isValid = false;
        _errorMessage = 'Không thể tải thông tin cuộc họp.\n${e.toString()}';
      });
      debugPrint('[MEETING_ERROR] Exception: $e');
    }
  }

  void _navigateToVideoCall() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          roomId: widget.roomId,
          userId: widget.userId,
          meetingInfo: _meeting,
          getUserName: (id) async {
            if (id == widget.userId) return 'You';
            if (id.startsWith('screen_')) {
              final ownerId = id.replaceFirst('screen_', '');
              return 'Screen: ${ConfigsCubit.fromContext(context).usersMap[ownerId]?.name ?? 'User $ownerId'}';
            }
            String name =
                ConfigsCubit.fromContext(context).usersMap[id]?.name ??
                'User $id';
            return name;
            // Hàm lấy avatar theo ID (có thể tùy chỉnh)
          },
          getUserAvatar: (id) async {
            String avatar =
                ConfigsCubit.fromContext(context).usersMap[id]?.avt ??
                'https://ui-avatars.com/api/?name=${ConfigsCubit.fromContext(context).usersMap[id]?.name ?? 'User $id'}&background=random';
            return avatar;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading ? _buildLoadingView() : _buildResultView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo hoặc icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.video_call, size: 40, color: Colors.white),
          ),
          SizedBox(height: 32),

          // Loading indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),

          // Text
          Text(
            'Đang kiểm tra thông tin cuộc họp...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Room ID: ${widget.roomId}',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_isValid) {
      return _buildSuccessView();
    } else {
      return _buildErrorView();
    }
  }

  Widget _buildSuccessView() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 50, color: Colors.green),
          ),
          SizedBox(height: 24),

          // Success text
          Text(
            'Đang tham gia cuộc họp...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (_meeting != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _meeting!.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_meeting!.description.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      _meeting!.description,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 50, color: Colors.red),
          ),
          SizedBox(height: 24),

          // Error title
          Text(
            'Không thể tham gia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // Error message
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút quay lại
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back),
                label: Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Nút thử lại
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isValid = false;
                    _errorMessage = '';
                  });
                  _validateMeeting();
                },
                icon: Icon(Icons.refresh),
                label: Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          // Meeting info (if available)
          if (_meeting != null) ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cuộc họp:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow('Tiêu đề', _meeting!.title),
                  _buildInfoRow('Thời gian', _formatDateTime(_meeting!.time)),
                  _buildInfoRow(
                    'Số thành viên',
                    '${_meeting!.members.length} người',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

// Ví dụ sử dụng:
/*
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => MeetingJoinPage(
      roomId: 'room123',
      userId: 'user456',
      getMeetingInfo: (roomId) async {
        // Implement hàm lấy meeting từ Firestore
        final doc = await FirebaseFirestore.instance
            .collection('meetings')
            .doc(roomId)
            .get();
        return MeetingModel.fromSnapshot(doc);
      },
    ),
  ),
);
*/
