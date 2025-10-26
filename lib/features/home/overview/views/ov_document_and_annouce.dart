import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/no_data_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';


class OVDocumentAndAnnouce extends StatelessWidget {
  const OVDocumentAndAnnouce({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppText.titleDocumentAndAnnounce.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                  color: ColorConfig.textColor,
                  shadows: const [ColorConfig.textShadow]),
            ),
            const ZSpace(w: 4),
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

        const ZSpace(h: 9),
        NoDataWidget(
            imgSize: 60,
            fontSizeTitle: 16,
            fontSizeContent: 12,
            data: AppText.titleDocumentAndAnnounce.text),
      ],
    );
  }
}