import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_preparation/checklist_preparation_view.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_preparation/content_text_field.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_preparation/list_attachments_preparation_view.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/more_option_meeting_button.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/select_user_popup/select_user_popup.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/widgets/avatar_item.dart';

class CardMeetingPreparationWidget extends StatelessWidget {
  const CardMeetingPreparationWidget(
      {super.key,
      required this.prepare,
      required this.weight,
      required this.isEdit,
      required this.onUpdate,
      required this.onAddFile,
      required this.mapFile});

  final MeetingPreparationModel prepare;
  final List<int> weight;
  final bool isEdit;
  final Function(MeetingPreparationModel) onUpdate; // MeetingPreparationModel
  final Function(FileAttachmentModel) onAddFile;
  final Map<String, FileAttachmentModel> mapFile;

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      prepare.owner.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                DialogUtils.showAlertDialog(context,
                                    child: SelectUserPopup(
                                        listUsers: configCubit.usersMap.values
                                            .toList(),
                                        listSelected: const [],
                                        onSelect: (v) {
                                          onUpdate(
                                              prepare.copyWith(owner: v.id));
                                        }));
                              },
                              child: Tooltip(
                                message:
                                    configCubit.usersMap[prepare.owner]?.name ??
                                        AppText.textUnknown.text,
                                child: AvatarItem(
                                    configCubit.usersMap[prepare.owner]?.avt ??
                                        ""),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                DialogUtils.showAlertDialog(context,
                                    child: SelectUserPopup(
                                        listUsers: configCubit.usersMap.values
                                            .toList(),
                                        listSelected: const [],
                                        onSelect: (v) {
                                          onUpdate(
                                              prepare.copyWith(owner: v.id));
                                        }));
                              },
                              child: Image.asset(
                                  'assets/images/icons/ic_add_circle.png',
                                  height: ScaleUtils.scaleSize(31, context)),
                            )
                    ],
                  )),
              Expanded(
                  flex: weight[1],
                  child: InkWell(
                    onTap: () async {
                      final times =
                          await DateTimeUtils.pickTimeAndDate(context);
                      if (times != null) {
                        onUpdate(
                            prepare.copyWith(date: Timestamp.fromDate(times)));
                      }
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: ScaleUtils.scaleSize(4, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(getTime(prepare.date.toDate()),
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
                            Text(getDate(prepare.date.toDate()),
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(14, context),
                                    fontWeight: FontWeight.w600,
                                    color: ColorConfig.textColor,
                                    letterSpacing: -0.02)),
                          ],
                        ),
                      ),
                    ),
                  )),
              Expanded(
                  flex: weight[2],
                  child: ContentTextField(
                      isEdit: isEdit,
                      prepare: prepare,
                      controller: TextEditingController(text: prepare.content),
                      onUpdate: onUpdate)),
              Expanded(
                  flex: weight[3],
                  child: ListAttachmentsPreparationView(
                      prepare: prepare,
                      mapFile: mapFile,
                      onAddFile: onAddFile)),
              Expanded(
                  flex: weight[4],
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: ScaleUtils.scaleSize(10.5, context)),
                    child: CheckListPreparationView(
                        prepare: prepare, isEdit: isEdit, onUpdate: onUpdate),
                  )),
            ],
          ),
        ),
        if (prepare.id.isNotEmpty)
          Positioned(
              top: ScaleUtils.scaleSize(2, context),
              right: ScaleUtils.scaleSize(8, context),
              child: MoreOptionMeetingButton(
                onDelete: () {
                  onUpdate(prepare.copyWith(enable: false));
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
