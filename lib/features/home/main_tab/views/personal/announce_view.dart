import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/views/no_task_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class AnnounceView extends StatelessWidget {
  const AnnounceView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              AppText.titleDocumentAndAnnounce.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(18, context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.33,
                  color: ColorConfig.textColor,
                  shadows: const [ColorConfig.textShadow]),
            ),
            SizedBox(width: ScaleUtils.scaleSize(9, context)),
            Container(
              height: ScaleUtils.scaleSize(23, context),
              width: ScaleUtils.scaleSize(23, context),
              decoration: BoxDecoration(
                  color: ColorConfig.primary3,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                        color: ColorConfig.primary3.withOpacity(0.3))
                  ]),
              child: Center(
                child: Text(
                  "0",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(10, context),
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: ScaleUtils.scaleSize(12, context)),
        const NoTaskView(tab: "-2005", sizeTitle: 18, sizeImg: 140, spacing: 15, isShowFullScreen: false, paddingHor: 30,)
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // AnnounceWidget(),
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // AnnounceWidget(),
        // SizedBox(height: ScaleUtils.scaleSize(9, context)),
        // AnnounceWidget(),
      ],
    );
  }
}