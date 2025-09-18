import 'package:flutter/material.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/widgets/custom_check_box.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class HeaderTaskTable extends StatelessWidget {
  const HeaderTaskTable({
    super.key,
    this.cubit,
    this.cubitCO,
    required this.isAddTask,
    this.isShowSelectedAll = true,
    this.onTapTitle
  });

  final bool isAddTask;
  final SelectWorkCubit? cubit;
  final CheckOutCubit? cubitCO;
  final bool isShowSelectedAll;
  final Function()? onTapTitle;

  @override
  Widget build(BuildContext context) {
    final List<int> tableWeight = [1, 6, 2, 2, 2, 1, 1, 2];
    return Container(
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(20, context)),
        child:
        Row(children: [
          if (cubit != null || cubitCO != null)
            Expanded(
                flex: tableWeight[0],
                child: isShowSelectedAll
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            CustomCheckBox(
                                isActive: cubit != null
                                    ? cubit!.isSelectedAll
                                    : cubitCO!.isSelectedAll,
                                size: 12,
                                onTap: () {
                                  if (cubit != null) {
                                    cubit!.changeSelectedAll();
                                  }
                                  if (cubitCO != null) {
                                    cubitCO!.changeSelectedAll();
                                  }
                                })
                          ])
                    : const Text("")),
          if (cubit != null || cubitCO != null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          Expanded(
              flex: tableWeight[1],
              child: InkWell(
                onTap: () {
                  if(onTapTitle != null) {
                    onTapTitle!();
                  }
                },
                child: Text(
                  AppText.titleTask.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          if(cubitCO == null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(cubitCO == null)
          Expanded(
              flex: tableWeight[2],
              child: Center(
                child: Text(
                  AppText.titleDeadline.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          Expanded(
              flex: tableWeight[3],
              child: Center(
                child: Text(
                  AppText.titleStatus.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          if(cubitCO == null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(cubitCO == null)
          Expanded(
              flex: tableWeight[5],
              child: Center(
                child: Text(
                  AppText.titlePriorityLevelShort.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          if(cubitCO != null)
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(cubitCO != null)
            Expanded(
                flex: tableWeight[7],
                child: Center(
                  child: Text(
                    AppText.titleWorkingTime.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400),
                  ),
                )),
          if(cubitCO == null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(cubitCO == null)
          Expanded(
              flex: tableWeight[4],
              child: Center(
                child: Text(
                  AppText.titleWorkingPoint.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400),
                ),
              )),
          if(!isAddTask)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if(!isAddTask)
          Expanded(flex: tableWeight[5], child: Text("")),
        ]));
  }
}
