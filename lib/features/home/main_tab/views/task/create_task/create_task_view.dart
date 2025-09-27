import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/setting_view.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/bottom_button_create_task.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/main_view_1.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/select_work_view.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class CreateTaskView extends StatelessWidget {
  const CreateTaskView({super.key, required this.cubitMT, required this.onAdd});

  final MainTabCubit cubitMT;
  final Function(WorkingUnitModel) onAdd;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.white),
        width: ScaleUtils.scaleSize(900, context),
        height: ScaleUtils.scaleSize(550, context),
        child: Stack(children: [
          Positioned(
            right: ScaleUtils.scaleSize(15, context),
            top: ScaleUtils.scaleSize(15, context),
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset('assets/images/icons/ic_close_check_in.png',
                    height: ScaleUtils.scaleSize(16, context))),
          ),
          BlocProvider(
            create: (context) => CreateTaskCubit(),
            child: BlocBuilder<CreateTaskCubit, int>(
              builder: (c, s) {
                var cubit = BlocProvider.of<CreateTaskCubit>(c);
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(50, context),
                      vertical: ScaleUtils.scaleSize(25, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          cubit.tab <= 1
                              ? AppText.titleAddTaskToList.text
                              : AppText.titleChooseTask.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(24, context),
                              fontWeight: FontWeight.w500,
                              color: ColorConfig.textColor6,
                              letterSpacing: -0.41,
                              shadows: const [ColorConfig.textShadow])),
                      SizedBox(height: ScaleUtils.scaleSize(5, context)),
                      Text(
                          cubit.tab <= 1
                              ? AppText.textAddTaskToList.text
                              : AppText.textChooseTask.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(16, context),
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFA6A6A6),
                              letterSpacing: -0.41)),
                      if (cubit.tab <= 1)
                        Expanded(
                            child: MainView1(cubit: cubit, cubitMT: cubitMT)),
                      if (cubit.tab == 2)
                        Expanded(
                            child: SelectWorkViewTask(
                                cubitMT: cubitMT, cubit: cubit)),
                      SizedBox(height: ScaleUtils.scaleSize(8, context)),
                      if (cubit.tab == 0)
                        SizedBox(height: ScaleUtils.scaleSize(12, context)),
                      if (cubit.tab == 0)
                        SettingView(
                            work: null,
                            isTaskToday: false,
                            initTime: cubit.workingTime,
                            onChanged: (value) {
                              cubit.changeWorkingTime(value);
                            },
                            onChangedStatus: (v) {},
                            isEdit: true),
                      if (cubit.tab == 0)
                        SizedBox(height: ScaleUtils.scaleSize(12, context)),
                      if (cubit.tab == 0)
                        BottomButtonCreateTask(
                            cubit: cubit,
                            onAdd: onAdd,
                            endEvent: () {
                              // cubitMT.initData(context);
                            }),
                      // if(cubit.tab == 1)
                      //   MainView2(cubit: cubit, cubitMT: cubitMT)
                    ],
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
