import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class TitleRecordTextField extends StatelessWidget {
  const TitleRecordTextField({
    super.key,
    required this.record,
    required this.controller,
    required this.onUpdate,
    required this.isTitle,
  });

  final MeetingRecordModel record;
  final TextEditingController controller;
  final Function(MeetingRecordModel p1) onUpdate;
  final bool isTitle;

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
              hint: isTitle
                  ? AppText.textHintTypingTitle.text
                  : AppText.textHintTypingContent.text,
              isEdit: true,
              fontWeight: FontWeight.w500,
              radius: 2,
              minLines: null,
              paddingContentHor: 0,
              borderColor: Colors.transparent,
              onEnter: (v) {
                if (isTitle) {
                  onUpdate(record.copyWith(title: v));
                } else {
                  onUpdate(record.copyWith(content: v));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
