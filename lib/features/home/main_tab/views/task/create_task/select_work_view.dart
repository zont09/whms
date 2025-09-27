import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/select_work_view.dart';
import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SelectWorkViewTask extends StatelessWidget {
  const SelectWorkViewTask({
    super.key,
    required this.cubitMT,
    required this.cubit,
  });

  final MainTabCubit cubitMT;
  final CreateTaskCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectWorkCubit(ConfigsCubit.fromContext(context))
        ..initData(cubitMT.listSum, null, null, selectOne: true),
      child: BlocBuilder<SelectWorkCubit, int>(
        builder: (cc, ss) {
          var cubitSW =
          BlocProvider.of<SelectWorkCubit>(cc);
          return Column(
            children: [
              Expanded(
                  child: SelectWorkView(cubitMA: cubitMT)),
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
                        cubit.changeTab(0);
                      }),
                  SizedBox(
                      width: ScaleUtils.scaleSize(
                          12, context)),
                  ZButton(
                      title: AppText.btnAdd.text,
                      icon: "",
                      sizeTitle: 16,
                      paddingVer: 7,
                      paddingHor: 16,
                      onPressed: () async {
                        cubit.changeWorkPar(
                            cubitSW.workSelected);
                        cubit.changeTab(0);
                      }),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}