import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/features/home/checkin/views/select_work_view.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView2 extends StatelessWidget {
  const MainView2({
    super.key,
    required this.cubit,
    required this.cubitMT,
  });

  final CreateTaskCubit cubit;
  final MainTabCubit cubitMT;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return BlocProvider(
      create: (context) => SelectWorkCubit(ConfigsCubit.fromContext(context))
        ..initData(null, null, null, ctx: context),
      child: BlocBuilder<SelectWorkCubit, int>(
        builder: (cc, ss) {
          var cubitSW = BlocProvider.of<SelectWorkCubit>(cc);
          if (ss == 0) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorConfig.primary3,
              ),
            );
          }
          return Column(
            children: [
              Expanded(child: SelectWorkView(cubitMA: cubitMT)),
              const ZSpace(h: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ZButton(
                      title: AppText.btnCancel.text,
                      icon: "",
                      colorTitle: ColorConfig.primary2,
                      colorBackground: Colors.transparent,
                      colorBorder: Colors.transparent,
                      fontWeight: FontWeight.w600,
                      sizeTitle: 16,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  SizedBox(width: ScaleUtils.scaleSize(12, context)),
                  ZButton(
                      title: AppText.btnAdd.text,
                      icon: "",
                      sizeTitle: 16,
                      paddingVer: 7,
                      paddingHor: 16,
                      onPressed: () async {
                        bool isSuccess = false;
                        await DialogUtils.handleDialog(context, () async {
                          try {
                            final idUser =
                                ConfigsCubit.fromContext(context).user.id;
                            final workShift = await UserServices.instance
                                .getWorkShiftByIdUserAndDate(
                                    idUser, DateTimeUtils.getCurrentDate());
                            if (workShift != null) {
                              for (var work in cubitSW.selectWork) {
                                if(context.mounted) {
                                  await _addWorkToToday(
                                      cfC, workShift, work, context);
                                }
                                for(var e in cfC.mapWorkChild[work.id] ?? []) {
                                  if(context.mounted) {
                                    await _addWorkToToday(
                                        cfC, workShift, e, context);
                                  }
                                }
                              }
                            }
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
                            failedMessage: AppText.textHasError.text,
                            failedTitle: AppText.titleFailed.text,
                            isShowDialogSuccess: false);
                        if (isSuccess && context.mounted) {
                          // cubitMT.initData(context);
                          Navigator.of(context).pop();
                        }
                      }),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  _addWorkToToday(ConfigsCubit cfC, WorkShiftModel workShift,
      WorkingUnitModel work, BuildContext context) async {
    final workField = await WorkingService.instance
        .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(workShift.id, work.id);
    if (workField != null && context.mounted) {
      ConfigsCubit.fromContext(context)
          .updateWorkField(workField.copyWith(enable: true), workField);
      // await WorkingService.instance.updateWorkField(
      //     workField.copyWith(enable: true));
    } else {
      String id = FirebaseFirestore.instance
          .collection('whms_pls_work_field')
          .doc()
          .id;
      WorkFieldModel newWorkField = WorkFieldModel(
        id: id,
        taskId: work.id,
        fromStatus: work.status,
        toStatus: work.status,
        date: DateTimeUtils.getCurrentDate(),
        workShift: workShift.id,
        enable: true,
      );
      cfC.addWorkField(newWorkField);
      // await WorkingService.instance
      //     .addNewWorkField(newWorkField);
    }
  }
}
