import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final Widget child;
  final Duration period;
  final Color baseColor;
  final Color highlightColor;

  const LoadingShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.baseColor = Colors.grey,
    this.highlightColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: period,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
