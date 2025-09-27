import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/comment_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/comment/attachments_comment_view.dart';
import 'package:whms/widgets/comment/comment_view_cubit.dart';
import 'package:whms/widgets/comment/textfield_comment.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';
import 'package:whms/widgets/z_space.dart';

class CommentView extends StatelessWidget {
  const CommentView(
      {super.key,
      required this.comment,
      required this.owner,
      this.mapFile,
      this.afterDeleteAction});

  final CommentModel comment;
  final UserModel owner;
  final Map<String, PlatformFile>? mapFile;
  final Function(CommentModel)? afterDeleteAction;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    return BlocProvider(
      create: (context) => CommentViewCubit()..initData(comment),
      child: BlocBuilder<CommentViewCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CommentViewCubit>(c);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarItem(owner.avt,
                      size: ScaleUtils.scaleSize(20, context)),
                  const ZSpace(w: 5),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(owner.name,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(14, context),
                              fontWeight: FontWeight.w600,
                              color: ColorConfig.textColor6,
                              overflow: TextOverflow.ellipsis)),
                      Text(
                          DateTimeUtils.formatFullDateTime(
                              comment.date.toDate()),
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w400,
                              color: ColorConfig.hintText,
                              overflow: TextOverflow.ellipsis))
                    ],
                  )),
                  Row(
                    children: [
                      // if (!cubit.isEdit)
                      //   IconButtonCustom(
                      //       fontSize: 16,
                      //       tooltip: AppText.textReply.text,
                      //       icon: Icons.reply,
                      //       onTap: () {}),
                      if (user.id == owner.id) const ZSpace(w: 5),
                      if (user.id == owner.id && !cubit.isEdit)
                        IconButtonCustom(
                            fontSize: 16,
                            tooltip: AppText.textEdit.text,
                            icon: Icons.edit_outlined,
                            onTap: () {
                              cubit.changeEdit(true);
                            }),
                      if (user.id == owner.id) const ZSpace(w: 5),
                      if (user.id == owner.id && !cubit.isEdit)
                        IconButtonCustom(
                            fontSize: 16,
                            tooltip: AppText.textDelete.text,
                            icon: Icons.delete_outline,
                            onTap: () async {
                              bool confirmDel =
                                  await DialogUtils.showConfirmDialog(
                                      context,
                                      AppText.titleConfirmDelete.text,
                                      AppText.textConfirmDeleteComment.text);
                              if (!confirmDel) return;
                              if (context.mounted) {
                                DialogUtils.showLoadingDialog(context);
                              }
                              await CommentService.instance.updateComment(
                                  comment.copyWith(enable: false));
                              if (afterDeleteAction != null) {
                                afterDeleteAction!(comment);
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  const ZSpace(w: 25),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(!cubit.isEdit)
                      Container(
                        key: ValueKey(cubit.comment),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ScaleUtils.scaleSize(8, context)),
                              border: Border.all(
                                  width: ScaleUtils.scaleSize(1, context),
                                  color: ColorConfig.border4)),
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(12, context),
                              vertical: ScaleUtils.scaleSize(4, context)),
                          child:FormatTextView(
                                  content: cubit.comment!.content,
                                  fontSize: 12,
                                )),
                      if(cubit.isEdit)
                        FormatTextField(
                            initialContent: cubit.comment!.content,
                            onContentChanged: (v) {
                              cubit.commentEdited = v;
                            }),
                      const ZSpace(h: 9),
                      if (cubit.isEdit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ZButton(
                                title: AppText.btnCancel.text,
                                sizeTitle: 14,
                                radius: 8,
                                colorBorder: ColorConfig.border4,
                                colorTitle: ColorConfig.textColor,
                                colorBackground: Colors.transparent,
                                paddingVer: 4,
                                icon: "",
                                onPressed: () {
                                  cubit.cancelEdit();
                                }),
                            const ZSpace(w: 8),
                            ZButton(
                                title: AppText.btnUpdate.text,
                                icon: "",
                                sizeTitle: 14,
                                radius: 8,
                                paddingVer: 4,
                                onPressed: () {
                                  cubit.edit();
                                }),
                          ],
                        ),
                      if (!cubit.isEdit)
                        AttachmentsCommentView(comment: comment, cubit: cubit),
                    ],
                  ))
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
