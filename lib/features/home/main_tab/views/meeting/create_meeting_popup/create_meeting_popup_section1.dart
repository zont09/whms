import 'package:whms/features/home/main_tab/blocs/meeting/create_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/select_scope_popup.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_choose_member_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CreateMeetingPopupSection1 extends StatelessWidget {
  const CreateMeetingPopupSection1({
    super.key,
    required this.cubit,
    required this.configCubit,
  });

  final CreateMeetingCubit cubit;
  final ConfigsCubit configCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppText.textCreateMeeting.text.toUpperCase(),
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(24, context),
              fontWeight: FontWeight.w500,
              color: ColorConfig.textColor6,
              letterSpacing: -0.41,
              shadows: const [ColorConfig.textShadow]),
        ),
        // const ZSpace(h: 5),
        Text(AppText.textDescriptionCreateMeeting.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor7,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(h: 9),
        Text(AppText.textChooseScopeMeeting.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(h: 5),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          spacing: ScaleUtils.scaleSize(8, context),
          runSpacing: ScaleUtils.scaleSize(5, context),
          children: [
            ...cubit.listScopeMeeting.map((e) => ScopeCard(
              scope: e,
              remove: () {
                cubit.addScope(e);
              },
            )),
            InkWell(
              onTap: () {
                DialogUtils.showAlertDialog(context,
                    child: SelectScopePopup(
                        listScope: configCubit.allScopes,
                        listSelected: cubit.listScopeMeeting,
                        onSelect: (v) {
                          cubit.addScope(v);
                        }));
              },
              child: Image.asset('assets/images/icons/ic_add_meeting.png',
                  height: ScaleUtils.scaleSize(20, context)),
            ),
          ],
        ),
        const ZSpace(h: 9),
        Text(AppText.textChooseMemberMeeting.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(h: 5),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          spacing: ScaleUtils.scaleSize(8, context),
          runSpacing: ScaleUtils.scaleSize(5, context),
          children: [
            ...cubit.listMemberMeeting.map((e) => InkWell(
              onTap: () {
                cubit.addMember(e);
              },
              child: Tooltip(
                message: e.name,
                child: AvatarItem(e.avt),
              ),
            )),
            InkWell(
              onTap: () {
                DialogUtils.showAlertDialog(context,
                    child: ScopeChooseMemberPopup(
                        users: configCubit.allUsers,
                        selectedUsers: cubit.listMemberMeeting,
                        updateMember: (v) {
                          cubit.EMIT();
                        }));
              },
              child: Image.asset('assets/images/icons/ic_add_meeting.png',
                  height: ScaleUtils.scaleSize(20, context)),
            ),
          ],
        ),
      ],
    );
  }
}