import 'package:whms/features/home/main_tab/blocs/meeting/create_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/views/meeting/create_meeting_popup/create_meeting_popup_section1.dart';
import 'package:whms/features/home/main_tab/views/meeting/create_meeting_popup/create_meeting_popup_section2.dart';
import 'package:whms/features/home/main_tab/views/meeting/create_meeting_popup/pick_time.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/dropdown_search_user.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateMeetingPopup extends StatelessWidget {
  const CreateMeetingPopup({super.key, this.onAdd});

  final Function(MeetingModel)? onAdd;

  @override
  Widget build(BuildContext context) {
    final configCubit = ConfigsCubit.fromContext(context);
    return BlocProvider(
      create: (context) => CreateMeetingCubit()
        ..initData(configCubit.user, configCubit.allUsers),
      child: BlocBuilder<CreateMeetingCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CreateMeetingCubit>(c);
          return Container(
            width: ScaleUtils.scaleSize(765, context),
            height: MediaQuery.of(context).size.height * 7 / 8,
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(50, context),
                vertical: ScaleUtils.scaleSize(25, context)),
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: InvisibleScrollBarWidget(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CreateMeetingPopupSection1(
                              cubit: cubit, configCubit: configCubit),
                          const ZSpace(h: 9),
                          Text(AppText.textOwnerMeeting.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(16, context),
                                  fontWeight: FontWeight.w400,
                                  color: ColorConfig.textColor6,
                                  letterSpacing: -0.41,
                                  height: 1.5)),
                          const ZSpace(h: 5),
                          DropdownSearchUser(
                              onChanged: (v) {
                                cubit.changeOwner(v!);
                              },
                              initItem: cubit.ownerMeeting,
                              options: configCubit.allUsers
                                  .where((e) => e.roles > 20)
                                  .toList()),
                          const ZSpace(h: 9),
                          CreateMeetingPopupPickTime(cubit: cubit),
                          const ZSpace(h: 9),
                          CreateMeetingPopupSection2(
                            cubit: cubit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const ZSpace(h: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ZButton(
                        title: AppText.btnCancel.text,
                        icon: "",
                        sizeTitle: 18,
                        fontWeight: FontWeight.w600,
                        colorTitle: ColorConfig.primary2,
                        colorBackground: Colors.white,
                        colorBorder: Colors.white,
                        paddingHor: 20,
                        paddingVer: 4,
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    const ZSpace(w: 6),
                    ZButton(
                        title: AppText.btnCreateMeeting.text,
                        icon: "",
                        sizeTitle: 18,
                        fontWeight: FontWeight.w600,
                        colorTitle: Colors.white,
                        colorBackground: ColorConfig.primary2,
                        colorBorder: ColorConfig.primary2,
                        paddingHor: 20,
                        paddingVer: 4,
                        onPressed: () {
                          if(cubit.timeMeeting == null) {
                            ToastUtils.showBottomToast(context, AppText.textPleaseChooseTimeMeeting.text, duration: 3);
                            return;
                          }
                          final model = cubit.createMeeting();
                          if(onAdd != null) {
                            onAdd!(model);
                          }
                          Navigator.of(context).pop();
                        }),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
