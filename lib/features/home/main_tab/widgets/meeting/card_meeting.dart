import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_status_meeting.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/more_option_meeting_button.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CardMeeting extends StatelessWidget {
  const CardMeeting(
      {super.key,
      required this.meeting,
      required this.weight,
      required this.onUpdate,
      this.isShowMenuButton = true});

  final MeetingModel meeting;
  final List<int> weight;
  final Function(MeetingModel) onUpdate;
  final bool isShowMenuButton;

  @override
  Widget build(BuildContext context) {
    final configCubit = ConfigsCubit.fromContext(context);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
              border: Border.all(
                  width: ScaleUtils.scaleSize(1, context),
                  color: ColorConfig.border6),
              color: Colors.white,
              boxShadow: const [ColorConfig.boxShadow2]),
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(16, context),
              vertical: ScaleUtils.scaleSize(12, context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: weight[0],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(meeting.title,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(14, context),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black))
                            // MeetingTextField(
                            //   meeting: meeting,
                            //   controller:
                            //       TextEditingController(text: meeting.title),
                            //   onUpdate: (v) {
                            //     onUpdate(meeting.copyWith(title: v));
                            //   },
                            //   hint: AppText.textHintTypingTitle.text,
                            //   fontSize: 14,
                            //   fontWeight: FontWeight.w500,
                            // ),
                            ),
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[5],
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getTime(meeting.time),
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w400,
                                color: ColorConfig.textColor,
                                letterSpacing: -0.02)),
                        const ZSpace(w: 5),
                        Text("|",
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w500,
                                color: ColorConfig.textTertiary,
                                letterSpacing: -0.02)),
                        const ZSpace(w: 5),
                        Text(getDate(meeting.time),
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w600,
                                color: ColorConfig.textColor,
                                letterSpacing: -0.02)),
                      ],
                    ),
                  )),
              const ZSpace(w: 9),
              Expanded(
                  flex: weight[1],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: FormatTextView(
                        content: meeting.description,
                        maxLines: 3,
                        fontSize: 12,
                      ))

                      // Expanded(
                      //     child: EditableTextField(
                      //         text: meeting.description,
                      //         onSave: (v) {
                      //           onUpdate(meeting.copyWith(description: v));
                      //         },
                      //         controller: TextEditingController(
                      //             text: meeting.description)))

                      // Expanded(
                      //   child: MeetingTextField(
                      //     meeting: meeting,
                      //     controller:
                      //         TextEditingController(text: meeting.description),
                      //     onUpdate: (v) {
                      //       onUpdate(meeting.copyWith(description: v));
                      //     },
                      //     hint: AppText.textHintTypingDescription.text,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  )),
              Expanded(
                  flex: weight[2],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (meeting.members.isNotEmpty)
                          Tooltip(
                            message: configCubit
                                    .usersMap[meeting.members[0]]?.name ??
                                AppText.textUnknown.text,
                            child: AvatarItem(
                              configCubit.usersMap[meeting.members[0]]?.avt ??
                                  "",
                              size: ScaleUtils.scaleSize(22, context),
                            ),
                          ),
                        if (meeting.members.length > 1) const ZSpace(w: 5),
                        if (meeting.members.length > 1)
                          Tooltip(
                              richMessage: TextSpan(
                                text: (configCubit.usersMap[meeting.members[1]]
                                            ?.name ??
                                        AppText.textUnknown.text) +
                                    (meeting.members.length > 2 ? '\n' : ''),
                                style: const TextStyle(color: Colors.white),
                                children: [
                                  ...meeting.members.skip(2).map((item) {
                                    final isLast =
                                        item == meeting.members.skip(1).last;
                                    return TextSpan(
                                        text:
                                            (configCubit.usersMap[item]?.name ??
                                                    AppText.textUnknown.text) +
                                                (isLast ? '' : '\n'));
                                  })
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(
                                    ScaleUtils.scaleSize(8, context)),
                              ),
                              child: Container(
                                height: ScaleUtils.scaleSize(22, context),
                                width: ScaleUtils.scaleSize(22, context),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorConfig.primary3),
                                child: Center(
                                  child: Text(
                                    meeting.members.length > 100
                                        ? "99+"
                                        : "+${meeting.members.length - 1}",
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(12, context),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              )),
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[3],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: CardStatusMeeting(
                            status: meeting.status,
                            isSelected: false,
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[4],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: configCubit.usersMap[meeting.owner]?.name ??
                              AppText.textUnknown.text,
                          child: AvatarItem(
                            configCubit.usersMap[meeting.owner]?.avt ?? "",
                            size: ScaleUtils.scaleSize(22, context),
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: weight[6],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [],
                    ),
                  )),
            ],
          ),
        ),
        if (meeting.id.isNotEmpty && isShowMenuButton)
          Positioned(
              top: ScaleUtils.scaleSize(2, context),
              right: ScaleUtils.scaleSize(8, context),
              child: MoreOptionMeetingButton(
                onDelete: () {
                  onUpdate(meeting.copyWith(enable: false));
                },
              ))
      ],
    );
  }

  String getTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}";
  }
}
