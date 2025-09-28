import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/views/check_in_dialog.dart';
import 'package:whms/features/home/main_tab/widgets/user_profile_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/app_bar/tab_button_view.dart';
import 'package:whms/widgets/custom_button.dart';

class NewAppBar extends StatelessWidget {
  const NewAppBar({super.key, required this.isHome, required this.tab});

  final bool isHome;
  final int tab;

  @override
  Widget build(BuildContext context) {
    var configsCubit = context.read<ConfigsCubit>();
    return Container(
      height: ScaleUtils.scaleSize(60, context),
      color: ColorConfig.primary3,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                left: ScaleUtils.scalePadding(30, context),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo/logo_white.png',
                    height: ScaleUtils.scaleSize(70, context),
                  ),
                ],
              ),
            ),
          ),
          if (isHome)
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(
                  right: ScaleUtils.scalePadding(30, context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TabButtonView(tab: tab),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocBuilder<ConfigsCubit, ConfigsState>(
                          builder: (cc, ss) {
                            final checkIn = ConfigsCubit.fromContext(
                              cc,
                            ).isCheckIn;
                            return SizedBox(
                              height: ScaleUtils.scaleSize(36, context),
                              child: ZButton(
                                title:
                                    checkIn == StatusCheckInDefine.notCheckIn ||
                                        checkIn == StatusCheckInDefine.checkOut
                                    ? AppText.titleCheckIn.text
                                    : (checkIn == StatusCheckInDefine.breakTime
                                          ? AppText.titleResume.text
                                          : AppText.titleCheckOut.text),
                                // icon: 'assets/images/icons/ic_check_in.png',
                                colorBackground:
                                    checkIn == StatusCheckInDefine.checkOut
                                    ? ColorConfig.border4
                                    : Colors.white,
                                colorBorder:
                                    checkIn == StatusCheckInDefine.checkOut
                                    ? ColorConfig.border4
                                    : Colors.white,
                                colorTitle:
                                    checkIn == StatusCheckInDefine.checkOut
                                    ? Colors.white
                                    : ColorConfig.primary1,
                                colorIcon:
                                    checkIn == StatusCheckInDefine.checkOut
                                    ? Colors.white
                                    : ColorConfig.primary1,
                                sizeTitle: 14,
                                sizeIcon: 24,
                                fontWeight: FontWeight.w400,
                                paddingVer: 6,
                                paddingHor: 20,
                                isShadow: true,
                                onPressed: () async {
                                  // await configsCubit.getConfiguration();
                                  if (context.mounted) {
                                    CheckInDialog.showCheckInDialog(context);
                                  }
                                  // configsCubit.getDataWorkingUnitNewest();
                                  // showAddTaskDialog(context);
                                  // showTaskDialog(context);
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(width: ScaleUtils.scaleSize(18, context)),
                        const UserProfileWidget(),
                        SizedBox(width: ScaleUtils.scaleSize(40, context)),
                        // const AppbarNotification(),
                        // SizedBox(width: ScaleUtils.scaleSize(20, context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
