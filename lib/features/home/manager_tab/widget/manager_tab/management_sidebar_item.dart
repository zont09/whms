import 'dart:math';

import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagementSidebarItem extends StatelessWidget {
  final WorkingUnitModel item;
  final ManagementCubit cubit;
  const ManagementSidebarItem(
    this.item,
    this.cubit, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (item.type == AppText.txtSubTask.text) {
      return const SizedBox.shrink();
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          margin: EdgeInsets.only(
              top: ScaleUtils.scaleSize(6, context),
              left: ScaleUtils.scaleSize(5, context) +
                  max(0, (item.level - 1) * ScaleUtils.scaleSize(12, context)),
              bottom: ScaleUtils.scaleSize(6, context)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Stack(children: [
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(5, context),
                      vertical: ScaleUtils.scaleSize(5, context)),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(1000),
                      boxShadow: cubit.selectedWorking!.id == item.id
                          ? [
                              BoxShadow(
                                  blurStyle: BlurStyle.outer,
                                  blurRadius: ScaleUtils.scaleSize(3, context),
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(
                                      0, ScaleUtils.scaleSize(2, context)))
                            ]
                          : [],
                      border: Border.all(
                          color: cubit.selectedWorking!.id == item.id
                              ? Colors.white
                              : Colors.transparent)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if(item.type != TypeAssignmentDefine.epic.title)
                    Image.asset(item.iconType,
                        width: ScaleUtils.scaleSize(24, context),
                        height: ScaleUtils.scaleSize(24, context),
                        color: Colors.white),
                    if(item.type == TypeAssignmentDefine.epic.title)
                    Container(
                      height: ScaleUtils.scaleSize(26, context),
                      width: ScaleUtils.scaleSize(26, context),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: ScaleUtils.scaleSize(1, context),
                              color: ColorConfig.border7)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(229),
                        child: cubit.state == 0
                            ? CircularProgressIndicator(
                          color: ColorConfig.primary3,
                        )
                            : (cubit.mapAvtEpic[item.id] != null
                            ? Image.memory(cubit.mapAvtEpic[item.id]!.bytes!,
                            height: ScaleUtils.scaleSize(25, context))
                            : Image.asset('assets/images/icons/ic_epic.png',
                          height: ScaleUtils.scaleSize(25, context), color: Colors.white,)),
                      ),
                    ),
                    SizedBox(width: ScaleUtils.scaleSize(5, context)),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (item.type == TypeAssignmentDefine.story.title ||
                              item.type == TypeAssignmentDefine.sprint.title)
                            Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ScaleUtils.scaleSize(5, context)),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        color: item.background),
                                    child: Text(item.typeString,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScaleUtils.scaleSize(
                                                9, context)))),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(5, context)),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ScaleUtils.scaleSize(5, context)),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        color: DateTimeUtils.convertToDateTime(
                                            DateTimeUtils.convertTimestampToDateString(
                                                item.deadline)).isBefore(DateTime.now()) ? Colors.black : item.background),
                                    child: Text(item.deadlineString,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color:
                                            DateTimeUtils.convertToDateTime(
                                                DateTimeUtils.convertTimestampToDateString(
                                                    item.deadline)).isBefore(DateTime.now()) ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScaleUtils.scaleSize(
                                                9, context)))),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(5, context)),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        ScaleUtils.scaleSize(5, context)),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(1000),
                                        color: item.background),
                                    child: Text(item.percent < 0 ? '0%' : '${item.percent}%',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScaleUtils.scaleSize(
                                                9, context)))),
                              ],
                            ),
                          Text(item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      cubit.selectedWorking!.id == item.id
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                  fontSize: ScaleUtils.scaleSize(13, context)))
                        ]))
                  ])),
              Positioned.fill(
                  child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(1000),
                          onTap: () {
                            cubit.chooseWorkingUnit(item);
                            context.go(
                                '${AppRoutes.manager}/${cubit.selectedScope!.id}&${item.position}');
                          })))
            ])),
            Opacity(
                opacity: (item.children.isEmpty ||
                        !(item.children.isNotEmpty &&
                            item.type != TypeAssignmentDefine.task.title &&
                            item.level < 3))
                    ? 0
                    : 1,
                child: InkResponse(
                  onTap: () {
                    item.isOpen = !item.isOpen;
                    cubit.buildUI();
                  },
                  radius: ScaleUtils.scaleSize(12, context),
                  splashFactory: InkRipple.splashFactory,
                  child: Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
                    child: Icon(
                      item.isOpen ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: ScaleUtils.scaleSize(20, context)
                    )
                  )
                )
            )
          ])),
      if (item.isOpen && item.children.isNotEmpty && item.level < 3)
        Column(
            children: item.children.where((e) => e.type != TypeAssignmentDefine.task.title)
                .map((subItem) => ManagementSidebarItem(subItem, cubit))
                .toList())
    ]);
  }
}
