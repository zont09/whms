import 'package:whms/defines/status_working_define.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class MenuTaskOption extends StatelessWidget {
  const MenuTaskOption(
      {super.key, required this.work, required this.afterUpdateAction});

  final WorkingUnitModel work;
  final Function(WorkingUnitModel) afterUpdateAction;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return MenuAnchor(
        style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(4),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                side: BorderSide(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border))),
            padding: WidgetStateProperty.all(EdgeInsets.zero)),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child:
                Icon(Icons.more_vert, size: ScaleUtils.scaleSize(16, context)),
          );
        },
        menuChildren: [
          if (work.closed)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    // Wrap với IntrinsicHeight
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          DialogUtils.showLoadingDialog(context);
                          final WorkingService workService =
                              WorkingService.instance;
                          cfC.updateWorkingUnit(work.copyWith(closed: false), work);
                          final subtasks = await workService
                              .getWorkingUnitByIdParentIgnoreClosed(work.id);
                          for (var e in subtasks) {
                            cfC.updateWorkingUnit(e.copyWith(closed: false), e);
                          }
                          afterUpdateAction(work.copyWith(closed: false));
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Text(AppText.textReOpen.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(10, context),
                                    color: ColorConfig.textTertiary)))))),
          if (!work.closed)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    // Wrap với IntrinsicHeight
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          DialogUtils.showLoadingDialog(context);
                          final WorkingService workService =
                              WorkingService.instance;
                          cfC.updateWorkingUnit(work.copyWith(closed: true), work);
                          final subtasks = await workService
                              .getWorkingUnitByIdParentIgnoreClosed(work.id);
                          for (var e in subtasks) {
                            cfC.updateWorkingUnit(e.copyWith(closed: true), e);
                          }
                          afterUpdateAction(work.copyWith(closed: true));
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Text(AppText.textClose.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(10, context),
                                    color: ColorConfig.textTertiary)))))),
          if (work.status == StatusWorkingDefine.none.value)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    // Wrap với IntrinsicHeight
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          DialogUtils.showLoadingDialog(context);
                          cfC.updateWorkingUnit(work.copyWith(
                              status:
                              StatusWorkingDefine.processing.value), work);
                          afterUpdateAction(work.copyWith(
                              status: StatusWorkingDefine.processing.value));
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Text(AppText.textStart.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(10, context),
                                    color: ColorConfig.textTertiary)))))),
        ]);
  }
}
