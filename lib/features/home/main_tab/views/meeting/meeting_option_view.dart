import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class MeetingOptionView extends StatelessWidget {
  const MeetingOptionView({
    super.key,
    required this.cubit,
  });

  final MeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image.asset('assets/images/icons/ic_filter_issues.png',
        //     height: ScaleUtils.scaleSize(20, context)),
        // const ZSpace(w: 8),
        DropdownString(
          onChanged: (v) {
            cubit.changeFilter(v!);
          },
          initItem: cubit.filterTime,
          options: [
            AppText.textAll.text,
            AppText.titleToday.text,
            AppText.textThisWeek.text,
            AppText.textTomorrow.text,
            AppText.textNext3Days.text,
            AppText.textNeedPrepare.text
          ],
          radius: 6,
          fontSize: 12,
          textColor: ColorConfig.primary3,
          maxHeight: 24,
        ),
        const ZSpace(w: 8),
        DropdownString(
          onChanged: (v) {
            cubit.changeFilterStatus(v!);
          },
          initItem: cubit.filterStatus,
          options: [
            AppText.textAll.text,
            AppText.textDone.text,
            AppText.textByUnFinished.text,
          ],
          radius: 6,
          fontSize: 12,
          textColor: ColorConfig.primary3,
          maxHeight: 24,
        ),
        const Spacer(),
        SizedBox(
          width: ScaleUtils.scaleSize(250, context),
          height: ScaleUtils.scaleSize(28, context),
          child: SearchField(
              controller: cubit.conSearch,
              onChanged: (v) {
                cubit.updateListShow();
                cubit.EMIT();
              },
              fontSize: 12,
              padHor: 8,
              padVer: 2,
              radius: 8),
        )
      ],
    );
  }
}
