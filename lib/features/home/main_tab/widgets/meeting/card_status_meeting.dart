import 'package:whms/defines/status_meeting_define.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CardStatusMeeting extends StatelessWidget {
  const CardStatusMeeting(
      {super.key, required this.status, required this.isSelected});

  final String status;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(229),
          color: StatusMeetingExtension.convertToStatus(status).background),
      padding: EdgeInsets.symmetric(
          vertical: ScaleUtils.scaleSize(4, context),
          horizontal: ScaleUtils.scaleSize(8, context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(12, context),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis),
              textAlign: TextAlign.center,
            ),
          ),
          if (isSelected) const ZSpace(w: 5),
          if (isSelected)
            Image.asset(
              'assets/images/icons/ic_dropdown.png',
              height: ScaleUtils.scaleSize(4, context),
              color: Colors.white,
            )
        ],
      ),
    );
  }
}
