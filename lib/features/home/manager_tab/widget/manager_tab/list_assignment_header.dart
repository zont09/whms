import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class ListAssignmentHeader extends StatelessWidget {
  final int typeAssignment;
  const ListAssignmentHeader(this.typeAssignment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(10, context)),
      child: typeAssignment <= 1
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(20, context)),
                      child: Text(AppText.titleName.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: ColorConfig.textTertiary,
                              fontWeight: FontWeight.w400,
                              fontSize: ScaleUtils.scaleSize(12, context),
                              letterSpacing:
                                  ScaleUtils.scaleSize(-0.33, context))))),
              SizedBox(width: ScaleUtils.scaleSize(20, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(AppText.titleDeadline.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(typeAssignment == 0 ? 30 : 50, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(typeAssignment == 0 ? 'Groups & Tasks' : 'Tasks',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(typeAssignment == 0 ? 10 : 30, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(AppText.titleStatus.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.centerRight,
                  child: Text(AppText.titleAssigner.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(40, context)),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(20, context)),
                      child: Text(AppText.titleName.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: ColorConfig.textTertiary,
                              fontWeight: FontWeight.w400,
                              fontSize: ScaleUtils.scaleSize(12, context),
                              letterSpacing:
                                  ScaleUtils.scaleSize(-0.33, context))))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(AppText.titleDeadline.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(30, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(AppText.titlePriorityLevel.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.center,
                  child: Text(AppText.titleStatus.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.centerRight,
                  child: Text(AppText.txtWorkingPoint.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.centerRight,
                  child: Text(AppText.titleCreator.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              Container(
                  alignment: Alignment.centerRight,
                  child: Text(AppText.titleAssignee.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ColorConfig.textTertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: ScaleUtils.scaleSize(12, context),
                          letterSpacing:
                              ScaleUtils.scaleSize(-0.33, context)))),
              SizedBox(width: ScaleUtils.scaleSize(20, context)),
            ]),
    );
  }
}
