import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/loading_widget.dart';

class AvatarItem extends StatelessWidget {
  final String avatar;
  final double size;
  final bool isShadow;

  const AvatarItem(
    this.avatar, {
    this.size = 20,
    this.isShadow = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isShadow
            ? [
                BoxShadow(
                  color: const Color(0x59000000),
                  offset: Offset(
                    ScaleUtils.scaleSize(3, context),
                    ScaleUtils.scaleSize(2, context),
                  ),
                  blurRadius: ScaleUtils.scaleSize(4, context),
                  spreadRadius: 0,
                ),
              ]
            : null,
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: ScaleUtils.scaleSize(1, context),
        ),
      ),
      child: CircleAvatar(
        radius: ScaleUtils.scaleSize(size / 2, context),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10000),
          child: Image.network(
            avatar,
            width: ScaleUtils.scaleSize(size, context),
            height: ScaleUtils.scaleSize(size, context),
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const LoadingWidget();
                  }
                },
            errorBuilder: (context, error, stackTrace) {
              debugPrint("[THINK] ====> error: $error");
              debugPrint("[THINK] ====> stack: $stackTrace");
              return Image.asset(
                'assets/images/default_avatar.png',
                color: Colors.grey.shade400,
                width: ScaleUtils.scaleSize(size, context),
                height: ScaleUtils.scaleSize(size, context),
              );
            },
          ),
        ),
      ),
    );
  }
}
