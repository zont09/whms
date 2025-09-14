import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class TwoButtons extends StatelessWidget {
  final String titleOK;
  final String titleCancel;
  final Function() onOK;
  final Function() onCancel;
  const TwoButtons(
      {required this.titleCancel,
      required this.titleOK,
      required this.onCancel,
      required this.onOK,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, elevation: 0),
            child: Text(
              titleCancel,
              style: TextStyle(
                  color: ColorConfig.primary2,
                  fontWeight: FontWeight.w600,
                  fontSize: ScaleUtils.scaleSize(16, context)),
            )),
        SizedBox(width: ScaleUtils.scalePadding(10, context)),
        ElevatedButton(
            onPressed: onOK,
            style:
                ElevatedButton.styleFrom(backgroundColor: ColorConfig.primary2),
            child: Text(
              titleOK,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: ScaleUtils.scaleSize(16, context)),
            )),
      ],
    );
  }
}
