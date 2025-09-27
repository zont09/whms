import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HeaderPersonalTaskWidget extends StatelessWidget {
  const HeaderPersonalTaskWidget({
    super.key,
    this.isInHrTab = false,
    this.isInTask = false,
    this.isClickToDeadline,
    this.isClickToAssignees,
  });

  final bool isInHrTab;
  final bool isInTask;
  final Function()? isClickToDeadline;
  final Function()? isClickToAssignees;

  @override
  Widget build(BuildContext context) {
    final List<int> tableWeight =
        !isInHrTab ? [8, 4, 3, 3, 1, 1, 1, 3] : [10, 2, 2, 2, 1, 2, 2, 1];
    return Container(
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(12, context)),
        child: Row(children: [
          if(isInTask)
            const ZSpace(w: 12),
          Expanded(
              flex: tableWeight[0],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Text(
                  AppText.titleTask.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          if(isInTask)
          Expanded(
              flex: tableWeight[7],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: Text(
                    AppText.titleScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )),
          Expanded(
              flex: tableWeight[1],
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Text(
                    AppText.titleStatus.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )),
          Expanded(
              flex: tableWeight[2],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: Text(
                    AppText.titlePriorityLevel.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )),
          Expanded(
              flex: tableWeight[3],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: AbsorbPointer(
                    absorbing: isClickToDeadline == null,
                    child: InkWell(
                      onTap: () {
                        isClickToDeadline!();
                      },
                      child: Text(
                        AppText.titleDeadline.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              )),
          Expanded(
              flex: tableWeight[4],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: Text(AppText.titleUrgent.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400)),
                ),
              )),
          if (isInHrTab)
            Expanded(
                flex: tableWeight[6],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Center(
                    child: Text(AppText.titleWorkingPoint.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w400)),
                  ),
                )),
          Expanded(
              flex: tableWeight[5],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: Text(
                    AppText.textSubTaskShort.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )),
          if(isClickToAssignees != null)
            Expanded(
                flex: tableWeight[7],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Center(
                    child: AbsorbPointer(
                      absorbing: isClickToAssignees == null,
                      child: InkWell(
                        onTap: () {
                          isClickToAssignees!();
                        },
                        child: Text(
                          AppText.titleAssignee.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                )),
          if(isInTask)
          Expanded(
              flex: tableWeight[6],
              child: const SizedBox.shrink()),
        ]));
  }
}
