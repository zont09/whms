import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/file_view_widget.dart';
import 'package:whms/widgets/comment/video_view_widget.dart';
import 'package:whms/widgets/z_space.dart';

import 'comment_view_cubit.dart';


class AttachmentsCommentView extends StatelessWidget {
  const AttachmentsCommentView({
    super.key,
    required this.comment,
    required this.cubit
  });

  final CommentModel comment;
  final CommentViewCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(comment.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: [
            ...cubit.images.map((img) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    DialogUtils.showAlertDialog(
                      context,
                      child: Image.memory(
                        Uint8List.fromList(img.bytes!),
                        height: null,
                        width: null,
                      ),
                    );
                  },
                  child: Image.memory(
                    Uint8List.fromList(img.bytes!),
                    height:
                    ScaleUtils.scaleSize(80, context),
                    width: null,
                  ),
                ),
                const ZSpace(w: 5),
              ],
            )),
            ...cubit.videos.map((vd) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () async {
                      FileUtils.downloadPlatformFile(vd);
                    },
                    child:
                    VideoViewWidget(title: vd.name)),
                const ZSpace(w: 5),
              ],
            )),
          ],
        ),
        const ZSpace(h: 9),
        Wrap(
          direction: Axis.horizontal,
          children: [
            ...cubit.files.map((file) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                    onTap: () async {
                      FileUtils.downloadPlatformFile(file);
                    },
                    child: FileViewWidget(
                      title: file.name,
                      onRemove: () {},
                      isCanRemove: false,
                      width: 200,
                    )),
                const ZSpace(w: 5),
              ],
            )),
          ],
        ),
      ],
    );
  }
}