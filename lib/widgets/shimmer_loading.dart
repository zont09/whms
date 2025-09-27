import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/toast_utils.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final bool isShadow;

  const ShimmerLoading(
      {super.key,
      this.width,
      this.height,
      this.radius = 0,
      this.isShadow = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ToastUtils.showBottomToast(
            context, "Dữ liệu đang tải, bình tĩnh nào! Bộ bạn gấp lắm hả 😒",
            duration: 4);
      },
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [if (isShadow) ColorConfig.boxShadow2]),
        ),
      ),
    );
  }
}
