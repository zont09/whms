import 'package:whms/features/home/main_tab/views/meeting/detail_meeting/detail_meeting_section1.dart';
import 'package:whms/features/home/main_tab/views/meeting/detail_meeting/detail_meeting_section2.dart';
import 'package:whms/features/home/main_tab/views/meeting/detail_meeting/detail_meeting_section3.dart';
import 'package:whms/features/home/main_tab/views/meeting/list_preparation/list_preparation_view.dart';
import 'package:whms/features/home/main_tab/views/meeting/list_record/list_record_view.dart';
import 'package:whms/features/home/main_tab/views/meeting/list_section/list_section_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/detail_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailMeetingView extends StatelessWidget {
  const DetailMeetingView(
      {super.key, required this.meeting, required this.cubitM});

  final MeetingModel meeting;
  final MeetingCubit cubitM;

  @override
  Widget build(BuildContext context) {
    final configCubit = ConfigsCubit.fromContext(context);

    return BlocProvider(
      create: (context) => DetailMeetingCubit(meeting, configCubit.user)
        ..initData(configCubit.allScopeMap),
      child: BlocBuilder<DetailMeetingCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<DetailMeetingCubit>(c);
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailMeetingSection1(
                      cubitM: cubitM, meeting: meeting, cubit: cubit),
                  const ZSpace(h: 9),
                  DetailMeetingSection2(
                      meeting: meeting,
                      cubit: cubit,
                      cubitM: cubitM,
                      configCubit: configCubit),
                  const ZSpace(h: 9),
                  DetailMeetingSection3(
                      cubit: cubit,
                      configCubit: configCubit,
                      meeting: meeting,
                      cubitM: cubitM),
                  if (cubit.tab == AppText.textMeetingContent.text)
                    !cubitM.mapSection.containsKey(meeting.id)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ColorConfig.primary3,
                            ),
                          )
                        : ListSectionView(
                            listSections: cubitM.mapSection[meeting.id] ?? [],
                            onUpdate: (v) {
                              if (v.id.isEmpty &&
                                  v.title.isEmpty &&
                                  v.description.isEmpty &&
                                  v.attachments.isEmpty &&
                                  v.durations == 0 &&
                                  v.checklist.isEmpty) {
                                // cubit.updateMeeting(cubit.meeting.copyWith(
                                //     sections: [...cubit.meeting.sections, "--pseudocode--"]));
                              }
                              cubitM.updateSection(v, meeting);
                            },
                            onAddFile: (x, y) {
                              cubitM.addFileAttachSection(y, meeting, x);
                            },
                            mapFile: cubitM.mapFileAttach,
                          ),
                  if (cubit.tab == AppText.textPrepareDocuments.text)
                    !cubitM.mapPreparation.containsKey(meeting.id)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ColorConfig.primary3,
                            ),
                          )
                        : ListPreparationView(
                            listPreparations:
                                cubitM.mapPreparation[meeting.id] ?? [],
                            onUpdate: (v) {
                              cubitM.updatePreparation(v, meeting);
                            },
                            onAddFile: (x, y) {
                              cubitM.addFileAttachPreparation(y, meeting, x);
                            },
                            mapFile: cubitM.mapFileAttach,
                          ),
                  if (cubit.tab == AppText.textRecordMeetings.text)
                    !cubitM.mapRecord.containsKey(meeting.id)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: ColorConfig.primary3,
                            ),
                          )
                        : ListRecordView(
                            listPreparations:
                                cubitM.mapRecord[meeting.id] ?? [],
                            onUpdate: (v) {
                              cubitM.updateRecord(v, meeting);
                            })
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
