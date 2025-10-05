import 'package:whms/features/home/main_tab/views/meeting/list_preparation/header_preparation_meeting_table.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_preparation/card_meeting_preparation_widget.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/meeting_preparation_model.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class ListPreparationView extends StatelessWidget {
  const ListPreparationView(
      {super.key,
        required this.listPreparations,
        required this.onUpdate,
        required this.onAddFile,
        required this.mapFile});

  final List<MeetingPreparationModel> listPreparations;
  final Function(MeetingPreparationModel) onUpdate;
  final Function(FileAttachmentModel, MeetingPreparationModel) onAddFile;
  final Map<String, FileAttachmentModel> mapFile;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [2, 3, 6, 3, 6];
    return Column(
      children: [
        const ZSpace(h: 12),
        HeaderPreparationMeetingTable(weight: weight),
        const ZSpace(h: 6),
        ...listPreparations.map((e) => Column(
          children: [
            CardMeetingPreparationWidget(
              key: ValueKey("key_meeting_preparation_${e.id}"),
              prepare: e,
              weight: weight,
              isEdit: true,
              onUpdate: onUpdate,
              onAddFile: (v) {
                onAddFile(v, e);
              },
              mapFile: mapFile,
            ),
            const ZSpace(h: 12),
          ],
        )),
        if (listPreparations.isEmpty) const ZSpace(h: 12),
        CardMeetingPreparationWidget(
          key: ValueKey("key_meeting_section_${listPreparations.length}"),
          prepare: MeetingPreparationModel(),
          weight: weight,
          isEdit: true,
          onUpdate: onUpdate,
          onAddFile: (v) {
            onAddFile(v, MeetingPreparationModel());
          },
          mapFile: mapFile,
        ),
      ],
    );
  }
}
