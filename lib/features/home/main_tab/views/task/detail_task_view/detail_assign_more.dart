import 'package:flutter/material.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/features/home/main_tab/widgets/task/menu_button.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';

import '../../../../../../configs/color_config.dart' show ColorConfig;

class DetailAssignMore extends StatelessWidget {
  final Function(WorkingUnitModel) reload;
  final Function()? endEvent;
  final Function(WorkingUnitModel)? edited;
  final Function(WorkingUnitModel) onDoToday;
  final Function(WorkingUnitModel) onRemoveToday;
  final Function(WorkingUnitModel) onDoing;
  final Function(WorkingUnitModel, WorkingUnitModel) onUpdate;
  final DetailAssignCubit cubit;
  final int isTaskToday;
  final String userId;

  const DetailAssignMore(
      {required this.cubit,
      required this.endEvent,
      required this.isTaskToday,
      required this.onDoToday,
      required this.onRemoveToday,
      required this.onDoing,
      required this.onUpdate,
      required this.edited,
      required this.reload,
      required this.userId,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(
            top: ScaleUtils.scaleSize(3, context),
            right: ScaleUtils.scaleSize(3, context)),
        child: Theme(
            data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                    color: Colors.white,
                    textStyle: const TextStyle(color: ColorConfig.textColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(ScaleUtils.scaleSize(12, context))),
                        side: BorderSide(
                            color: ColorConfig.border,
                            width: ScaleUtils.scaleSize(2, context))))),
            child: MenuButton(
                work: cubit.wu,
                endEvent: endEvent != null ? endEvent! : () {},
                deletePress: () => cubit.delete(cubit.wu,
                    isTask: cubit.wu.type == TypeAssignmentDefine.task.title),
                isTaskToday: isTaskToday,
                onDoToday: onDoToday,
                onRemoveToday: onRemoveToday,
                onUpdate: onUpdate,
                onDoing: onDoing,
                editPressed: () {
                  DialogUtils.showAlertDialog(context,
                      child: CreateAssignmentPopup(
                          typeAssignment:
                              TypeAssignmentDefineExtension.types(cubit.wu.type)
                                      .index +
                                  4,
                          isEdit: true,
                          reload: reload,
                          edited: (v) async {
                            await cubit.updateWU(v);
                            await edited!(v);
                          },
                          scopes: cubit.wu.scopes,
                          userId: userId,
                          selectedWorking: cubit.wu,
                          assignees: cubit.wu.assignees));
                })));
  }
}
