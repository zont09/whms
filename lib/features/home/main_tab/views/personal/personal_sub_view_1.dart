import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_personal_task_widget.dart';
import 'package:whms/features/home/main_tab/widgets/personal/personal_task_widget.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

import '../task/no_task_view.dart';

class PersonalSubView1 extends StatelessWidget {
  const PersonalSubView1(
      {super.key,
      required this.title,
      required this.iconTitle,
      required this.items,
      required this.onTapMoreView,
      required this.tab,
      required this.cubitMT});

  final String iconTitle;
  final String title;
  final List<WorkingUnitModel> items;
  final Function() onTapMoreView;
  final String tab;
  final MainTabCubit cubitMT;

  @override
  Widget build(BuildContext context) {
    var cubitMT = BlocProvider.of<MainTabCubit>(context);
    return Column(
      children: [
        Row(
          children: [
            Image.asset(iconTitle,
                height: ScaleUtils.scaleSize(20, context),
                color: ColorConfig.primary2),
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
            Text(title,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(18, context),
                    fontWeight: FontWeight.w500))
          ],
        ),
        SizedBox(height: ScaleUtils.scaleSize(8, context)),
        if (items.isNotEmpty) const HeaderPersonalTaskWidget(),
        if (items.isNotEmpty)
          SizedBox(height: ScaleUtils.scaleSize(5, context)),
        if (items.isEmpty)
          SizedBox(
            width: double.infinity,
            height: ScaleUtils.scaleSize(320, context),
            child: NoTaskView(
              tab: tab,
              sizeContent: 16,
              sizeTitle: 18,
              sizeImg: 200,
              isShowButtonPersonal: false,
            ),
          ),
        if (items.isNotEmpty)
          ...items.take(5).map((item) => Column(
                children: [
                  PersonalTaskWidget(
                      isToday: cubitMT.listToday.any((e) => e.id == item.id),
                      work: item,
                      address: cubitMT.mapAddress[item.id],
                      subTask: cubitMT.mapNumberSubTask[item.id] ?? 0),
                  SizedBox(height: ScaleUtils.scaleSize(9, context))
                ],
              )),
        if (items.length > 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  onTapMoreView();
                },
                child: Text(
                  AppText.textViewMore.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(14, context),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      color: ColorConfig.textColor),
                ),
              )
            ],
          )
      ],
    );
  }
}
