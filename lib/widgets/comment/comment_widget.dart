import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/comment/close_file_widget.dart';
import 'package:whms/widgets/comment/comment_cubit.dart';
import 'package:whms/widgets/comment/file_view_widget.dart';
import 'package:whms/widgets/comment/textfield_comment.dart';
import 'package:whms/widgets/comment/video_view_widget.dart';
import 'package:whms/widgets/format_text_field/format_text_field_for_comment.dart';
import 'package:whms/widgets/z_space.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget(
      {super.key,
      required this.type,
      required this.position,
      this.afterSendAction});

  final String type;
  final String position;
  final Function(CommentModel)? afterSendAction;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    return BlocProvider(
      create: (context) => CommentCubit(context)..initData(type, position, ""),
      child: BlocBuilder<CommentCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CommentCubit>(c);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarItem(
                    user.avt,
                    size: 30,
                  ),
                  const ZSpace(w: 5),
                  Expanded(
                      child: FormatTextFieldForComment(
                          key: ValueKey(cubit.sendCmt),
                          initialContent: cubit.content.text,
                          cubit: cubit,
                          maxLines: 5,
                          onContentChanged: (v) {
                            cubit.content.text = v;
                            cubit.checkEmptyContent();
                          })),
                  Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButtonCustom(
                          fontSize: 16 * 1.2,
                          icon: Icons.send,
                          tooltip: AppText.textSendComment.text,
                          iconColor: ColorConfig.primary3,
                          isEnable: !cubit.isEmptyContent,
                          onTap: () async {
                            final newCmt = await cubit.sendComment();
                            if(afterSendAction != null) {
                              afterSendAction!(newCmt);
                            }
                          },
                        )
                      ])
                ],
              ),
              const ZSpace(h: 5),
              Padding(
                padding:
                    EdgeInsets.only(left: ScaleUtils.scaleSize(35, context)),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ...cubit.listImages.map((item) => Row(
                          key: ValueKey(item),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                      ScaleUtils.scaleSize(4, context)),
                                  child: Image.memory(
                                    Uint8List.fromList(item.bytes!),
                                    height: ScaleUtils.scaleSize(60, context),
                                    width: null,
                                  ),
                                ),
                                Positioned(
                                  right: ScaleUtils.scaleSize(2, context),
                                  top: ScaleUtils.scaleSize(2, context),
                                  child: CloseFileWidget(
                                    onClose: () {
                                      cubit.removeImages(item);
                                    },
                                  ),
                                )
                              ],
                            ),
                            const ZSpace(w: 5)
                          ],
                        ))
                  ],
                ),
              ),
              const ZSpace(h: 5),
              Padding(
                padding:
                    EdgeInsets.only(left: ScaleUtils.scaleSize(35, context)),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ...cubit.listVideos.map((item) => Row(
                          key: ValueKey(item),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                VideoViewWidget(
                                  title: item.name,
                                ),
                                Positioned(
                                  right: ScaleUtils.scaleSize(2, context),
                                  top: ScaleUtils.scaleSize(2, context),
                                  child: CloseFileWidget(
                                    onClose: () {
                                      cubit.removeVideos(item);
                                    },
                                  ),
                                )
                              ],
                            ),
                            const ZSpace(w: 5)
                          ],
                        ))
                  ],
                ),
              ),
              const ZSpace(h: 5),
              Padding(
                padding:
                    EdgeInsets.only(left: ScaleUtils.scaleSize(35, context)),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ...cubit.listFiles.map((item) => Row(
                          key: ValueKey(item),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FileViewWidget(
                              title: item.name,
                              onRemove: () {
                                cubit.removeFiles(item);
                              },
                            ),
                            const ZSpace(w: 5)
                          ],
                        ))
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
