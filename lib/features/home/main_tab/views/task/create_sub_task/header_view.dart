import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({
    super.key,
    required this.address,
    required this.isEdit,
    required this.isDetail,
  });

  final List<WorkingUnitModel> address;
  final bool isEdit;
  final bool isDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            !isDetail
                ? AppText.titleCreateSubtask.text.toUpperCase()
                : (isEdit
                    ? AppText.titleEditSubTask.text.toUpperCase()
                    : AppText.titleDetailSubTask.text.toUpperCase()),
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(24, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                shadows: const [ColorConfig.textShadow])),
        SizedBox(height: ScaleUtils.scaleSize(5, context)),
        Text(
            !isDetail
                ? AppText.textCreateSubTaskDescription.text
                : (isEdit
                    ? AppText.textEditSubTask.text
                    : AppText.textDetailSubTask.text),
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: const Color(0xFFA6A6A6),
                letterSpacing: -0.41)),
        SizedBox(height: ScaleUtils.scaleSize(18, context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(AppText.titleLink.text,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(16, context),
                    fontWeight: FontWeight.w500,
                    color: ColorConfig.textColor6,
                    letterSpacing: -0.41,
                    shadows: const [ColorConfig.textShadow])),
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFFFD0D2),
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(12, context))),
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(8, context),
                  vertical: ScaleUtils.scaleSize(4, context)),
              child: Row(
                children: [
                  for (int i = address.length - 1; i >= 0; i--)
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Tooltip(
                              message: address[i].title,
                              child: Text(address[i].type,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(13, context),
                                      fontWeight: FontWeight.w500,
                                      color: ColorConfig.primary3))),
                          if (i > 0)
                            Text(" > ",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(13, context),
                                    fontWeight: FontWeight.w500,
                                    color: ColorConfig.primary3))
                        ])
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
