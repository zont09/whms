import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/no_data_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class OvFileAttachmentsView extends StatelessWidget {
  const OvFileAttachmentsView({
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
              AppText.titleFileAttachments.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                  color: ColorConfig.textColor,
                  shadows: const [ColorConfig.textShadow]),
            ),
            const ZSpace(w: 4),
            Image.asset(
              'assets/images/icons/ic_add_task_2.png',
              height: ScaleUtils.scaleSize(16, context),
            )
          ],
        ),
        const ZSpace(h: 9),
        NoDataWidget(
            imgSize: 60,
            fontSizeTitle: 16,
            fontSizeContent: 12,
            data: AppText.titleFileAttachments.text),
      ],
    );
  }
}
