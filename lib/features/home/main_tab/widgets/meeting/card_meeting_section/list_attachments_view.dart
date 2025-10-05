import 'dart:typed_data';

import 'package:whms/features/home/main_tab/blocs/meeting/card_meeting_section_cubit.dart';
import 'package:whms/features/home/main_tab/views/meeting/select_file_popup/select_file_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'dart:js' as js;

class ListAttachmentsView extends StatelessWidget {
  const ListAttachmentsView({
    super.key,
    required this.cubit,
    required this.mapFile,
    required this.onAddFile,
  });

  final CardMeetingSectionCubit cubit;
  final Map<String, FileAttachmentModel> mapFile;
  final Function(FileAttachmentModel p1) onAddFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(2.5, context)),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                ...cubit.section.attachments.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (mapFile[e] == null) return;
                            if (mapFile[e]!.type == "link") {
                              // final url = Uri.parse(mapFile[e]!.source);
                              final url = mapFile[e]!.source;
                              if (url.isNotEmpty) {
                                try {
                                  js.context.callMethod('open', [url, '_blank']);
                                } catch (e) {
                                  print('Error opening link: $e');
                                }
                              }
                            } else {
                              final file = await CacheUtils.instance
                                  .getFileGB(mapFile[e]!.source);
                              if (file == null) return;
                              if (FileUtils.isDocument(file) &&
                                  context.mounted) {
                                FileUtils.handleFileDocuments(context, file);
                              } else if (FileUtils.isImage(file) &&
                                  context.mounted) {
                                DialogUtils.showAlertDialog(
                                  context,
                                  child: Image.memory(
                                    Uint8List.fromList(file.bytes!),
                                    height: null,
                                    width: null,
                                  ),
                                );
                              } else if (FileUtils.isVideo(file) &&
                                  context.mounted) {
                                DialogUtils.showVideoDialog(context, file);
                              } else if (FileUtils.isAudio(file) &&
                                  context.mounted) {
                                DialogUtils.showAudioDialog(context, file);
                              } else {
                                FileUtils.downloadPlatformFile(file);
                              }
                            }
                          },
                          child: Text(
                              mapFile[e]?.title ?? AppText.textUnknown.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(14, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.textColor,
                                  decoration: TextDecoration.underline,
                                  overflow: TextOverflow.ellipsis,
                                  decorationColor: ColorConfig.textColor)),
                        ),
                        const ZSpace(h: 4),
                      ],
                    )),
                InkWell(
                    onTap: () {
                      DialogUtils.showAlertDialog(context,
                          child: SelectFilePopup(onUpload: (v) {
                        onAddFile(v);
                      }));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(229),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 3,
                                  offset: const Offset(0, 0),
                                  color: Colors.black.withOpacity(0.2))
                            ],
                            color: Colors.white),
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(8, context),
                            vertical: ScaleUtils.scaleSize(4, context)),
                        child: Row(children: [
                          Image.asset('assets/images/icons/ic_upload_2.png',
                              height: ScaleUtils.scaleSize(16, context), color: ColorConfig.primary2,),
                          const ZSpace(w: 4),
                          Text(AppText.titleAddFileAttachment.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(12, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.primary3))
                        ])))
              ]))
        ]));
  }
}
