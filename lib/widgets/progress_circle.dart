import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class ProgressCircle extends StatelessWidget {
  final int done;
  final int cnt;
  final double size;
  final Color background;
  final double strokeWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;

  const ProgressCircle(
      {super.key,
      required this.done,
      required this.cnt,
      required this.size,
      this.background = Colors.white,
      this.strokeWidth = 6,
      this.fontSize = 16,
      this.fontWeight = FontWeight.w500,
      this.textColor = ColorConfig.textColor});

  @override
  Widget build(BuildContext context) {
    double percent = cnt == 0 ? 0 : done / cnt;
    Color color = percent >= 0.75
        ? Colors.green
        : percent >= 0.5
            ? Colors.orange
            : Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: ScaleUtils.scaleSize(size, context),
          height: ScaleUtils.scaleSize(size, context),
          child: CircularProgressIndicator(
            value: percent,
            backgroundColor: background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: ScaleUtils.scaleSize(strokeWidth, context),
          ),
        ),
        Text(
          '$cnt',
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight, color: textColor),
        ),
      ],
    );
  }
}
