import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/app_bar_item.dart';

class AppbarManager extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final int tab;

  const AppbarManager({required this.height, this.tab = 4, super.key});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: ScaleUtils.scaleSize(height, context),
      // shadowColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_manager.png'),
            // Ảnh từ assets
            fit: BoxFit.cover, // Phủ kín AppBar
          ),
        ),
      ),
      // flexibleSpace: Container(
      //   color: Colors.transparent,
      // ),
      centerTitle: true,
      title: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(60, context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo/pls_white.png',
                height: ScaleUtils.scaleSize(45, context)),
            const Spacer(),
            Padding(
              padding:
                  EdgeInsets.only(right: ScaleUtils.scalePadding(30, context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppBarItem(
                    icon: 'assets/images/icons/ic_tab_staffs.png',
                    title: AppText.txtListStaff.text,
                    tab: 1,
                    curTab: tab,
                    onTap: () {
                      context.go(AppRoutes.managerPersonnel);
                    },
                  ),
                  SizedBox(width: ScaleUtils.scaleSize(24, context)),
                  AppBarItem(
                    icon: 'assets/images/icons/ic_tab_scopes.png',
                    title: AppText.txtListScope.text,
                    tab: 2,
                    curTab: tab,
                    onTap: () {
                      context.go(AppRoutes.managerScope);
                    },
                  ),
                  // SizedBox(width: ScaleUtils.scaleSize(24, context)),
                  // AppBarItem(
                  //   icon: 'assets/images/icons/ic_okr.png',
                  //   title: AppText.titleOKR.text,
                  //   tab: 5,
                  //   curTab: tab,
                  //   onTap: () {},
                  // ),
                  // SizedBox(width: ScaleUtils.scaleSize(24, context)),
                  // CustomButton(
                  //     title: AppText.titleCheckIn.text,
                  //     icon: 'assets/images/icons/ic_check_in.png',
                  //     colorBackground: ColorConfig.primary2,
                  //     colorBorder: ColorConfig.primary2,
                  //     colorTitle: Colors.white,
                  //     colorIcon: Colors.white,
                  //     sizeTitle: 14,
                  //     sizeIcon: 24,
                  //     fontWeight: FontWeight.w400,
                  //     paddingVer: 6,
                  //     paddingHor: 8,
                  //     onPressed: () async {
                  //       CheckInDialog.showCheckInDialog(context);
                  //     }),
                  // SizedBox(width: ScaleUtils.scaleSize(18, context)),
                  // const UserProfileWidget(),
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
      ),
      elevation: 8,
    );
  }
}
