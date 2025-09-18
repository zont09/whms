import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/views/check_in_dialog.dart';
import 'package:whms/features/home/main_tab/widgets/user_profile_widget.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/app_bar_item.dart';
import 'package:whms/widgets/custom_button.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final bool isHome;
  final int tab;

  const MyAppbar(
      {required this.height,
      required this.title,
      this.isHome = false,
      this.tab = 0,
      super.key});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: ScaleUtils.scaleSize(80, context),
      // shadowColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      // flexibleSpace: Container(
      //   color: Colors.transparent,
      // ),
      centerTitle: true,
      title: Row(
        children: [
          Container(
            alignment: Alignment.center,
            padding:
                EdgeInsets.only(left: ScaleUtils.scalePadding(30, context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo/pls.png',
                    height: ScaleUtils.scaleSize(55, context)),
                if (!isHome)
                  SizedBox(width: ScaleUtils.scalePadding(20, context)),
                if (!isHome)
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                        color: ColorConfig.redTitle,
                        fontFamily: 'Afacad',
                        fontSize: ScaleUtils.scaleSize(28, context),
                        fontWeight: FontWeight.w700),
                  )
              ],
            ),
          ),
          const Spacer(),
          if (isHome)
            Padding(
              padding:
                  EdgeInsets.only(right: ScaleUtils.scalePadding(30, context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppBarItem(
                        icon: 'assets/images/icons/ic_main_tab.png',
                        title: AppText.titleMainTab.text,
                        tab: 1,
                        curTab: tab,
                        onTap: () {
                          context.go(AppRoutes.mainTab);
                        },
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(24, context)),
                      AppBarItem(
                        icon: 'assets/images/icons/ic_overview.png',
                        title: AppText.titleOverview.text,
                        tab: 2,
                        curTab: tab,
                        onTap: () {
                          context.go(AppRoutes.overview);
                        },
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(24, context)),
                      AppBarItem(
                        icon: 'assets/images/icons/ic_manager.png',
                        title: AppText.titleManager.text,
                        tab: 3,
                        curTab: tab,
                        onTap: () {
                          // context.go(AppRoutes.manager);
                          // context.go(
                          //     '${AppRoutes.manager}/${ConfigsCubit.localScopeId.isEmpty ? '0' : ConfigsCubit.localScopeId}&001000000');
                        },
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(24, context)),
                      AppBarItem(
                        icon: 'assets/images/icons/ic_report.png',
                        title: AppText.titleReport.text,
                        tab: 4,
                        curTab: tab,
                        onTap: () {
                          context.go(AppRoutes.report);
                        },
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(24, context)),
                      AppBarItem(
                        icon: 'assets/images/icons/ic_okr.png',
                        title: AppText.titleOKR.text,
                        tab: 5,
                        curTab: tab,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(width: ScaleUtils.scaleSize(24, context)),
                  ZButton(
                      title: AppText.titleCheckIn.text,
                      icon: 'assets/images/icons/ic_check_in.png',
                      colorBackground: ColorConfig.primary2,
                      colorBorder: ColorConfig.primary2,
                      colorTitle: Colors.white,
                      colorIcon: Colors.white,
                      sizeTitle: 14,
                      sizeIcon: 24,
                      fontWeight: FontWeight.w400,
                      paddingVer: 6,
                      paddingHor: 8,
                      onPressed: () async {
                        CheckInDialog.showCheckInDialog(context);
                      }),
                  SizedBox(width: ScaleUtils.scaleSize(18, context)),
                  const UserProfileWidget(),
                  // SizedBox(width: ScaleUtils.scaleSize(18, context)),
                  // const AppbarNotification(),
                ],
              ),
            )

          // Container(
          //   width: 500,
          //   alignment: Alignment.centerRight,
          //   margin: EdgeInsets.only(
          //       top: ScaleUtils.scalePadding(20, context),
          //       right: ScaleUtils.scalePadding(80, context)),
          //   child: Row(
          //     children: [
          //       const Spacer(),
          //       TabButton(
          //           isActive: true,
          //           onPressed: () {},
          //           title: AppText.txtListStaff.text,
          //           icon: 'ic_tab_staffs'),
          //       SizedBox(width: ScaleUtils.scalePadding(15, context)),
          //       TabButton(
          //           isActive: false,
          //           onPressed: () {},
          //           title: AppText.txtListScope.text,
          //           icon: 'ic_tab_scopes'),
          //     ],
          //   ),
          // ),
        ],
      ),
      elevation: 8,
    );
  }
}
