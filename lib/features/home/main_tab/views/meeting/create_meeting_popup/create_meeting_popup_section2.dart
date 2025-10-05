import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/create_meeting_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class CreateMeetingPopupSection2 extends StatelessWidget {
  const CreateMeetingPopupSection2({
    super.key,
    required this.cubit
  });

  final CreateMeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.titleTitle.text,
            style: TextStyle(
                fontSize:
                ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(h: 5),
        TextFieldCustom(
            controller: cubit.conTitle,
            hint: "Nhập tiêu đề",
            isEdit: true),
        const ZSpace(h: 9),
        Text(AppText.titleDescription.text,
            style: TextStyle(
                fontSize:
                ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(h: 5),
        FormatTextField(onContentChanged: (v) {
          cubit.conDes.text = v;
        }, fixedLines: 8,)
        // TextFieldCustom(
        //   controller: cubit.conDes,
        //   hint: "Nhập mô tả",
        //   isEdit: true,
        //   minLines: 5,
        //   radius: 12,
        // ),
      ],
    );
  }
}