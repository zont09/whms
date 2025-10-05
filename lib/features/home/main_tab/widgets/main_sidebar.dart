import 'package:whms/features/home/main_tab/widgets/main_sidebar_item.dart';
import 'package:whms/features/home/main_tab/widgets/menu_item.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainSidebar extends StatelessWidget {
  const MainSidebar({super.key, required this.curTab, required this.cubit});

  final String curTab;
  final MainTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        color: Colors.transparent,
        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(9, context)),
        child: ListView(children: [
          MenuItem(
              icon: 'assets/images/icons/tab_bar/ic_tab_personal.png',
              title: AppText.titlePersonal.text,
              tab: "1",
              curTab: curTab,
              onTap: () {
                if (curTab != "1") {
                  context.go('${AppRoutes.mainTab}/1');
                }
              },
              children: const []),
          MenuItem(
              icon: 'assets/images/icons/tab_bar/ic_tab_task.png',
              title: AppText.titleTask.text,
              onTap: () {
                if (curTab == "2") return;
                context.go('${AppRoutes.mainTab}/2');
              },
              tab: "2",
              curTab: curTab,
              children: [
                MainSidebarItem(
                    onTap: () {
                      if (curTab == "201") return;
                      context.go('${AppRoutes.mainTab}/201');
                    },
                    isActive: curTab == "201",
                    iconSize: 20,
                    titleSize: 12,
                    icon: 'assets/images/icons/tab_bar/ic_tab_today.png',
                    title: AppText.titleDoing.text,
                    numQuest: cubit.taskToday),
                // MainSidebarItem(
                //     onTap: () {
                //       if (curTab == "206") return;
                //       context.go('${AppRoutes.mainTab}/206');
                //     },
                //     isActive: curTab == "206",
                //     iconSize: 20,
                //     titleSize: 12,
                //     icon: 'assets/images/icons/ic_doing.png',
                //     title: AppText.titleDoing.text,
                //     numQuest: cubit.taskDoing),
                MainSidebarItem(
                    onTap: () {
                      if (curTab == "202") return;
                      context.go('${AppRoutes.mainTab}/202');
                    },
                    isActive: curTab == "202",
                    iconSize: 20,
                    titleSize: 12,
                    icon: 'assets/images/icons/tab_bar/ic_tab_task_hot.png',
                    title: AppText.textTop.text,
                    numQuest: cubit.taskTop),
                MainSidebarItem(
                    onTap: () {
                      if (curTab == "205") return;
                      context.go('${AppRoutes.mainTab}/205');
                    },
                    isActive: curTab == "205",
                    iconSize: 20,
                    titleSize: 12,
                    icon: 'assets/images/icons/ic_urgent_date.png',
                    title: AppText.titleUrgent.text,
                    numQuest: cubit.taskUrgent),
                MainSidebarItem(
                    onTap: () {
                      if (curTab == "203") return;
                      context.go('${AppRoutes.mainTab}/203');
                    },
                    isActive: curTab == "203",
                    iconSize: 20,
                    titleSize: 12,
                    icon: 'assets/images/icons/tab_bar/ic_tab_task_personal.png',
                    title: AppText.textTaskPersonal.text,
                    numQuest: cubit.taskPersonal),
                // MainSidebarItem(
                //     onTap: () {
                //       if (curTab == "207") return;
                //       context.go('${AppRoutes.mainTab}/207');
                //     },
                //     isActive: curTab == "207",
                //     iconSize: 20,
                //     titleSize: 12,
                //     icon:
                //         'assets/images/icons/tab_bar/ic_task_follower.png',
                //     title: AppText.textTaskFollowing.text,
                //     numQuest: cubit.taskFollowing),
                MainSidebarItem(
                    onTap: () {
                      if (curTab == "204") return;
                      context.go('${AppRoutes.mainTab}/204');
                    },
                    isActive: curTab == "204",
                    iconSize: 20,
                    titleSize: 12,
                    icon: 'assets/images/icons/tab_bar/ic_tab_task_assign.png',
                    title: AppText.textTaskAssign.text,
                    numQuest: cubit.taskAssign)
              ]),
          MenuItem(
              icon: 'assets/images/icons/tab_bar/ic_tab_note.png',
              title: AppText.titleNote.text,
              onTap: () {
                if (curTab == "3") return;
                context.go('${AppRoutes.mainTab}/3');
              },
              tab: "3",
              curTab: curTab,
              children: [
                ...cubit.listUserScope.where((e) => e.id != "personal").map(
                      (e) => MenuItem(
                          onTap: () {
                            if (curTab == "3&scp=${e.id}") return;
                            context.go('${AppRoutes.mainTab}/3&scp=${e.id}');
                          },
                          curTab: curTab,
                          tab: "3&scp=${e.id}",
                          iconSize: 20,
                          fontSize: 15,
                          icon: 'assets/images/icons/tab_bar/ic_tab_scope.png',
                          title: e.title,
                          numQuest: -1,
                          children: [
                            if (cubit.mapProjectInScope[e.id] != null)
                              ...cubit.mapProjectInScope[e.id]!
                                  .map((p) => MenuItem(
                                      onTap: () {
                                        if (curTab ==
                                            "3&scp=${e.id}&prj=${p.id}") return;
                                        context.go(
                                            '${AppRoutes.mainTab}/3&scp=${e.id}&prj=${p.id}');
                                      },
                                      curTab: curTab,
                                      tab: "3&scp=${e.id}&prj=${p.id}",
                                      iconSize: 20,
                                      fontSize: 15,
                                      icon: 'assets/images/icons/ic_epic.png',
                                      title: p.title,
                                      children: const [],
                                      numQuest: -1)),
                          ]),
                    ),
                MenuItem(
                    onTap: () {
                      if (curTab == "3&scp=personal") return;
                      context.go('${AppRoutes.mainTab}/3&scp=personal');
                    },
                    curTab: curTab,
                    tab: "3&scp=personal",
                    iconSize: 20,
                    fontSize: 15,
                    icon:
                        'assets/images/icons/tab_bar/ic_tab_note_personal.png',
                    title: AppText.titlePersonal.text,
                    numQuest: -1,
                    children: const []),
                // MainSidebarItem(
                //     onTap: () {
                //       if (curTab == "3&scp=personal") return;
                //       context.go('${AppRoutes.mainTab}/3&scp=personal');
                //     },
                //     isActive: curTab == "3&scp=personal",
                //     iconSize: 20,
                //     titleSize: 12,
                //     icon:
                //         'assets/images/icons/tab_bar/ic_tab_note_personal.png',
                //     title: AppText.titlePersonal.text,
                //     numQuest: -1)
              ]),
          MenuItem(
              icon: 'assets/images/icons/tab_bar/ic_tab_meeting.png',
              title: AppText.titleMeetings.text,
              onTap: () {
                if (curTab == "4") return;
                context.go('${AppRoutes.mainTab}/4');
              },
              tab: "4",
              curTab: curTab,
              children: []),
          MenuItem(
              icon: 'assets/images/icons/ic_okr.png',
              title: AppText.titleOKR.text,
              tab: "5",
              curTab: curTab,
              onTap: () {
                if (curTab != "5") {
                  context.go('${AppRoutes.mainTab}/5');
                }
              },
              children: const []),
          SizedBox(height: ScaleUtils.scaleSize(20, context)),
          // const IssueReportButton()
        ]));
  }
}
