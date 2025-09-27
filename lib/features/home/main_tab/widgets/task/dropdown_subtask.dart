import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class DropdownSubtask extends StatelessWidget {
  const DropdownSubtask({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
        border: Border.all(
            width: ScaleUtils.scaleSize(2, context), color: ColorConfig.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(ScaleUtils.scaleSize(4, context)),
            child: Text(
              AppText.textEdit.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(10, context),
                  color: ColorConfig.textTertiary),
            ),
          ),
          // Divider(thickness: ScaleUtils.scaleSize(2, context), color: ColorConfig.primary2,),
          IntrinsicWidth(
            child: Container(
              height: ScaleUtils.scaleSize(2, context),
              // width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.blue,

                border: Border(
                  bottom: BorderSide(
                    color: ColorConfig.border,
                    width: ScaleUtils.scaleSize(2, context)
                  )
                )
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(4, context), horizontal: ScaleUtils.scaleSize(8, context)),
            child: Text(
              AppText.textDelete.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(10, context),
                  color: ColorConfig.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
