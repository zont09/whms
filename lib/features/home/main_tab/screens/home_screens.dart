import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/main_tab/widgets/my_appbar.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigsCubit, ConfigsState>(
      builder: (c, s) {
        final checkIn = BlocProvider.of<ConfigsCubit>(c).isCheckIn;
        return Scaffold(
          appBar: MyAppbar(
              height: ScaleUtils.scaleSize(60, context),
              title: "",
          isHome: true,
          tab: 1,),
          body: Row(
            children: [

              Expanded(
                  flex: 8,
                  child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: checkIn == StatusCheckInDefine.notCheckIn
                          ? Text(
                        AppText.titlePleaseCheckIn.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(35, context),
                            fontWeight: FontWeight.w700,
                            color: ColorConfig.primary1),
                      )
                          : (checkIn == StatusCheckInDefine.breakTime
                          ? Text(
                        AppText.textPleaseResume.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(35, context),
                            fontWeight: FontWeight.w700,
                            color: ColorConfig.primary1),
                      )
                          :
                      Text(
                        AppText.titleHandlerRole.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(35, context),
                            fontWeight: FontWeight.w700,
                            color: ColorConfig.primary1),
                      )
                      )
                  ))
            ],
          ),
          // bottomNavigationBar: Container(
          //   padding: EdgeInsets.symmetric(
          //       horizontal: ScaleUtils.scaleSize(9, context),
          //       vertical: ScaleUtils.scaleSize(9, context)),
          //   decoration: BoxDecoration(color: Colors.white, boxShadow: [
          //     BoxShadow(
          //         blurRadius: 4,
          //         color: ColorConfig.shadow,
          //         offset: const Offset(0, -2))
          //   ]),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 173,
          //         child: BottomButton(
          //             title: AppText.btnOKRS.text,
          //             icon: 'assets/images/icons/ic_okr.png',
          //             onPressed: () {}),
          //       ),
          //       SizedBox(width: ScaleUtils.scaleSize(8, context)),
          //       Expanded(
          //         flex: 352,
          //         child: BottomButton(
          //             title: AppText.btnImprovementProblem.text,
          //             icon: 'assets/images/icons/ic_problem.png',
          //             onPressed: () {}),
          //       ),
          //       SizedBox(width: ScaleUtils.scaleSize(8, context)),
          //       Expanded(
          //         flex: 643,
          //         child: BottomButton(
          //             title: AppText.btnCheckIn.text,
          //             icon: 'assets/images/icons/ic_checkin.png',
          //             onPressed: () async {
          //               CheckInDialog.showCheckInDialog(context);
          //             }),
          //       ),
          //       SizedBox(width: ScaleUtils.scaleSize(8, context)),
          //       BottomButton(
          //           title: "",
          //           icon: 'assets/images/icons/ic_notification.png',
          //           mainColor: null,
          //           onPressed: () {}),
          //       SizedBox(width: ScaleUtils.scaleSize(8, context)),
          //       Expanded(
          //         flex: 148,
          //         child: BottomButton(
          //             title: AppText.btnProfile.text,
          //             icon: 'assets/images/icons/ic_profile.png',
          //             onPressed: () {}),
          //       ),
          //     ],
          //   ),
          // ),
        );
      },
    );
  }
}


