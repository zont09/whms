import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class ContentTextField extends StatelessWidget {
  const ContentTextField({
    super.key,
    required this.isEdit,
    required this.prepare,
    required this.controller,
    required this.onUpdate,
  });

  final bool isEdit;
  final MeetingPreparationModel prepare;
  final TextEditingController controller;
  final Function(MeetingPreparationModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(2.5, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!isEdit)
            Text(
              prepare.content,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(14, context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.02,
                  color: ColorConfig.textColor),
            ),
          if (isEdit)
            Expanded(
              child: TextFieldCustom(
                controller: controller,
                hint: AppText.textTypingSectionDescription.text,
                isEdit: isEdit,
                fontWeight: FontWeight.w500,
                radius: 2,
                minLines: null,
                borderColor: Colors.transparent,
                onEnter: (v) {
                  onUpdate(prepare.copyWith(content: v));
                },
              ),
            ),
        ],
      ),
    );
  }
}