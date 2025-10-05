import 'package:whms/features/home/main_tab/views/meeting/create_meeting_popup/create_meeting_popup.dart';
import 'package:whms/features/home/main_tab/views/meeting/meeting_overview.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/loading_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MeetingMainView extends StatelessWidget {
  const MeetingMainView({super.key, required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    final configCubit = ConfigsCubit.fromContext(context);
    // final bool isShow = true;
    // if(!isShow) {
    //   return Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     color: Colors.transparent,
    //     child: const Center(child: InvalidWidget(),),
    //   );
    // }
    return BlocProvider(
      create: (context) => MeetingCubit(configCubit.user,context)..initData(tab),
      child: BlocBuilder<MeetingCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<MeetingCubit>(c);
          if(s == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: const Center(child: LoadingWidget(),),
            );
          }
          return Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(child: MeetingOverview(cubit: cubit)),
                if(cubit.meetingSelected.id == "none")
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(20, context),
                      vertical: ScaleUtils.scaleSize(20, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          DialogUtils.showAlertDialog(context,
                              child: CreateMeetingPopup(onAdd: (v) {
                                cubit.addMeeting(v);
                              },));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                                'assets/images/icons/ic_add_meeting.png',
                                height: ScaleUtils.scaleSize(20, context)),
                            const ZSpace(w: 5),
                            Text(AppText.textCreateMeeting.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(16, context),
                                    fontWeight: FontWeight.w600,
                                    color: ColorConfig.textColor))
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
