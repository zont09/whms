import 'dart:typed_data';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/attachment_files_task_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/close_file_widget.dart';
import 'package:whms/widgets/comment/file_view_widget.dart';
import 'package:whms/widgets/comment/video_view_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttachmentFilesView extends StatelessWidget {
  const AttachmentFilesView(
      {super.key, required this.work, required this.onUpdate});

  final WorkingUnitModel work;
  final Function(WorkingUnitModel, WorkingUnitModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    bool canUpload = work.assignees.contains(user.id) || work.owner == user.id;
    return BlocProvider(
        create: (context) =>
            AttachmentFilesTaskCubit(work, onUpdate,context)..initData(),
        child: BlocBuilder<AttachmentFilesTaskCubit, int>(builder: (c, s) {
          var cubit = BlocProvider.of<AttachmentFilesTaskCubit>(c);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(AppText.titleAttachmentsFile.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w600,
                          letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                          color: ColorConfig.textColor)),
                  const ZSpace(w: 6),
                  if (canUpload)
                    InkWell(
                        onTap: () async => await cubit.pickFile(),
                        child: Image.asset(
                            'assets/images/icons/ic_add_task_2.png',
                            height: ScaleUtils.scaleSize(20, context)))
                ]),
                const ZSpace(h: 12),
                Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: ScaleUtils.scaleSize(10, context),
                    runSpacing: ScaleUtils.scaleSize(10, context),
                    children: [
                      if (cubit.sumLen > 0) const ZSpace(h: 9),
                      if (cubit.sumLen > 0)
                        ...cubit.listImages.map((img) => Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                            ScaleUtils.scaleSize(10, context)),
                                        child: MouseRegion(
                                            onEnter: (_) {
                                              DialogUtils.showAlertDialog(
                                                  context,
                                                  child: Image.memory(
                                                      Uint8List.fromList(
                                                          img.bytes!),
                                                      height: null,
                                                      width: null));
                                            },
                                            child: img.bytes == null
                                                ? Container()
                                                : Image.memory(
                                                    key: ValueKey(
                                                        "key_images_${img.bytes}"),
                                                    Uint8List.fromList(
                                                        img.bytes!),
                                                    height:
                                                        ScaleUtils.scaleSize(
                                                            80, context),
                                                    width: null)),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: CloseFileWidget(onClose: () {
                                          cubit.removeFile(img, "image");
                                        }),
                                      )
                                    ],
                                  ),
                                  const ZSpace(w: 8),
                                ])),
                      ...cubit.listVideos.map((video) => Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    ScaleUtils.scaleSize(10, context)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            DialogUtils.showVideoDialog(
                                                context, video);
                                          },
                                          child: VideoViewWidget(
                                              title: video.name)),
                                      const ZSpace(w: 8)
                                    ]),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(onClose: () {
                                  cubit.removeFile(video, "video");
                                }),
                              )
                            ],
                          )),
                      ...cubit.listAudios.map((aud) => Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    ScaleUtils.scaleSize(10, context)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            DialogUtils.showAudioDialog(
                                                context, aud);
                                          },
                                          child: VideoViewWidget(
                                              title: aud.name, isAudio: true)),
                                      const ZSpace(w: 8)
                                    ]),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(onClose: () {
                                  cubit.removeFile(aud, "audio");
                                }),
                              )
                            ],
                          )),
                      ...cubit.listDocs.map((file) => Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    ScaleUtils.scaleSize(6, context)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            // FileUtils.downloadPlatformFile(file);
                                            FileUtils.handleFileDocuments(
                                                context, file);
                                          },
                                          child: FileViewWidget(
                                              title: file.name,
                                              onRemove: () {},
                                              isCanRemove: false)),
                                      const ZSpace(w: 8)
                                    ]),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(onClose: () {
                                  cubit.removeFile(file, "document");
                                }),
                              )
                            ],
                          )),
                      ...cubit.listOthers.map((file) => Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    ScaleUtils.scaleSize(6, context)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            FileUtils.downloadPlatformFile(
                                                file);
                                          },
                                          child: FileViewWidget(
                                              title: file.name,
                                              onRemove: () {},
                                              isCanRemove: false)),
                                      const ZSpace(w: 8),
                                    ]),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(onClose: () {
                                  cubit.removeFile(file, "other");
                                }),
                              )
                            ],
                          )),
                      if (cubit.loading > 0) const ZSpace(w: 12),
                      if (cubit.loading > 0)
                        const CircularProgressIndicator(
                            color: ColorConfig.primary3)
                    ])
              ]);
        }));
  }
}
