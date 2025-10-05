import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/card_meeting_section_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_section/checklist_view.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_section/description_text_field.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_section/list_attachments_view.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting_section/title_text_field.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/duration_dropdown_without_border.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/more_option_meeting_button.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardMeetingSectionWidget extends StatelessWidget {
  const CardMeetingSectionWidget(
      {super.key,
      required this.section,
      required this.weight,
      required this.isEdit,
      required this.onUpdate,
      required this.onAddFile,
      required this.mapFile});

  final MeetingSectionModel section;
  final List<int> weight;
  final bool isEdit;
  final Function(MeetingSectionModel) onUpdate;
  final Function(FileAttachmentModel) onAddFile;
  final Map<String, FileAttachmentModel> mapFile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardMeetingSectionCubit(section)..initData(),
      child: BlocBuilder<CardMeetingSectionCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CardMeetingSectionCubit>(c);
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
                        child: TitleTextField(
                            isEdit: isEdit,
                            section: section,
                            cubit: cubit,
                            onUpdate: onUpdate)),
                    Expanded(
                        flex: weight[1],
                        child: DescriptionTextField(
                            isEdit: isEdit,
                            section: section,
                            cubit: cubit,
                            onUpdate: onUpdate)),
                    Expanded(
                        flex: weight[2],
                        child: CheckListView(
                            section: section,
                            isEdit: isEdit,
                            onUpdate: onUpdate)),
                    Expanded(
                        flex: weight[3],
                        child: ListAttachmentsView(
                            cubit: cubit,
                            mapFile: mapFile,
                            onAddFile: onAddFile)),
                    Expanded(
                        flex: weight[4],
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(2.5, context)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DurationDropdownWithoutBorder(
                                  onChanged: (v) {
                                    onUpdate(
                                        cubit.section.copyWith(durations: v));
                                  },
                                  initItem: cubit.section.durations)
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              if(section.id.isNotEmpty)
              Positioned(
                  top: ScaleUtils.scaleSize(2, context),
                  right: ScaleUtils.scaleSize(8, context),
                  child: MoreOptionMeetingButton(
                    onDelete: () {
                      onUpdate(section.copyWith(enable: false));
                    },
                  ))
            ],
          );
        },
      ),
    );
  }
}
