import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  const LoadingWidget({super.key, this.color = ColorConfig.primary2});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, cons) => SizedBox(
              width: cons.maxWidth,
              height: cons.maxHeight,
              child: Center(
                child: CircularProgressIndicator(color: color),
              ),
            ));
  }
}
