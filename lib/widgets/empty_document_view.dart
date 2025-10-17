import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class EmptyDocumentView extends StatelessWidget {
  final String image;
  final String title;
  final String txt;
  const EmptyDocumentView(
      {this.image = 'assets/images/img_no_document.png',
      required this.title,
      required this.txt,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Image.asset(image, ),
      SizedBox(
        width: ScaleUtils.scaleSize(230, context),
        child: Column(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ScaleUtils.scaleSize(14, context),
                    color: ColorConfig.textTertiary,
                    letterSpacing: ScaleUtils.scaleSize(-0.33, context))),
            Text(txt,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: ScaleUtils.scaleSize(12, context),
                    color: ColorConfig.textTertiary,
                    letterSpacing: ScaleUtils.scaleSize(-0.33, context)))
          ],
        ),
      )
    ]);
  }
}
