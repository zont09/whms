import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/header_and_option_task_page_view.dart';
import 'package:whms/features/home/main_tab/views/task/header_list_task_view.dart';
import 'package:whms/features/home/main_tab/views/task/task_main_view.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/shimmer_loading.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class LoadingTaskMainView extends StatelessWidget {
  const LoadingTaskMainView(
      {super.key,
        required this.s,
        required this.widget,
        required this.cfC,
        required this.cubit});

  final int s;
  final TaskMainView widget;
  final ConfigsCubit cfC;
  final TaskMainViewCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (widget.tab == "2") {
      return Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        // padding: EdgeInsets.only(
        //     // top: ScaleUtils.scaleSize(20, context),
        //     // left: ScaleUtils.scaleSize(20, context),
        //     bottom: ScaleUtils.scaleSize(20, context),
        //     right: ScaleUtils.scaleSize(20, context)),
        child: Column(
          children: [
            HeaderAndOptionTaskPageView(
                cubit: null, user: cfC.user, mapScope: cfC.allScopeMap),
            const ZSpace(h: 20),
            ...List.generate(
                3,
                    (_) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(20, context)),
                      child: Column(
                                        children: [
                      ShimmerLoading(
                        height: 40,
                        radius: 8,
                      ),
                      const ZSpace(h: 12)
                                        ],
                                      ),
                    ))
          ],
        ),
      );
    }
    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.only(
          top: ScaleUtils.scaleSize(20, context),
          left: ScaleUtils.scaleSize(20, context),
          bottom: ScaleUtils.scaleSize(20, context),
          right: ScaleUtils.scaleSize(20, context)),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  HeaderListTaskView(
                    cubit: cubit,
                    tab: widget.tab,
                    cubitMT: widget.cubitTM,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(12, context)),
                  ...List.generate(
                      3,
                          (_) => const Column(
                        children: [
                          ShimmerLoading(
                              height: 80, radius: 8, isShadow: true),
                          const ZSpace(h: 12)
                        ],
                      ))
                ],
              )),
          const ZSpace(w: 20),
          const Expanded(
              flex: 3, child: ShimmerLoading(radius: 14, isShadow: true)),
        ],
      ),
    );
  }
}