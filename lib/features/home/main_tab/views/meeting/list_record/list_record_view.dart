import 'package:whms/features/home/main_tab/views/meeting/list_record/header_record_meeting_table.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_record/card_meeting_record_widget.dart';
import 'package:whms/models/meeting_record_model.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class ListRecordView extends StatelessWidget {
  const ListRecordView(
      {super.key,
        required this.listPreparations,
        required this.onUpdate});

  final List<MeetingRecordModel> listPreparations;
  final Function(MeetingRecordModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [2, 7];
    return Column(
      children: [
        const ZSpace(h: 12),
        HeaderRecordMeetingTable(weight: weight),
        const ZSpace(h: 6),
        ...listPreparations.map((e) => Column(
          children: [
            CardMeetingRecordWidget(
              key: ValueKey("key_meeting_record_${e.id}"),
              record: e,
              weight: weight,
              isEdit: true,
              onUpdate: onUpdate,
            ),
            const ZSpace(h: 12),
          ],
        )),
        if (listPreparations.isEmpty) const ZSpace(h: 12),
        CardMeetingRecordWidget(
          key: ValueKey("key_meeting_record_${listPreparations.length}"),
          record: MeetingRecordModel(),
          weight: weight,
          isEdit: true,
          onUpdate: onUpdate,
        ),
      ],
    );
  }
}
