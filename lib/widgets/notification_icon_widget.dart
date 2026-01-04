import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/services/notification_service.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/notification_panel_widget.dart';

class NotificationIconWidget extends StatelessWidget {
  const NotificationIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final configsCubit = context.read<ConfigsCubit>();
    final userId = configsCubit.user.id;

    return StreamBuilder<int>(
      stream: NotificationService.instance.unreadCountStream(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return InkWell(
          onTap: () {
            _showNotificationPanel(context, userId);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: ScaleUtils.scaleSize(24, context),
                  color: Colors.white,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPanel(BuildContext context, String userId) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: ScaleUtils.scaleSize(65, context),
            right: ScaleUtils.scaleSize(20, context),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: NotificationPanelWidget(userId: userId),
            ),
          ),
        ],
      ),
    );
  }
}
