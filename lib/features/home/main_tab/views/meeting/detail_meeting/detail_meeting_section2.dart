import 'package:whms/features/manager/widgets/scope_tab/scope_choose_member_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/detail_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/dropdown_search_user.dart';
import 'package:whms/widgets/editable_text_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class DetailMeetingSection2 extends StatelessWidget {
  const DetailMeetingSection2({
    super.key,
    required this.meeting,
    required this.cubit,
    required this.cubitM,
    required this.configCubit,
  });

  final MeetingModel meeting;
  final DetailMeetingCubit cubit;
  final MeetingCubit cubitM;
  final ConfigsCubit configCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.titleDescription.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w600,
                color: ColorConfig.textColor,
                letterSpacing: -0.33)),
        const ZSpace(h: 6),
        EditableTextField(
            key: ValueKey(
                "key_detail_meeting_description_${meeting.description}"),
            text: meeting.description,
            onSave: (v) {
              cubit.updateMeeting(meeting.copyWith(description: v));
              cubitM.updateMeeting(meeting.copyWith(description: v));
            },
            controller: TextEditingController(text: meeting.description)),
        // MeetingTextField(
        //   meeting: meeting,
        //   controller: TextEditingController(text: meeting.description),
        //   onUpdate: (v) {
        //     cubit.updateMeeting(meeting.copyWith(description: v));
        //     cubitM.updateMeeting(meeting.copyWith(description: v));
        //   },
        //   hint: AppText.textHintTypingDescription.text,
        //   fontSize: 16,
        //   fontWeight: FontWeight.w400,
        // ),
        const ZSpace(h: 9),
        Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: ScaleUtils.scaleSize(8, context),
          runSpacing: ScaleUtils.scaleSize(5, context),
          children: [
            Text(AppText.textMemberMeeting.text,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(14, context),
                    fontWeight: FontWeight.w600,
                    color: ColorConfig.textColor,
                    letterSpacing: -0.33)),
            ...cubit.meeting.members
                .where((e) => configCubit.usersMap[e] != null)
                .map((e) => IntrinsicWidth(
                      child: CardUserItem(
                          user: configCubit.usersMap[e]!,
                          fontSize: 12,
                          isSelected: false,
                          textColor: ColorConfig.textColor),
                    )),
            InkWell(
              onTap: () {
                // if (cubit.meeting.description.isEmpty ||
                //     cubit.meeting.description == "[{\"insert\":\"\\n\"}]" ||
                //     cubit.meeting.description == "[{\"insert\":\"\"}]")
                if(meeting.sections.isEmpty)
                {
                  ToastUtils.showBottomToast(
                      context, AppText.textNeedAddDescriptionToAddMember.text,
                      duration: 4);
                  return;
                }
                DialogUtils.showAlertDialog(context,
                    child: ScopeChooseMemberPopup(
                        users: configCubit.allUsers,
                        selectedUsers: cubit.meeting.members
                            .where((e) => configCubit.usersMap[e] != null)
                            .map((e) => configCubit.usersMap[e]!)
                            .toList(),
                        updateMember: (v) {
                          final newMeet = meeting
                              .copyWith(members: [...v.map((e) => e.id)]);
                          cubitM.updateMeeting(newMeet);
                          cubit.updateMeeting(newMeet);
                        }));
              },
              child: Image.asset("assets/images/icons/ic_edit.png",
                  height: ScaleUtils.scaleSize(22, context)),
            )
          ],
        ),
      ],
    );
  }
}
