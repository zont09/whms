import 'package:whms/features/home/main_tab/blocs/meeting/card_meeting_section_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.isEdit,
    required this.section,
    required this.cubit,
    required this.onUpdate,
  });

  final bool isEdit;
  final MeetingSectionModel section;
  final CardMeetingSectionCubit cubit;
  final Function(MeetingSectionModel p1) onUpdate;

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
              section.title,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(14, context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.02,
                  color: ColorConfig.textColor),
            ),
          if (isEdit)
            Expanded(
              child: TextFieldCustom(
                controller: cubit.conTitle,
                hint: AppText.textTypingSectionTitle.text,
                isEdit: isEdit,
                fontWeight: FontWeight.w500,
                radius: 2,
                minLines: null,
                borderColor: Colors.transparent,
                onEnter: (v) {
                  onUpdate(section.copyWith(title: v));
                },
              ),
            ),
        ],
      ),
    );
  }
}