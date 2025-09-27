import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/screens/home_screens.dart';
import 'package:whms/features/home/main_tab/screens/main_tab.dart';
import 'package:whms/features/login/screens/change_password_screen.dart';
import 'package:whms/features/login/screens/login_screens.dart';
import 'package:whms/features/manager/screens/manager_home_screens.dart';
import 'package:whms/features/manager/screens/profile_screens.dart';
import 'package:whms/features/page_not_found/page_not_found_screen.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/widgets/page_check.dart';

class SetupGoRouter {
  static List<GoRoute> createRoutes() {
    return [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: PageCheck(url: AppRoutes.login, screen: const LoginScreen()),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.managerHome,
        redirect: (context, state) {
          return AppRoutes.managerPersonnel;
        },
      ),
      GoRoute(
        path: AppRoutes.managerPersonnel,
        pageBuilder: (context, state) {
          final role = BlocProvider.of<ConfigsCubit>(context).role;

          return CustomTransitionPage(
            child: PageCheck(
              url: AppRoutes.managerPersonnel,
              screen: 0 <= role && role < 30
                  ? const ManagerHomeScreen(tab: AppRoutes.managerPersonnel)
                  : const PageNotFoundScreen(),
            ),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.managerScope,
        pageBuilder: (context, state) {
          final role = BlocProvider.of<ConfigsCubit>(context).role;

          return CustomTransitionPage(
            child: PageCheck(
              url: AppRoutes.managerScope,
              screen: 0 <= role && role < 30
                  ? const ManagerHomeScreen(tab: AppRoutes.managerScope)
                  : const PageNotFoundScreen(),
            ),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),
      // GoRoute(
      //   path: AppRoutes.managerProcedure,
      //   pageBuilder: (context, state) {
      //     final role = BlocProvider.of<ConfigsCubit>(context).role;
      //
      //     return CustomTransitionPage(
      //         child: PageCheck(
      //           url: AppRoutes.managerProcedure,
      //           screen: 0 <= role && role < 30
      //               ? const ManagerHomeScreen(tab: AppRoutes.managerProcedure)
      //               : const PageNotFoundScreen(),
      //         ),
      //         transitionsBuilder: fadeTransitionBuilder);
      //   },
      // ),
      GoRoute(
        path: AppRoutes.profileId,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return CustomTransitionPage(
            child: PageCheck(
              url: AppRoutes.profileId,
              screen: ProfileScreen(idUser: id!),
            ),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: PageCheck(
              url: AppRoutes.changePassword,
              screen: const ChangePasswordScreen(),
            ),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) {
          return '${AppRoutes.home}/mainTab/1';
        },
      ),
      GoRoute(
        path: "${AppRoutes.home}/mainTab",
        redirect: (context, state) {
          return '${AppRoutes.home}/mainTab/1';
        },
      ),
      GoRoute(
        path: '${AppRoutes.home}/mainTab/:tab',
        pageBuilder: (context, state) {
          final tab = state.pathParameters['tab'] ?? '1';
          final cfC = ConfigsCubit.fromContext(context);
          cfC.getDataWorkingUnitNewest(cfC.user.id);
          cfC.getWorkShiftByUser(cfC.user.id, DateTimeUtils.getCurrentDate());
          if (tab == '2') {
            cfC.getDataWorkingUnitClosedNewest(cfC.user.id);
          }
          cfC.saveSaveTab(
            cfC.keySaveTabMainTab,
            "${AppRoutes.home}/mainTab/$tab",
          );
          return CustomTransitionPage(
            child: PageCheck(
              url: '/home/$tab',
              screen: MainTab(tab: tab), // Hàm trả về widget theo tab
            ),
            transitionsBuilder: fadeTransitionBuilder,
          );
        },
      ),
    ];
  }

  static Widget fadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeIn;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    final opacity = tween.animate(
      CurvedAnimation(parent: animation, curve: curve),
    );
    return FadeTransition(opacity: opacity, child: child);
  }
}
