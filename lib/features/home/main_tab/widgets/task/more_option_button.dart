import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoreOptionButton extends StatelessWidget {
  const MoreOptionButton(
      {super.key,
      required this.editPressed,
      required this.deletePress,
      required this.endEvent,
      required this.tab,
      this.isDeleteAndEdit = false,
      this.showEdit = true,
      required this.work});

  final Function(bool) editPressed;
  final Function() endEvent;
  final Function() deletePress;
  final WorkingUnitModel work;
  final String tab;
  final bool isDeleteAndEdit;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    MainTabCubit? cubitMT;
    try {
      cubitMT = BlocProvider.of<MainTabCubit>(context);
    } catch (e) {
      debugPrint("===> failed to get main tab cubit");
    }

    bool isAddToTaskToday = (tab == "201" ||
        (cubitMT != null &&
            cubitMT.listSubTaskToday.any((item) => item.id == work.id)));

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
            child: Image.asset('assets/images/icons/ic_expand.png',
                height: ScaleUtils.scaleSize(16, context)),
          );
        },
        menuChildren: [
          if (work.owner.isNotEmpty ||
              work.type != TypeAssignmentDefine.subtask.title ||
              showEdit)
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
                          await editPressed(isAddToTaskToday);
                          if (cubitMT != null && context.mounted) {
                            // cubitMT.initData(context);
                          }
                          // try {
                          //   if(context.mounted) {
                          //     var cubitMT = BlocProvider.of<MainTabCubit>(context);
                          //     cubitMT.initData(context);
                          //   }
                          // }catch(e){
                          //   debugPrint("xxxxxxxxxxxx Failed");
                          // }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Text(AppText.textEdit.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(10, context),
                                    color: ColorConfig.textTertiary)))))),
          if (work.owner.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: IntrinsicHeight(
                  child: MenuItemButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () async {
                        final isDelete = await DialogUtils.showConfirmDialog(
                            context,
                            AppText.titleConfirm.text,
                            AppText.textConfirmDeleteTask.text);
                        if (!isDelete) return;
                        bool isSuccess = false;
                        await DialogUtils.handleDialog(context, () async {
                          try {
                            await deletePress();
                            isSuccess = true;
                            return ResponseModel(
                                status: ResponseStatus.ok, results: "");
                          } catch (e) {
                            return ResponseModel(
                                status: ResponseStatus.error,
                                error: ErrorModel(text: e.toString()));
                          }
                        }, () {},
                            successMessage: AppText.titleSuccess.text,
                            successTitle: AppText.titleSuccess.text,
                            failedMessage: AppText.titleFailed.text,
                            failedTitle: AppText.textHasError.text,
                            isShowDialogSuccess: false);
                        if (isSuccess && context.mounted) {
                          endEvent();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(12, context),
                              vertical: ScaleUtils.scaleSize(6, context)),
                          child: Text(AppText.textDelete.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(10, context),
                                  color: ColorConfig.textTertiary))))),
            ),
          // if (isAddToTaskToday && checkIn == StatusCheckInDefine.checkIn)
          //   Container(
          //       decoration: BoxDecoration(
          //         border: Border(
          //           bottom: BorderSide(color: Colors.grey.shade200),
          //         ),
          //       ),
          //       child: IntrinsicHeight(
          //           child: MenuItemButton(
          //               style: ButtonStyle(
          //                 minimumSize: WidgetStateProperty.all(Size.zero),
          //                 padding: WidgetStateProperty.all(EdgeInsets.zero),
          //               ),
          //               onPressed: () async {
          //                 DialogUtils.showLoadingDialog(context);
          //                 final idUser =
          //                     ConfigsCubit.fromContext(context).user.id;
          //                 final workShift = await UserServices.instance
          //                     .getWorkShiftByIdUserAndDate(
          //                         idUser, DateTimeUtils.getCurrentDate());
          //                 final workService = WorkingService.instance;
          //                 if (workShift != null) {
          //                   final workField = await workService
          //                       .getWorkFieldByWorkShiftAndIdWork(
          //                           workShift.id, work.id);
          //                   if (workField != null) {
          //                     await workService.updateWorkField(
          //                         workField.copyWith(enable: false));
          //                   }
          //                 }
          //                 if (context.mounted) {
          //                   if(cubitMT != null) {
          //                     cubitMT.initData(context);
          //                   }
          //                 }
          //                 if (context.mounted) {
          //                   Navigator.of(context).pop();
          //                 }
          //               },
          //               child: Container(
          //                   width: double.infinity,
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: ScaleUtils.scaleSize(12, context),
          //                       vertical: ScaleUtils.scaleSize(6, context)),
          //                   child: Text(AppText.textRemoveFromTaskToday.text,
          //                       style: TextStyle(
          //                           fontSize: ScaleUtils.scaleSize(10, context),
          //                           color: ColorConfig.textTertiary)))))),
          // if (!isAddToTaskToday && checkIn == StatusCheckInDefine.checkIn)
          //   Container(
          //       decoration: BoxDecoration(
          //         border: Border(
          //           bottom: BorderSide(color: Colors.grey.shade200),
          //         ),
          //       ),
          //       child: IntrinsicHeight(
          //           child: MenuItemButton(
          //               style: ButtonStyle(
          //                 minimumSize: WidgetStateProperty.all(Size.zero),
          //                 padding: WidgetStateProperty.all(EdgeInsets.zero),
          //               ),
          //               onPressed: () async {
          //                 DialogUtils.showLoadingDialog(context);
          //                 final idUser =
          //                     ConfigsCubit.fromContext(context).user.id;
          //                 final workShift = await UserServices.instance
          //                     .getWorkShiftByIdUserAndDate(
          //                         idUser, DateTimeUtils.getCurrentDate());
          //                 final workService = WorkingService.instance;
          //                 if (workShift != null) {
          //                   final workField = await workService
          //                       .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
          //                           workShift.id, work.id);
          //                   if (workField != null) {
          //                     await workService.updateWorkField(
          //                         workField.copyWith(enable: true));
          //                   } else {
          //                     String id = FirebaseFirestore.instance
          //                         .collection('whms_pls_work_field')
          //                         .doc()
          //                         .id;
          //                     WorkFieldModel newWorkField = WorkFieldModel(
          //                       id: id,
          //                       taskId: work.id,
          //                       fromStatus: work.status,
          //                       toStatus: work.status,
          //                       date: DateTimeUtils.getCurrentDate(),
          //                       workShift: workShift.id,
          //                       enable: true,
          //                     );
          //                     await workService.addNewWorkField(newWorkField);
          //                   }
          //                   if (context.mounted && cubitMT != null) {
          //                     cubitMT.initData(context);
          //                   }
          //                   if (context.mounted) {
          //                     Navigator.of(context).pop();
          //                   }
          //                 }
          //               },
          //               child: Container(
          //                   width: double.infinity,
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: ScaleUtils.scaleSize(12, context),
          //                       vertical: ScaleUtils.scaleSize(6, context)),
          //                   child: Text(AppText.textAddToTaskToday.text,
          //                       style: TextStyle(
          //                           fontSize: ScaleUtils.scaleSize(10, context),
          //                           color: ColorConfig.textTertiary)))))),
          if (isDeleteAndEdit)
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
                          ConfigsCubit.fromContext(context).updateWorkingUnit(
                              work.copyWith(closed: true), work);
                          endEvent();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Text(AppText.textCloseTask.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(10, context),
                                    color: ColorConfig.textTertiary)))))),
        ]);
  }
}
