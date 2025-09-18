import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/features/home/checkin/widgets/task_general_view.dart';
import 'package:whms/features/manager/widgets/list_status_dropdown.dart';
import 'package:whms/models/pair.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/dropdown_status_working_unit.dart';
import 'package:whms/widgets/working_time_field.dart';
import 'package:whms/widgets/z_space.dart';


class CheckOutTaskExpandWidget extends StatelessWidget {
  const CheckOutTaskExpandWidget(
      {super.key,
      required this.subtasks,
      required this.mapAddress,
      required this.mapScope,
      required this.mapDuration,
      required this.canEditDF,
      required this.onChangeStatus,
      required this.onChangeWorkingTime});

  final List<WorkingUnitModel> subtasks;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, ScopeModel> mapScope;
  final Pair<String, bool> canEditDF;
  final Map<String, int> mapDuration;
  final Function(int, WorkingUnitModel) onChangeStatus;
  final Function(int, WorkingUnitModel) onChangeWorkingTime;

  // final List<WorkingUnitModel> listCheckout;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [10, 4, 4, 4];
    return Column(
      children: [
        HeaderTitle(weight: weight),
        const ZSpace(h: 9),
        ...subtasks.map((e) => Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ScaleUtils.scaleSize(4, context)),
              child: CardSubtaskCheckout(
                model: e,
                weight: weight,
                mapAddress: mapAddress,
                mapScope: mapScope,
                duration: mapDuration[e.id] ?? 0,
                canEditDF: canEditDF,
                onChangeStatus: (v) {
                  onChangeStatus(v, e);
                },
                onChangeWorkingTime: (v) {
                  onChangeWorkingTime(v, e);
                },
              ),
            ))
      ],
    );
  }
}

class CardSubtaskCheckout extends StatelessWidget {
  const CardSubtaskCheckout(
      {super.key,
      required this.model,
      required this.weight,
      required this.mapAddress,
      required this.mapScope,
      required this.duration,
      required this.onChangeStatus,
      required this.onChangeWorkingTime,
      required this.canEditDF});

  final WorkingUnitModel model;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, ScopeModel> mapScope;
  final int duration;
  final Function(int) onChangeStatus;
  final Function(int) onChangeWorkingTime;
  final Pair<String, bool> canEditDF;
  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    final isCheckoutTask = (cfC.mapWorkingUnit[model.id]?.status ??
            StatusWorkingDefine.unknown.value) !=
        model.status;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2],
          border: Border.all(
              width: ScaleUtils.scaleSize(0.85, context),
              color:
                  isCheckoutTask ? (duration == 0 ? ColorConfig.redState : ColorConfig.greenState) : Colors.transparent)),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(12, context),
          vertical: ScaleUtils.scaleSize(6, context)),
      child: Row(
        children: [
          Expanded(
            flex: weight[0],
            child: Padding(
                padding:
                    EdgeInsets.only(right: ScaleUtils.scaleSize(4, context)),
                child: TaskGeneralView(
                    work: model, mapAddress: mapAddress, mapScope: mapScope)),
          ),
          Expanded(
            flex: weight[1],
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(4, context)),
                child: Center(
                  child: SizedBox(
                    width: ScaleUtils.scaleSize(110, context),
                    child: StatusCardWU(
                        status: cfC.mapWorkingUnit[model.id]?.status ??
                            StatusWorkingDefine.unknown.value,
                        fontSize: 10,
                        isSelected: false,
                        radius: 229),
                  ),
                )),
          ),
          Expanded(
            flex: weight[2],
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(4, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (canEditDF.first == model.id && !canEditDF.second)
                      Expanded(
                          child: InkWell(
                            onTap: () {
                              ToastUtils.showBottomToast(context, AppText.textDoneAllSubTaskToEditDefault.text, duration: 3);
                            },
                            child: Center(
                              child: SizedBox(
                                width: ScaleUtils.scaleSize(110, context),
                                child: StatusCardWU(
                                    status: model.status,
                                    fontSize: 10,
                                    isSelected: false,
                                    radius: 229),
                              ),
                            ),
                          )),
                    if (canEditDF.first != model.id || canEditDF.second)
                      ListStatusDropdown(
                        isPermission: true,
                        size: 8,
                        height: 21,
                        paddingHor: 6,
                        iconSize: 16,
                        maxWidth: 110,
                        isShadow: false,
                        selector: model.status,
                        typeOption: model.owner.isEmpty ? 2 : 1,
                        onChanged: (value) {
                          onChangeStatus(value!);
                        },
                      ),
                  ],
                )),
          ),
          Expanded(
            flex: weight[3],
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(4, context)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  WorkingTimeField(
                      initTime: duration,
                      onChange: (v) {
                        onChangeWorkingTime(v);
                      })
                ])),
          ),
        ],
      ),
    );
  }
}

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key, required this.weight});

  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(12, context)),
      child: Row(
        children: [
          Expanded(
            flex: weight[0],
            child: Padding(
              padding: EdgeInsets.only(right: ScaleUtils.scaleSize(4, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(AppText.titleTask.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          shadows: const [ColorConfig.textShadow])),
                ],
              ),
            ),
          ),
          Expanded(
            flex: weight[1],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(4, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppText.titleOldStatus.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          shadows: const [ColorConfig.textShadow])),
                ],
              ),
            ),
          ),
          Expanded(
            flex: weight[2],
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(4, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppText.titleNewStatus.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          shadows: const [ColorConfig.textShadow])),
                ],
              ),
            ),
          ),
          Expanded(
            flex: weight[3],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(4, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppText.titleTimeDoingTask.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          shadows: const [ColorConfig.textShadow])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
