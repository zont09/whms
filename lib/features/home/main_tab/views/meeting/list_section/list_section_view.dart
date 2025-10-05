import 'package:whms/features/home/main_tab/views/meeting/list_section/header_section_meeting_table.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_section/card_meeting_section_widget.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class ListSectionView extends StatelessWidget {
  const ListSectionView(
      {super.key,
      required this.listSections,
      required this.onUpdate,
      required this.onAddFile,
      required this.mapFile});

  final List<MeetingSectionModel> listSections;
  final Function(MeetingSectionModel) onUpdate;
  final Function(FileAttachmentModel, MeetingSectionModel) onAddFile;
  final Map<String, FileAttachmentModel> mapFile;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [3, 7, 7, 3, 3];
    return Column(
      children: [
        const ZSpace(h: 12),
        HeaderSectionMeetingTable(weight: weight),
        const ZSpace(h: 9),
        ...listSections.map((e) => Column(
              children: [
                CardMeetingSectionWidget(
                  key: ValueKey("key_meeting_section_${e.id}"),
                  section: e,
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
        if (listSections.isEmpty) const ZSpace(h: 12),
        CardMeetingSectionWidget(
          key: ValueKey("key_meeting_section_${listSections.length}"),
          section: MeetingSectionModel(),
          weight: weight,
          isEdit: true,
          onUpdate: onUpdate,
          onAddFile: (v) {
            onAddFile(v, MeetingSectionModel());
          },
          mapFile: mapFile,
        ),
      ],
    );
  }
}
