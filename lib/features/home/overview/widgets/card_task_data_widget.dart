import 'dart:math';

import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/widgets/personal/task_preview.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/mouse_hover_popup.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import '../../checkin/widgets/history_card_widget.dart';

class CardTaskDataWidget extends StatelessWidget {
  const CardTaskDataWidget(
      {super.key,
      required this.data,
      required this.children,
      required this.weight,
      this.onShowDetails});

  final WorkingUnitModel data;
  final int children;
  final List<int> weight;
  final Function()? onShowDetails;

  @override
  Widget build(BuildContext context) {
    return MousePopup(
      width: 400,
      popupContent: TaskPreview(task: data, width: 400),
      child: InkWell(
        onTap: (){
          if(onShowDetails != null) {
            onShowDetails!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
              color: Colors.white,
              boxShadow: const [ColorConfig.boxShadow2]),
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(16, context),
              vertical: ScaleUtils.scaleSize(8, context)),
          child: Row(
            children: [
              Expanded(
                  flex: weight[0],
                  child: Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w500,
                                color: ColorConfig.textColor,
                                letterSpacing: -0.02,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 2,
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[1],
                  child: Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: LayoutBuilder(
                          builder: (c, con) {
                            return Stack(
                              children: [
                                Container(
                                  width: con.maxWidth,
                                  height: ScaleUtils.scaleSize(10, context),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(229),
                                      color: const Color(0xFFD9D9D9)),
                                ),
                                Container(
                                  width:  con.maxWidth *
                                      max(0, FunctionUtils.getDurationFromStatus(
                                          data.status, data.type))  /
                                      100,
                                  height: ScaleUtils.scaleSize(10, context),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(229),
                                      color: ColorConfig.primary3),
                                )
                              ],
                            );
                          },
                        )),
                        const ZSpace(w: 5),
                        Stack(children: [
                          Text(
                            "100%",
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(12, context),
                                fontWeight: FontWeight.w500,
                                color: Colors.transparent),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${max(0, FunctionUtils.getDurationFromStatus(data.status, data.type))}%",
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(12, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.textColor),
                            ),
                          ),
                        ])
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[2],
                  child: Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(content: children.toString()),
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[3],
                  child: Padding(
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(content: "${max(0, data.workingPoint)}"),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
