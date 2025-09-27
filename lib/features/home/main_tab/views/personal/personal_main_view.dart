import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/views/personal/document_and_announce_view.dart';
import 'package:whms/features/home/main_tab/views/personal/history_personal_view/history_personal_view.dart';
import 'package:whms/features/home/main_tab/views/personal/personal_sub_view_1.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/loading_widget.dart';

class PersonalMainView extends StatelessWidget {
  const PersonalMainView({super.key, required this.cubitMT});

  final MainTabCubit cubitMT;

  @override
  Widget build(BuildContext context) {
    if (cubitMT.state == 0) {
      return Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: const LoadingWidget(),
      );
    }
    bool isEmptyAll = cubitMT.listAssign.isEmpty &&
        cubitMT.listPersonal.isEmpty &&
        cubitMT.listToday.isEmpty &&
        cubitMT.listTop.isEmpty;
    return Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (c, con) => Stack(
            children: [
              ScrollConfiguration(
                behavior: InvisibleScrollBarWidget(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 17,
                        child: !isEmptyAll
                            ? SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      ScaleUtils.scaleSize(20, context)),
                                  child: Column(
                                    children: [
                                      const HistoryPersonalView(),
                                      if (cubitMT.listToday.isNotEmpty)
                                        PersonalSubView1(
                                          cubitMT: cubitMT,
                                          tab: "201",
                                          title: AppText.titleToday.text,
                                          iconTitle:
                                              'assets/images/icons/tab_bar/ic_tab_today.png',
                                          items: cubitMT.listToday,
                                          onTapMoreView: () {
                                            context
                                                .go('${AppRoutes.mainTab}/201');
                                          },
                                        ),
                                      if (cubitMT.listDoing.isNotEmpty)
                                        SizedBox(
                                            height: ScaleUtils.scaleSize(
                                                30, context)),
                                      if (cubitMT.listDoing.isNotEmpty)
                                        PersonalSubView1(
                                            cubitMT: cubitMT,
                                            tab: "204",
                                            title: AppText.titleDoing.text,
                                            iconTitle:
                                                'assets/images/icons/ic_doing.png',
                                            items: cubitMT.listDoing,
                                            onTapMoreView: () {
                                              context
                                                  .go('${AppRoutes.mainTab}/206');
                                            }),
                                      if (cubitMT.listTop.isNotEmpty)
                                        SizedBox(
                                            height: ScaleUtils.scaleSize(
                                                30, context)),
                                      if (cubitMT.listTop.isNotEmpty)
                                        PersonalSubView1(
                                            cubitMT: cubitMT,
                                            tab: "202",
                                            title: AppText.textTop.text,
                                            iconTitle:
                                                'assets/images/icons/tab_bar/ic_tab_task_hot.png',
                                            items: cubitMT.listTop,
                                            onTapMoreView: () {
                                              context
                                                  .go('${AppRoutes.mainTab}/202');
                                            }),
                                      if (cubitMT.listUrgent.isNotEmpty)
                                        SizedBox(
                                            height: ScaleUtils.scaleSize(
                                                30, context)),
                                      if (cubitMT.listUrgent.isNotEmpty)
                                        PersonalSubView1(
                                            cubitMT: cubitMT,
                                            tab: "204",
                                            title: AppText.titleUrgent.text,
                                            iconTitle:
                                                'assets/images/icons/ic_urgent_date.png',
                                            items: cubitMT.listUrgent,
                                            onTapMoreView: () {
                                              context
                                                  .go('${AppRoutes.mainTab}/205');
                                            }),
                                      if (cubitMT.listTop.isNotEmpty)
                                        SizedBox(
                                            height: ScaleUtils.scaleSize(
                                                30, context)),
                                      if (cubitMT.listPersonal.isNotEmpty)
                                        PersonalSubView1(
                                            cubitMT: cubitMT,
                                            tab: "203",
                                            title: AppText.textTaskPersonal.text,
                                            iconTitle:
                                                'assets/images/icons/tab_bar/ic_tab_personal.png',
                                            items: cubitMT.listPersonal,
                                            onTapMoreView: () {
                                              context
                                                  .go('${AppRoutes.mainTab}/203');
                                            }),
                                      if (cubitMT.listPersonal.isNotEmpty)
                                        SizedBox(
                                            height: ScaleUtils.scaleSize(
                                                30, context)),
                                      if (cubitMT.listAssign.isNotEmpty)
                                        PersonalSubView1(
                                            cubitMT: cubitMT,
                                            tab: "204",
                                            title: AppText.textTaskAssign.text,
                                            iconTitle:
                                                'assets/images/icons/tab_bar/ic_tab_task_assign.png',
                                            items: cubitMT.listAssign,
                                            onTapMoreView: () {
                                              context
                                                  .go('${AppRoutes.mainTab}/204');
                                            }),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      ScaleUtils.scaleSize(20, context)),
                                  child: Column(
                                    children: [
                                      const HistoryPersonalView(),
                                      SizedBox(
                                          height:
                                              ScaleUtils.scaleSize(30, context)),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/img_no_task_all.png',
                                            height: ScaleUtils.scaleSize(
                                                211, context),
                                          ),
                                          SizedBox(
                                              height: ScaleUtils.scaleSize(
                                                  20, context)),
                                          Text(
                                            AppText.textNoTaskAll.text,
                                            style: TextStyle(
                                                fontSize: ScaleUtils.scaleSize(
                                                    22, context),
                                                fontWeight: FontWeight.w700,
                                                color: ColorConfig.primary3),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            AppText.textNoTaskAllDes.text,
                                            style: TextStyle(
                                                fontSize: ScaleUtils.scaleSize(
                                                    18, context),
                                                fontWeight: FontWeight.w400,
                                                color: ColorConfig.primary3),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                    Expanded(
                        flex: 10,
                        child: DocumentAndAnnounceView(
                          cubit: cubitMT,
                        )),
                    SizedBox(
                      width: ScaleUtils.scaleSize(30, context),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
