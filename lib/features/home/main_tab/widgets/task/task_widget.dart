import 'dart:math';

import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget(
      {super.key,
      required this.work,
      required this.isSelected,
      required this.onTap,
      required this.mapAddress,
      this.isToday = false});

  final WorkingUnitModel work;
  final bool isSelected;
  final Function(String) onTap;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    // final cubitMT = BlocProvider.of<MainTabCubit>(context);
    final currentUser = ConfigsCubit.fromContext(context).user;
    return InkWell(
      onTap: () {
        onTap(work.id);
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: ScaleUtils.scaleSize(8, context)),
            padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(20, context),
                    vertical: ScaleUtils.scaleSize(12, context))
                .copyWith(top: ScaleUtils.scaleSize(12, context), left: ScaleUtils.scaleSize(12, context)),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color:
                        isSelected ? ColorConfig.redState : Colors.transparent),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(1, 1),
                    // horizontal and vertical offset
                    blurRadius: 5.9,
                    // blur radius
                    spreadRadius: 0,
                    // spread radius (optional, defaults to 0)
                    color: const Color(0xFF000000)
                        .withOpacity(0.16), // Convert hex color with alpha
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Row(children: [
                    if (mapAddress[work.id] != null)
                      for (int i = mapAddress[work.id]!.length - 1; i >= 0; i--)
                        Row(children: [
                          Tooltip(
                              message: mapAddress[work.id]![i].title,
                              child: Text(mapAddress[work.id]![i].type,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(11, context),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFA6A6A6)))),
                          if (i > 0)
                            Text(" > ",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(11, context),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFA6A6A6)))
                        ]),
                    if (work.scopes.isEmpty)
                      Row(children: [
                        Tooltip(
                            message: work.title,
                            child: Text(AppText.titlePersonal.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(11, context),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFA6A6A6)))),
                      ])
                  ])),
                  // Image.asset('assets/images/icons/ic_expand_task.png',
                  //     height: ScaleUtils.scaleSize(12, context))
                ]),
                SizedBox(height: ScaleUtils.scaleSize(5, context)),
                Row(
                  children: [
                    Tooltip(
                      message:
                      "${AppText.titleWorkingPoint.text}: ${max(0, work.workingPoint)}",
                      child: Container(
                        height: ScaleUtils.scaleSize(18, context),
                        width: ScaleUtils.scaleSize(18, context),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConfig.workingPointCl,
                        ),
                        padding:
                        EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Center(
                            child: Text(
                              "${max(0, work.workingPoint)}",
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(11, context),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.41),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const ZSpace(w: 5),
                    if (isToday)
                      Image.asset(
                          'assets/images/icons/tab_bar/ic_tab_today.png',
                          height: ScaleUtils.scaleSize(12, context),
                          color: ColorConfig.primary3),
                    if (isToday)
                      SizedBox(width: ScaleUtils.scaleSize(3, context)),
                    Expanded(
                      child: Text(
                        work.title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? ColorConfig.primary3
                                : ColorConfig.textColor,
                            overflow: TextOverflow.ellipsis,
                            letterSpacing: -0.02),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScaleUtils.scaleSize(5, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(children: [
                        AvatarItem(currentUser.avt, size: 17,),
                        SizedBox(width: ScaleUtils.scaleSize(5, context)),
                        Expanded(
                          child: Text(currentUser.name,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(12, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.textColor,
                                  overflow: TextOverflow.ellipsis)),
                        )
                      ]),
                    ),
                    StatusCard(status: work.status)
                  ],
                )
              ],
            ),
          ),
          // Positioned(
          //     top: ScaleUtils.scaleSize(5, context),
          //     left: ScaleUtils.scaleSize(5, context),
          //     child: Tooltip(
          //       message: "${AppText.titleWorkingPoint.text}: ${work.workingPoint}",
          //       child: Container(
          //         height: ScaleUtils.scaleSize(17, context),
          //         width: ScaleUtils.scaleSize(17, context),
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: ColorConfig.workingPointCl,
          //         ),
          //         padding: EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
          //         child: FittedBox(
          //           fit: BoxFit.scaleDown,
          //           child: Center(
          //             child: Text(
          //               "${work.workingPoint}",
          //               style: TextStyle(
          //                   fontSize: ScaleUtils.scaleSize(11, context),
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.w500,
          //                   letterSpacing: -0.41),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ))
        ],
      ),
    );
  }
}
