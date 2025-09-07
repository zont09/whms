import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class ZSpace extends StatelessWidget {
  const ZSpace({super.key, this.w = 0, this.h = 0});

  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScaleUtils.scaleSize(w, context),
      height: ScaleUtils.scaleSize(h, context),
    );
  }
}
