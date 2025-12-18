import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/configs/reload_cubit.dart';
import 'package:whms/features/page_not_found/page_not_found_screen.dart';
import 'package:whms/features/splash/screen/splash_screen.dart';
import 'package:whms/setup_routes.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<ConfigsCubit>(ConfigsCubit()..init());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCk3K4gHqEFYLW_f26odRQAntLgXb9IY6U",
            authDomain: "whms-c56d3.firebaseapp.com",
            projectId: "whms-c56d3",
            storageBucket: "whms-c56d3.firebasestorage.app",
            messagingSenderId: "645643175310",
            appId: "1:645643175310:web:5838ea5319dd6fb74290df",
            measurementId: "G-JP4S2M3DD3"));
  } catch (e) {
    print("===> bug: $e");
  }
  // final workingUnit = await WorkingService.instance.getAllWorkingUnitIgnoreEnable();
  // for(var work in workingUnit) {
  //   await WorkingService.instance.updateWorkingUnit(work.copyWith(closed: false));
  // }
  // await giaiCuuFTF();
  // await bangVang();
  // await danhSachTamLongVang();
  // await giaiCuuScopeSubtask();
  // await danhSachTamLongKimCuong();
  setupDependencies();
  // runApp(MyApp());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    // initialLocation: AppRoutes.login,
    routes: SetupGoRouter.createRoutes(),
    errorBuilder: (context, state) {
      return const PageNotFoundScreen();
    },
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ConfigsCubit()..init()),
          BlocProvider(create: (context) => ReloadCubit())
        ],
        child: BlocBuilder<ConfigsCubit, ConfigsState>(
          builder: (cc, ss) {
            if (!ConfigsCubit.fromContext(cc).doneInitData) {
              return const SplashScreen();
            }
            // giaiCuuScopeSubtask();
            return CalendarControllerProvider(
              controller: EventController(),
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  ...GlobalMaterialLocalizations.delegates, // Có sẵn
                  FlutterQuillLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('vi', 'VN'),
                ],
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.mouse
                    }),
                title: 'WHMS',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
                  useMaterial3: true,
                  fontFamily: 'Afacad',
                ),
                routerConfig: _router,
              ),
            );
          },
        ));
  }
}