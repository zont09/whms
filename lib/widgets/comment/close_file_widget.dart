import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class CloseFileWidget extends StatelessWidget {
  const CloseFileWidget({
    super.key,
    required this.onClose,
  });

  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClose();
      },
      splashColor: Colors.grey.withOpacity(0.9),
      hoverColor: Colors.grey.withOpacity(0.6),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.grey.withOpacity(0.4)),
        padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
        child: Icon(
          Icons.close,
          size: ScaleUtils.scaleSize(12, context),
          color: Colors.black.withOpacity(0.75),
        ),
      ),
    );
  }
}