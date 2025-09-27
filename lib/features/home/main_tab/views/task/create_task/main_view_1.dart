import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/add_task_tab_view.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/main_view_2.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/text_field_view.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/scope_model.dart';

class MainView1 extends StatelessWidget {
  const MainView1({
    super.key,
    required this.cubit,
    required this.cubitMT,
  });

  final CreateTaskCubit cubit;
  final MainTabCubit cubitMT;

  @override
  Widget build(BuildContext context) {
    final List<ScopeModel> scopes = cubit.workSelected != null
        ? cubit.workSelected!.scopes
            .map((item) => cubitMT.mapScope[item] ?? ScopeModel())
            .toList()
        : [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ScaleUtils.scaleSize(15, context)),
        AddTaskTabView(cubit: cubit),
        SizedBox(height: ScaleUtils.scaleSize(15, context)),
        if (cubit.tab == 1)
          Expanded(child: MainView2(cubit: cubit, cubitMT: cubitMT)),
        if (cubit.tab == 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(AppText.titleLink.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w500,
                          color: ColorConfig.textColor6,
                          letterSpacing: -0.41,
                          shadows: const [ColorConfig.textShadow])),
                  SizedBox(width: ScaleUtils.scaleSize(5, context)),
                  InkWell(
                    onTap: () {
                      cubit.changeTab(2);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFD0D2),
                          borderRadius: BorderRadius.circular(
                              ScaleUtils.scaleSize(12, context))),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(8, context),
                          vertical: ScaleUtils.scaleSize(4, context)),
                      child: Row(
                        children: [
                          if (scopes.isNotEmpty && cubit.workSelected != null)
                            Tooltip(
                                richMessage: TextSpan(
                                  text: scopes[0].title +
                                      (scopes.length > 2 ? '\n' : ''),
                                  style: const TextStyle(color: Colors.white),
                                  children: [
                                    ...scopes.skip(1).map((item) {
                                      final isLast =
                                          item == scopes.skip(1).last;
                                      return TextSpan(
                                          text: item.title +
                                              (isLast ? '' : '\n'));
                                    })
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      ScaleUtils.scaleSize(8, context)),
                                ),
                                child: Text(AppText.titleScope.text,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(13, context),
                                        fontWeight: FontWeight.w600,
                                        color: ColorConfig.primary3))),
                          if (scopes.isEmpty && cubit.workSelected != null)
                            Tooltip(
                                message: AppText.titlePersonal.text,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      ScaleUtils.scaleSize(8, context)),
                                ),
                                child: Text(AppText.titleScope.text,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(13, context),
                                        fontWeight: FontWeight.w600,
                                        color: ColorConfig.primary3))),
                          if (cubit.workSelected != null &&
                              cubitMT.mapAddress[cubit.workSelected!.id]!
                                  .isNotEmpty)
                            Text(" > ",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(13, context),
                                    fontWeight: FontWeight.w600,
                                    color: ColorConfig.primary3)),
                            if (cubit.workSelected == null)
                              Text(AppText.titlePleaseChooseTask.text,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(13, context),
                                      fontWeight: FontWeight.w500,
                                      color: ColorConfig.primary3)),
                          if (cubit.workSelected != null)
                            for (int i = cubitMT
                                        .mapAddress[cubit.workSelected!.id]!
                                        .length -
                                    1;
                                i >= 0;
                                i--)
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Tooltip(
                                        message: cubitMT
                                            .mapAddress[
                                                cubit.workSelected!.id]![i]
                                            .title,
                                        child: Text(
                                            cubitMT
                                                .mapAddress[
                                                    cubit.workSelected!.id]![i]
                                                .type,
                                            style: TextStyle(
                                                fontSize: ScaleUtils.scaleSize(
                                                    13, context),
                                                fontWeight: FontWeight.w500,
                                                color: ColorConfig.primary3))),
                                    if (i > 0)
                                      Text(" > ",
                                          style: TextStyle(
                                              fontSize: ScaleUtils.scaleSize(
                                                  13, context),
                                              fontWeight: FontWeight.w500,
                                              color: ColorConfig.primary3))
                                  ])
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: ScaleUtils.scaleSize(15, context)),
              TextFieldView(cubit: cubit),
            ],
          ),
      ],
    );
  }
}
