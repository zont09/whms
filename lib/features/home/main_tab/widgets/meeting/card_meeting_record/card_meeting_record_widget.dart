import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_record/title_record_text_field.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/more_option_meeting_button.dart';
import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CardMeetingRecordWidget extends StatelessWidget {
  const CardMeetingRecordWidget(
      {super.key,
      required this.record,
      required this.weight,
      required this.isEdit,
      required this.onUpdate});

  final MeetingRecordModel record;
  final List<int> weight;
  final bool isEdit;
  final Function(MeetingRecordModel) onUpdate; // MeetingPreparationModel

  @override
  Widget build(BuildContext context) {
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
                  child: TitleRecordTextField(
                      record: record,
                      controller: TextEditingController(text: record.title),
                      onUpdate: onUpdate,
                      isTitle: true)),
              Expanded(
                  flex: weight[1],
                  child: TitleRecordTextField(
                      record: record,
                      controller: TextEditingController(text: record.content),
                      onUpdate: onUpdate,
                      isTitle: false)),
              const ZSpace(w: 9),
            ],
          ),
        ),
        if (record.id.isNotEmpty)
          Positioned(
              top: ScaleUtils.scaleSize(2, context),
              right: ScaleUtils.scaleSize(8, context),
              child: MoreOptionMeetingButton(
                onDelete: () {
                  onUpdate(record.copyWith(enable: false));
                },
              ))
      ],
    );
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
  }
}
