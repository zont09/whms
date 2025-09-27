
import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

import '../../../../../configs/color_config.dart' show ColorConfig;
import '../task/no_task_view.dart';

class MeetingView extends StatelessWidget {
  const MeetingView({super.key, required this.cubit});

  final MainTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              AppText.titleMeeting.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(18, context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.33,
                  color: ColorConfig.textColor,
                  shadows: const [ColorConfig.textShadow]),
            ),
          ],
        ),
        SizedBox(height: ScaleUtils.scaleSize(12, context)),
        // if (cubit.loadingMeeting == 0 && cubit.listMeeting.isEmpty)
          const NoTaskView(
              tab: "-2006",
              sizeTitle: 18,
              sizeImg: 140,
              spacing: 15,
              isShowFullScreen: false,
              paddingHor: 30),
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // if (cubit.loadingMeeting > 0) const ZSpace(h: 9),
        // if (cubit.loadingMeeting > 0)
        //   const Center(
        //       child: CircularProgressIndicator(color: ColorConfig.primary3)),
        // if (cubit.loadingMeeting == 0 && cubit.listMeeting.isNotEmpty)
        //   ...cubit.listMeeting.take(3).map((e) {
        //     cubit.getDataFileMeeting(e);
        //     return Column(
        //       children: [
        //         InkWell(
        //           onTap: () {
        //             context.go('${AppRoutes.mainTab}/4&id=${e.id}');
        //             // context.go('${AppRoutes.mainTab}/4');
        //           },
        //           child: MeetingWidget(
        //             meeting: e,
        //             attachments: cubit.mapFileMeeting[e.id],
        //           ),
        //         ),
        //         const ZSpace(h: 10),
        //       ],
        //     );
        //   }),
        // if (cubit.listMeeting.length > 3)
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       InkWell(
        //         onTap: () {
        //           context.go('${AppRoutes.mainTab}/4');
        //         },
        //         child: Text(
        //           AppText.textViewMore.text,
        //           style: TextStyle(
        //               fontSize: ScaleUtils.scaleSize(14, context),
        //               fontWeight: FontWeight.w600,
        //               letterSpacing: -0.02,
        //               color: ColorConfig.textColor,
        //               overflow: TextOverflow.ellipsis,
        //               decoration: TextDecoration.underline,
        //               decorationColor: ColorConfig.textColor,
        //               height: 1.3),
        //         ),
        //       ),
        //     ],
        //   )
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // MeetingWidget(),
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // MeetingWidget(),
      ],
    );
  }
}
