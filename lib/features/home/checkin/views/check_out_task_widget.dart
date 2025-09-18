import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/views/check_out_task_expand_widget.dart';
import 'package:whms/models/pair.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_status_working_unit.dart';
import 'package:whms/widgets/z_space.dart';

class CheckOutTaskWidget extends StatefulWidget {
  const CheckOutTaskWidget(
      {super.key,
      required this.task,
      required this.listSub,
      required this.info,
      required this.cubit});

  final WorkingUnitModel task;
  final List<WorkingUnitModel> listSub;
  final WorkCheckOutModel info;
  final CheckOutCubit cubit;

  @override
  State<CheckOutTaskWidget> createState() => _CheckOutTaskWidgetState();
}

class _CheckOutTaskWidgetState extends State<CheckOutTaskWidget> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    TaskCheckoutStatus statusCo = TaskCheckoutStatus.noChange;
    for (var e in widget.listSub) {
      if (e.status !=
          (cfC.mapWorkingUnit[e.id]?.status ??
              StatusWorkingDefine.unknown.value)) {
        statusCo = TaskCheckoutStatus.canCheckout;
        if (widget.cubit.mapWorkingTime[e.id] == 0) {
          statusCo = TaskCheckoutStatus.mustChangeWorkingTime;
          break;
        }
      }
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          border: Border.all(
            width: ScaleUtils.scaleSize(1, context),
            color: statusCo == TaskCheckoutStatus.noChange
                ? Colors.transparent
                : (statusCo == TaskCheckoutStatus.canCheckout
                    ? ColorConfig.greenState
                    : ColorConfig.redState),
          ),
          boxShadow: const [ColorConfig.boxShadow2]),
      // padding:
      //     EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(8, context)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpand = !isExpand;
              });
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(ScaleUtils.scaleSize(8, context)),
                      topRight:
                          Radius.circular(ScaleUtils.scaleSize(8, context)),
                      bottomLeft: Radius.circular(
                          ScaleUtils.scaleSize(isExpand ? 0 : 8, context)),
                      bottomRight: Radius.circular(
                          ScaleUtils.scaleSize(isExpand ? 0 : 8, context)),
                    ),
                    color: Colors.white,
                    boxShadow: [if (isExpand) ColorConfig.boxShadow2]),
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(12, context),
                    vertical: ScaleUtils.scaleSize(12, context)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: ScaleUtils.scaleSize(4, context)),
                        child: Text(widget.task.title,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w600,
                                color: ColorConfig.textColor,
                                letterSpacing: -0.02,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 2),
                      ),
                    ),
                    // Expanded(
                    //   flex: 5,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //         right: ScaleUtils.scaleSize(4, context)),
                    //     child: Text(widget.task.title,
                    //         style: TextStyle(
                    //             fontSize: ScaleUtils.scaleSize(14, context),
                    //             fontWeight: FontWeight.w600,
                    //             color: ColorConfig.textColor,
                    //             letterSpacing: -0.02,
                    //             overflow: TextOverflow.ellipsis),
                    //         maxLines: 2),
                    //   ),
                    // ),
                    Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(4, context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                WorkingPointWidget(
                                    wp: widget.info.workingPoint),
                              ],
                            ))),
                    Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(4, context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IntrinsicWidth(
                                  child: StatusCardWU(
                                      status: widget.info.status,
                                      fontSize: 12,
                                      isSelected: false,
                                      radius: 229),
                                ),
                              ],
                            ))),
                    Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(4, context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TimeDoingTask(
                                    duration: widget.info.workingTime),
                              ],
                            ))),
                    Container(
                      width: ScaleUtils.scaleSize(20, context),
                      alignment: Alignment.centerRight,
                      child: Image.asset('assets/images/icons/ic_dropdown.png',
                          height: ScaleUtils.scaleSize(10, context)),
                    )
                  ],
                )),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 229),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: 0.0,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isExpand
                ? Padding(
                    padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(20, context))
                        .copyWith(
                            top: ScaleUtils.scaleSize(12, context),
                            bottom: ScaleUtils.scaleSize(12, context)),
                    child: CheckOutTaskExpandWidget(
                      subtasks: widget.listSub,
                      mapAddress: widget.cubit.mapAddress,
                      mapScope: widget.cubit.mapScope,
                      mapDuration: widget.cubit.mapWorkingTime,
                      canEditDF: widget
                              .cubit.mapCanEditDefaultSubtask[widget.task.id] ??
                          Pair<String, bool>("", true),
                      onChangeWorkingTime: (v, e) {
                        widget.cubit.changeWorkingTime(e, v, context);
                      },
                      onChangeStatus: (v, e) {
                        widget.cubit
                            .updateWorkStatus(e.copyWith(status: v), context);
                      },
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey<bool>(false),
                  ),
          )
        ],
      ),
    );
  }
}

class WorkingPointWidget extends StatelessWidget {
  const WorkingPointWidget({super.key, required this.wp, this.fontSize = 12});

  final int wp;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(229),
          color: const Color(0xFFFFE5D7)),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(8, context),
          vertical: ScaleUtils.scaleSize(4, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppText.txtWorkingPoint.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize, context),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE65100),
                  letterSpacing: -0.02)),
          const ZSpace(w: 4),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE65100),
            ),
            // height: ScaleUtils.scaleSize(fontSize + 2, context),
            // width: ScaleUtils.scaleSize(fontSize + 2, context),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(4, context)),
            child: Center(
              child: Text("$wp",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(fontSize - 2, context),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.02)),
            ),
          )
        ],
      ),
    );
  }
}

class TimeDoingTask extends StatelessWidget {
  const TimeDoingTask({super.key, required this.duration, this.fontSize = 12});

  final int duration;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(229),
          color: const Color(0xFFDFFEF5)),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(12, context),
          vertical: ScaleUtils.scaleSize(4, context)),
      child: Text(DateTimeUtils.formatDuration(duration),
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(fontSize, context),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2C7300),
              letterSpacing: -0.02)),
    );
  }
}

enum TaskCheckoutStatus { noChange, canCheckout, mustChangeWorkingTime }
