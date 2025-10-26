import 'package:whms/features/home/overview/views/header_hr_data.dart';
import 'package:whms/features/home/overview/views/overview_data_task_view.dart';
import 'package:whms/features/home/overview/widgets/card_hr_data_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class OverviewDataView extends StatelessWidget {
  const OverviewDataView({super.key, required this.cubit});

  final OverviewTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [2, 1, 1, 1, 1];
    return Padding(
      padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            DropdownString(
                onChanged: (v) {
                  cubit.changeTime(v!);
                },
                initItem: AppText.text5Days.text,
                options: [
                  AppText.text5Days.text,
                  AppText.text10Days.text,
                  AppText.textLastWeek.text,
                  AppText.textThisWeek.text,
                  AppText.textLastMonth.text,
                  AppText.textThisMonth.text,
                ],
                radius: 8,
                maxWidth: 120)
          ]),
          const ZSpace(h: 9),
          Text(
            AppText.titleListHr.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor6,
                shadows: const [ColorConfig.textShadow]),
          ),
          const ZSpace(h: 12),
          HeaderHrData(weight: weight),
          const ZSpace(h: 9),
          ...cubit.listDataUser.map((item) => Column(
                children: [
                  CardHrDataWidget(data: item, weight: weight),
                  const ZSpace(h: 9),
                ],
              )),
          if (cubit.loadingDataUser > 0) const ZSpace(h: 9),
          if (cubit.loadingDataUser > 0)
            const Center(
              child: CircularProgressIndicator(color: ColorConfig.primary3,),
            ),
          const ZSpace(h: 20),
          OverviewDataTaskView(cubit: cubit)
        ],
      ),
    );
  }
}
