import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/bloc/duplicate_working_unit_cubit.dart';
import 'package:whms/features/home/manager_tab/duplicate/select_parent_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DuplicateWuPopup extends StatelessWidget {
  const DuplicateWuPopup({super.key, required this.model});

  final WorkingUnitModel model;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DuplicateWorkingUnitCubit(ConfigsCubit.fromContext(context), model)
            ..initData(),
      child: BlocBuilder<DuplicateWorkingUnitCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<DuplicateWorkingUnitCubit>(c);
          if (s == 0) {
            return Container(
              height: MediaQuery.of(context).size.height * 3 / 5,
              width: ScaleUtils.scaleSize(600, context),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(24, context)),
                  color: Colors.white),
              child: const Center(
                  child:
                      CircularProgressIndicator(color: ColorConfig.primary3)),
            );
          }
          return Container(
            height: MediaQuery.of(context).size.height * 3 / 5,
            width: ScaleUtils.scaleSize(600, context),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(24, context)),
                color: Colors.white),
            padding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(24, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(24, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppText.titleDuplicateWorkingUnit.text
                              .replaceAll('@', model.type)
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(24, context),
                              fontWeight: FontWeight.w700,
                              color: ColorConfig.textColor6,
                              shadows: const [ColorConfig.textShadow])),
                      Text(AppText.textDuplicateWorkingUnit.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(16, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.textColor)),
                      Row(
                        children: [
                          Text(AppText.textSelectPathDuplicateWorkingUnit.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(18, context),
                                  fontWeight: FontWeight.w600,
                                  color: ColorConfig.textColor6)),
                          const ZSpace(w: 5),
                          InkWell(
                            onTap: () {
                              DialogUtils.showAlertDialog(context,
                                  child: SelectParentPopup(cubitDp: cubit));
                            },
                            child: Image.asset(
                                'assets/images/icons/ic_add_meeting.png',
                                height: ScaleUtils.scaleSize(20, context)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const ZSpace(),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(24, context)),
                  child: Column(children: [
                    ...cubit.listParentDup
                        .map((e) => TaskDupSelectedView(e: e, cubit: cubit))
                  ]),
                )),
                const ZSpace(h: 9),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(24, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ZButton(
                          title: AppText.btnCancel.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorBackground: Colors.white,
                          colorBorder: Colors.white,
                          colorTitle: ColorConfig.primary2,
                          paddingHor: 12,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      const ZSpace(w: 9),
                      ZButton(
                          title: AppText.btnConfirm.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorBackground: const Color(0xFFFF2932),
                          colorBorder: const Color(0xFFFF2932),
                          colorTitle: Colors.white,
                          paddingHor: 24,
                          onPressed: () async {
                            DialogUtils.showLoadingDialog(context);
                            await cubit.handleDuplicate();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }
                          })
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class TaskDupSelectedView extends StatelessWidget {
  const TaskDupSelectedView({
    super.key,
    required this.e,
    required this.cubit,
  });

  final WorkingUnitModel e;
  final DuplicateWorkingUnitCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: TaskCardDup(model: e)),
        const ZSpace(w: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.all(ScaleUtils.scaleSize(4, context)),
              icon: Icon(Icons.remove,
                  color: ColorConfig.textColor6,
                  size: ScaleUtils.scaleSize(14, context)),
              onPressed: () {
                // Giảm số lượng
                int num = cubit.numOfDup[e.id] ?? 0;
                if (num > 1) {
                  cubit.updateNumOfDup(e, num - 1);
                }
              },
            ),
            Text(
              '${cubit.numOfDup[e.id] ?? 0}',
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  color: ColorConfig.textColor6),
            ),
            IconButton(
              padding: EdgeInsets.all(ScaleUtils.scaleSize(4, context)),
              icon: Icon(Icons.add,
                  color: ColorConfig.textColor6,
                  size: ScaleUtils.scaleSize(14, context)),
              onPressed: () {
                // Tăng số lượng
                int num = cubit.numOfDup[e.id] ?? 0;
                cubit.updateNumOfDup(e, num + 1);
              },
            ),
          ],
        ),
      ],
    );
  }
}
