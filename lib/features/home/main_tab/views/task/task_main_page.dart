import 'package:whms/features/home/main_tab/blocs/task_main_page_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/header_and_option_task_page_view.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_personal_task_widget.dart';
import 'package:whms/features/home/main_tab/widgets/task/task_widget_in_task_page.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/drag_task_widget.dart';
import 'package:whms/widgets/loading_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskMainPage extends StatelessWidget {
  const TaskMainPage(
      {super.key,
      required this.listWork,
      required this.listScope,
      required this.sorted,
      required this.mapAddress,
      required this.mapScope,
      required this.mapWorkChild,
      required this.numberOfSubtask,
      required this.cubitMT,
      required this.getDataWorkChild,
      required this.updateListTask});

  final List<WorkingUnitModel> listWork;
  final List<String> sorted;
  final List<ScopeModel> listScope;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, ScopeModel> mapScope;
  final Map<String, List<WorkingUnitModel>> mapWorkChild;
  final Map<String, int> numberOfSubtask;
  final MainTabCubit cubitMT;
  final Function(String) getDataWorkChild;
  final Function(WorkingUnitModel) updateListTask;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    final mapUser = ConfigsCubit.fromContext(context).usersMap;
    return BlocProvider(
      create: (context) =>
          TaskMainPageCubit(ConfigsCubit.fromContext(context))..initData(context, listWork, sorted),
      child: BlocBuilder<TaskMainPageCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<TaskMainPageCubit>(c);
          if (s == 0) {
            return Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorConfig.whiteBackground,
                child: const LoadingWidget());
          }
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: ColorConfig.whiteBackground,
            child: Padding(
              padding: EdgeInsets.all(ScaleUtils.scaleSize(0, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderAndOptionTaskPageView(
                      cubit: cubit, user: user, mapScope: mapScope),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(25, context)),
                    child: const HeaderPersonalTaskWidget(isInTask: true),
                  ),
                  const ZSpace(h: 9),
                  Expanded(
                    child: DragTaskWidget(
                        key: ValueKey(cubit.listShow),
                        position: DragIconPosition.left,
                        changeOrder: (a, b) {
                          cubit.changeOrder(a, b);
                        },
                        children: [
                          ...cubit.listShow.map((item) => TaskWidgetInTaskPage(
                              cubitMT: cubitMT,
                              mapAddress: mapAddress,
                              numberOfSubtask: numberOfSubtask,
                              mapScope: mapScope,
                              getDataWorkChild: getDataWorkChild,
                              mapWorkChild: mapWorkChild,
                              mapUser: mapUser,
                              listScope: listScope,
                              item: item,
                              cubit: cubit,
                              updateListTask: updateListTask)),
                        ]),
                  ),
                  if (cubit.loadingTaskClosed > 0 &&
                      cubit.filterStatusClosed == AppText.textClosed.text)
                    const Center(
                      child: CircularProgressIndicator(
                        color: ColorConfig.primary3,
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
