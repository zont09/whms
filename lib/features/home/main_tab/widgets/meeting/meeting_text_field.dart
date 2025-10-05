import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../widgets/textfield_custom_2.dart';

class MeetingTextField extends StatelessWidget {
  const MeetingTextField({
    super.key,
    required this.meeting,
    required this.controller,
    required this.onUpdate,
    required this.hint,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 14
  });

  final MeetingModel meeting;
  final TextEditingController controller;
  final Function(String) onUpdate;
  final FontWeight fontWeight;
  final double fontSize;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(2.5, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: TextFieldCustom(
              controller: controller,
              hint: hint,
              isEdit: true,
              fontWeight: fontWeight,
              fontSize: fontSize,
              radius: 2,
              minLines: null,
              paddingContentHor: 0,
              borderColor: Colors.transparent,
              onEnter: (v) {
                onUpdate(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
