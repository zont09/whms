import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/product_handover_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/close_file_widget.dart';
import 'package:whms/widgets/comment/file_view_widget.dart';
import 'package:whms/widgets/comment/video_view_widget.dart';
import 'package:whms/widgets/format_text_field/editable_format_text_field.dart';
import 'package:whms/widgets/z_space.dart';

class ProductHandoverView extends StatelessWidget {
  const ProductHandoverView({
    super.key,
    required this.work,
    required this.onUpdate,
  });

  final WorkingUnitModel work;
  final Function(WorkingUnitModel, WorkingUnitModel) onUpdate;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    bool canEdit = work.assignees.contains(user.id);

    return BlocProvider(
      create: (context) => ProductHandoverCubit(work, onUpdate, context)..initData(),
      child: BlocBuilder<ProductHandoverCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<ProductHandoverCubit>(c);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title
              Row(
                children: [
                  Text(
                    'Bàn giao sản phẩm',
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(16, context),
                      fontWeight: FontWeight.w600,
                      letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                      color: ColorConfig.textColor,
                    ),
                  ),
                ],
              ),

              const ZSpace(h: 10),

              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 1, color: ColorConfig.border
                    )
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mô tả bàn giao',
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(16, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textColor5,
                      ),
                    ),

                    const ZSpace(h: 6),

                    EditableFormatTextField(
                      isPermissionEdit: canEdit,
                      text: cubit.handoverDescription,
                      textStyle: TextStyle(
                        color: ColorConfig.textColor,
                        fontWeight: FontWeight.w400,
                        letterSpacing: ScaleUtils.scaleSize(-0.02 * 14, context),
                        fontSize: ScaleUtils.scaleSize(10, context),
                      ),
                      onSubmit: (v) {
                        cubit.updateHandoverDescription(v);
                      },
                      controller: TextEditingController(text: cubit.handoverDescription),
                      // hintText: 'Nhập mô tả bàn giao sản phẩm...',
                    ),

                    const ZSpace(h: 16),

                    // Files section
                    Row(
                      children: [
                        Text(
                          'Tài liệu bàn giao',
                          style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(16, context),
                            fontWeight: FontWeight.w500,
                            color: ColorConfig.textColor5,
                          ),
                        ),
                        const ZSpace(w: 6),
                        if (canEdit)
                          InkWell(
                            onTap: () async => await cubit.pickFile(),
                            child: Image.asset(
                              'assets/images/icons/ic_add_task_2.png',
                              height: ScaleUtils.scaleSize(20, context),
                            ),
                          ),
                      ],
                    ),

                    const ZSpace(h: 12),

                    // Files list
                    Wrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      spacing: ScaleUtils.scaleSize(10, context),
                      runSpacing: ScaleUtils.scaleSize(10, context),
                      children: [
                        // Images
                        if (cubit.sumLen > 0)
                          ...cubit.listImages.map((img) => Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(ScaleUtils.scaleSize(10, context)),
                                    child: MouseRegion(
                                      onEnter: (_) {
                                        DialogUtils.showAlertDialog(
                                          context,
                                          child: Image.memory(
                                            Uint8List.fromList(img.bytes!),
                                            height: null,
                                            width: null,
                                          ),
                                        );
                                      },
                                      child: img.bytes == null
                                          ? Container()
                                          : Image.memory(
                                        key: ValueKey("key_handover_images_${img.bytes}"),
                                        Uint8List.fromList(img.bytes!),
                                        height: ScaleUtils.scaleSize(80, context),
                                        width: null,
                                      ),
                                    ),
                                  ),
                                  if (canEdit)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: CloseFileWidget(
                                        onClose: () {
                                          cubit.removeFile(img, "image");
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              const ZSpace(w: 8),
                            ],
                          )),

                        // Videos
                        ...cubit.listVideos.map((video) => Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(ScaleUtils.scaleSize(10, context)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      DialogUtils.showVideoDialog(context, video);
                                    },
                                    child: VideoViewWidget(title: video.name),
                                  ),
                                  const ZSpace(w: 8),
                                ],
                              ),
                            ),
                            if (canEdit)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(
                                  onClose: () {
                                    cubit.removeFile(video, "video");
                                  },
                                ),
                              ),
                          ],
                        )),

                        // Audios
                        ...cubit.listAudios.map((aud) => Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(ScaleUtils.scaleSize(10, context)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      DialogUtils.showAudioDialog(context, aud);
                                    },
                                    child: VideoViewWidget(
                                      title: aud.name,
                                      isAudio: true,
                                    ),
                                  ),
                                  const ZSpace(w: 8),
                                ],
                              ),
                            ),
                            if (canEdit)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(
                                  onClose: () {
                                    cubit.removeFile(aud, "audio");
                                  },
                                ),
                              ),
                          ],
                        )),

                        // Documents
                        ...cubit.listDocs.map((file) => Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(ScaleUtils.scaleSize(6, context)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      FileUtils.handleFileDocuments(context, file);
                                    },
                                    child: FileViewWidget(
                                      title: file.name,
                                      onRemove: () {},
                                      isCanRemove: false,
                                    ),
                                  ),
                                  const ZSpace(w: 8),
                                ],
                              ),
                            ),
                            if (canEdit)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(
                                  onClose: () {
                                    cubit.removeFile(file, "document");
                                  },
                                ),
                              ),
                          ],
                        )),

                        // Other files
                        ...cubit.listOthers.map((file) => Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(ScaleUtils.scaleSize(6, context)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      FileUtils.downloadPlatformFile(file);
                                    },
                                    child: FileViewWidget(
                                      title: file.name,
                                      onRemove: () {},
                                      isCanRemove: false,
                                    ),
                                  ),
                                  const ZSpace(w: 8),
                                ],
                              ),
                            ),
                            if (canEdit)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: CloseFileWidget(
                                  onClose: () {
                                    cubit.removeFile(file, "other");
                                  },
                                ),
                              ),
                          ],
                        )),

                        // Loading indicator
                        if (cubit.loading > 0) const ZSpace(w: 12),
                        if (cubit.loading > 0)
                          const CircularProgressIndicator(
                            color: ColorConfig.primary3,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Description text field

            ],
          );
        },
      ),
    );
  }
}