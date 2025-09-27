import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

import '../../configs/color_config.dart' show ColorConfig;

class FileViewWidget extends StatelessWidget {
  const FileViewWidget(
      {super.key, required this.title, required this.onRemove, this.isCanRemove = true, this.width = 150});

  final String title;
  final Function() onRemove;
  final bool isCanRemove;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(width, context),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: const Color(0xFFEBEBEB)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2]),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(8, context),
          vertical: ScaleUtils.scaleSize(6, context)),
      child: Row(
        children: [
          Image.asset('assets/images/icons/ic_file_upload.png',
              height: ScaleUtils.scaleSize(24, context)),
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          Expanded(
              child: Text(
            title,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.41,
                overflow: TextOverflow.ellipsis,
                color: ColorConfig.primary3),
            maxLines: 1,
          )),
          if(isCanRemove)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(isCanRemove)
          InkWell(
            onTap: () {
              onRemove();
            },
            child: Image.asset(
              'assets/images/icons/ic_close_check_in.png',
              height: ScaleUtils.scaleSize(8, context),
              color: const Color(0xFFAFAFAF),
            ),
          ),
        ],
      ),
    );
  }
}
