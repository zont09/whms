import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/detail_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/select_scope_popup.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class DetailMeetingSection3 extends StatelessWidget {
  const DetailMeetingSection3({
    super.key,
    required this.cubit,
    required this.configCubit,
    required this.meeting,
    required this.cubitM,
  });

  final DetailMeetingCubit cubit;
  final ConfigsCubit configCubit;
  final MeetingModel meeting;
  final MeetingCubit cubitM;

  @override
  Widget build(BuildContext context) {
    final userMap = ConfigsCubit.fromContext(context).usersMap;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: ScaleUtils.scaleSize(8, context),
          runSpacing: ScaleUtils.scaleSize(5, context),
          children: [
            Text(AppText.titleScope.text,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(14, context),
                    fontWeight: FontWeight.w600,
                    color: ColorConfig.textColor,
                    letterSpacing: -0.33)),
            ...cubit.meeting.scopes
                .where((e) => configCubit.allScopeMap[e] != null)
                .map((e) => ScopeCard(
                      scope: configCubit.allScopeMap[e]!,
                    )),
            InkWell(
              onTap: () {
                DialogUtils.showAlertDialog(context,
                    child: SelectScopePopup(
                        listScope: configCubit.allScopes,
                        listSelected: cubit.listScopeMeeting,
                        onSelect: (v) {
                          cubit.updateListScope(v);
                          List<String> listScp = cubit.meeting.scopes;
                          List<String> listUsr = [];
                          if (cubit.meeting.scopes.contains(v.id)) {
                            listScp.remove(v.id);
                            for (var e in cubit.meeting.members) {
                              if (userMap[e] == null) continue;
                              final user = userMap[e]!;
                              bool isRemove = false;
                              if (user.scopes.contains(v.id)) {
                                isRemove = true;
                                for (var r in listScp) {
                                  if (user.scopes.contains(r)) {
                                    isRemove = false;
                                  }
                                }
                              }
                              if (!isRemove) {
                                listUsr.add(e);
                              }
                            }
                          } else {
                            listScp.add(v.id);
                            listUsr = [...cubit.meeting.members];
                            for (var e in userMap.values) {
                              if (e.scopes.contains(v.id) &&
                                  !cubit.meeting.members.contains(e.id)) {
                                listUsr.add(e.id);
                              }
                            }
                          }
                          final newMeet = meeting.copyWith(
                              scopes: [...listScp], members: [...listUsr]);
                          cubit.updateMeeting(newMeet);
                          cubitM.updateMeeting(newMeet);
                        }));
              },
              child: Image.asset("assets/images/icons/ic_edit.png",
                  height: ScaleUtils.scaleSize(22, context)),
            )
          ]),
      const ZSpace(h: 12),
      Row(children: [
        InkWell(
          onTap: () {
            if (cubit.tab != AppText.textMeetingContent.text) {
              cubit.changeTab(AppText.textMeetingContent.text);
              cubitM.getDataSection(meeting);
            }
          },
          child: Text(AppText.textMeetingContent.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.33,
                  color: cubit.tab == AppText.textMeetingContent.text
                      ? ColorConfig.primary3
                      : Colors.black)),
        ),
        const ZSpace(w: 40),
        InkWell(
          onTap: () {
            if (cubit.tab != AppText.textPrepareDocuments.text) {
              cubit.changeTab(AppText.textPrepareDocuments.text);
            }
          },
          child: Text(AppText.textPrepareDocuments.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.33,
                  color: cubit.tab == AppText.textPrepareDocuments.text
                      ? ColorConfig.primary3
                      : Colors.black)),
        ),
        const ZSpace(w: 40),
        InkWell(
          onTap: () {
            if (cubit.tab != AppText.textRecordMeetings.text) {
              cubit.changeTab(AppText.textRecordMeetings.text);
            }
          },
          child: Text(AppText.textRecordMeetings.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.33,
                  color: cubit.tab == AppText.textRecordMeetings.text
                      ? ColorConfig.primary3
                      : Colors.black)),
        )
      ])
    ]);
  }
}
