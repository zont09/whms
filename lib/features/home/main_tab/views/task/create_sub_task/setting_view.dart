import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/list_status_dropdown.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/working_time_dropdown.dart';

class SettingView extends StatelessWidget {
  const SettingView(
      {super.key,
      required this.initTime,
      required this.onChanged,
      required this.onChangedStatus,
      required this.isEdit,
      required this.isTaskToday,
        this.canEditDefault = false,
      this.work});

  final WorkingUnitModel? work;
  final bool isTaskToday;
  final int initTime;
  final Function(int) onChanged;
  final Function(int) onChangedStatus;
  final bool isEdit;
  final bool canEditDefault;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(AppText.titleSettingTask.text,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(16, context),
              fontWeight: FontWeight.w500,
              color: ColorConfig.textColor6,
              letterSpacing: -0.41,
              shadows: const [ColorConfig.textShadow])),
      SizedBox(width: ScaleUtils.scaleSize(9, context)),
      if (work != null)
        AbsorbPointer(
            absorbing: !isTaskToday || (!canEditDefault && (work != null && work!.owner.isEmpty)),
            child: ListStatusDropdown(
              isPermission: true,
                selector: work!.status,
                typeOption: work!.owner.isEmpty ? 2 : 1,
                onChanged: (value) {
                  onChangedStatus(value!);
                })),
      SizedBox(width: ScaleUtils.scaleSize(9, context)),
      AbsorbPointer(
        absorbing: !isEdit,
        child: WorkingTimeDropdown(
          fontSize: 12,
          maxHeight: 30,
          radius: 20,
          maxWidth: 120,
          onChanged: (value) {
            onChanged(value!);
          },
          initTime: initTime,
          isAddTask: false,
          isRemove: false,
          isEdit: isEdit,
        ),
      )
    ]);
  }
}
