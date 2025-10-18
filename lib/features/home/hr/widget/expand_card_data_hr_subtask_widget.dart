import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import '../../checkin/widgets/history_card_widget.dart';

class ExpandCardDataHrSubtaskWidget extends StatelessWidget {
  const ExpandCardDataHrSubtaskWidget(
      {super.key, required this.weight, required this.listData});

  final List<int> weight;
  final List<WorkHistorySynthetic> listData;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(
                // horizontal: ScaleUtils.scaleSize(16, context),
                vertical: ScaleUtils.scaleSize(12, context))
            .copyWith(top: ScaleUtils.scaleSize(20, context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...listData.map(
              (data) => Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          flex: weight[0] + weight[1],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  data.work.title,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(14, context),
                                      fontWeight: FontWeight.w500,
                                      color: ColorConfig.textColor,
                                      letterSpacing: -0.02,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              )
                            ],
                          )),
                      // Expanded(
                      //     flex: ,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         CardView(
                      //             content: DateTimeUtils.formatDuration(
                      //                 data.workingPoint)),
                      //       ],
                      //     )),
                      Expanded(
                          flex: weight[2],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CardView(
                                  content: DateTimeUtils.formatDuration(
                                      data.workingTime)),
                            ],
                          )),
                      Expanded(
                          flex: weight[3],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatusCard(status: data.fromStatus),
                            ],
                          )),
                      Expanded(
                          flex: weight[4],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatusCard(status: data.toStatus),
                            ],
                          )),
                      Expanded(flex: weight[5], child: Container()),
                      const ZSpace(h: 9)
                    ],
                  ),
                  const ZSpace(
                    h: 5,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
