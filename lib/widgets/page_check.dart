import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/login/screens/change_password_screen.dart';
import 'package:whms/features/login/screens/login_screens.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_routes.dart';

class PageCheck extends StatefulWidget {
  final String url;
  final dynamic screen;

  const PageCheck({super.key, required this.url, required this.screen});

  @override
  State<PageCheck> createState() => _PageCheckState();
}

class _PageCheckState extends State<PageCheck> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser;
    final mustChangePassword =
        ConfigsCubit.fromContext(context).user.mustChangePassword;
    final user = ConfigsCubit.fromContext(context).user;
    if (isLoggedIn == null) {
      if (widget.url == AppRoutes.login) {
        return const LoginScreen();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.login);
        });
        return const SizedBox.shrink();
      }
    } if(widget.url == AppRoutes.login) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(mustChangePassword) {
          await UserServices.instance.logout(context);
          return;
        }
        debugPrint("====> user.roles: ${user.name} - ${user.roles}");
        if(user.roles == -229) {
          context.go(AppRoutes.linktink);
        } else
        if(user.roles <= 20) {
          context.go(AppRoutes.managerHome);
        }
        else {
          context.go(AppRoutes.mainTab);
        }
      });
      if(mustChangePassword) {
        return const LoginScreen();
      }
      return const SizedBox.shrink();
    }
    else if (mustChangePassword) {
      if (widget.url == AppRoutes.changePassword) {
        return const ChangePasswordScreen();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(AppRoutes.changePassword);
        });
        return const SizedBox.shrink();
      }
    } else {
      // if (user.roles > 20) {
      //   if (checkInStatus == StatusCheckInDefine.notCheckIn &&
      //       url != AppRoutes.home) {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       context.go(AppRoutes.home);
      //     });
      //     return const SizedBox.shrink();
      //   }
      //   if (checkInStatus != StatusCheckInDefine.notCheckIn &&
      //       url == AppRoutes.home) {
      //     WidgetsBinding.instance.addPostFrameCallback((_) {
      //       context.go(AppRoutes.mainTab);
      //     });
      //     return const SizedBox.shrink();
      //   }
      // }
      return widget.screen;
    }
  }
}
