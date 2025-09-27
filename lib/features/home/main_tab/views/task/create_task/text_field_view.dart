import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class TextFieldView extends StatelessWidget {
  const TextFieldView({
    super.key,
    required this.cubit,
  });

  final CreateTaskCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.titleNameTask.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                shadows: const [ColorConfig.textShadow])),
        SizedBox(height: ScaleUtils.scaleSize(5, context)),
        TextFieldCustom(
            controller: cubit.conName,
            isEdit: true,
            hint: AppText.textCreateNameForTask.text),
        SizedBox(height: ScaleUtils.scaleSize(12, context)),
        Text(AppText.titleDescription.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                shadows: const [ColorConfig.textShadow])),
        SizedBox(height: ScaleUtils.scaleSize(5, context)),
        TextFieldCustom(
            isEdit: true,
            controller: cubit.conDes,
            hint: AppText.textTaskDescription.text,
            radius: 11,
            minLines: 5),
      ],
    );
  }
}