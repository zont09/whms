import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HeaderMeetingOverview extends StatelessWidget {
  const HeaderMeetingOverview(
      {super.key, required this.weight, required this.cubit});

  final List<int> weight;
  final MeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(16, context)),
      margin: EdgeInsets.only(left: ScaleUtils.scaleSize(20, context)),
      child: Row(
        children: [
          Expanded(
              flex: weight[0],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: InkWell(
                  onTap: () {
                    cubit.changeSortTitle();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppText.titleTitle.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary)),
                      const ZSpace(w: 3),
                      Padding(
                        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(2, context)),
                        child: Icon(
                            cubit.sortTitle == 1
                                ? Icons.keyboard_double_arrow_up_sharp
                                : (cubit.sortTitle == -1
                                    ? Icons.keyboard_double_arrow_down_sharp
                                    : Icons.keyboard_double_arrow_right_sharp),
                            size: ScaleUtils.scaleSize(12, context),
                            color: ColorConfig.textTertiary),
                      )
                    ],
                  ),
                ),
              )),
          Expanded(
              flex: weight[5],
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: InkWell(
                  onTap: () {
                    cubit.changeSortDeadline();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppText.textTimeStartMeeting.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textTertiary)),
                      const ZSpace(w: 3),
                      Padding(
                        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(2, context)),
                        child: Icon(
                            cubit.sortTime == 1
                                ? Icons.keyboard_double_arrow_up_sharp
                                : (cubit.sortTime == -1
                                ? Icons.keyboard_double_arrow_down_sharp
                                : Icons.keyboard_double_arrow_right_sharp),
                            size: ScaleUtils.scaleSize(12, context),
                            color: ColorConfig.textTertiary),
                      )
                    ],
                  ),
                ),
              )),
          const ZSpace(w: 9),
          Expanded(
              flex: weight[1],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(AppText.titleDescription.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400,
                            color: ColorConfig.textTertiary))
                  ],
                ),
              )),
          Expanded(
              flex: weight[2],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppText.textMember.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400,
                            color: ColorConfig.textTertiary))
                  ],
                ),
              )),
          Expanded(
              flex: weight[3],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppText.textStatusMeeting.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400,
                            color: ColorConfig.textTertiary))
                  ],
                ),
              )),
          Expanded(
              flex: weight[4],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppText.textOwnerMeetingShort.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400,
                            color: ColorConfig.textTertiary))
                  ],
                ),
              )),
          Expanded(flex: weight[6], child: const SizedBox.shrink()),
        ],
      ),
    );
  }
}
