import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/comment_type_define.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/comment_view.dart';
import 'package:whms/widgets/comment/comment_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CommentTaskView extends StatelessWidget {
  const CommentTaskView(
      {super.key,
      required this.work,
      required this.listComment,
      required this.isLoading,
      required this.afterSendAction,
      required this.afterDeleteAction});

  final WorkingUnitModel work;
  final List<CommentModel> listComment;
  final bool isLoading;
  final Function(CommentModel) afterSendAction;
  final Function(CommentModel) afterDeleteAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.titleComment.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w600,
                letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                color: ColorConfig.textColor)),
        const ZSpace(h: 9),
          CommentWidget(
            type: CommentTypeDefine.workingUnit.value.toString(),
            position: "${CommentTypeDefine.workingUnit.title}_${work.id}",
            afterSendAction: (v) {
              afterSendAction(v);
            },
          ),
        const ZSpace(h: 9),
        if (isLoading) const ZSpace(h: 9),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: ColorConfig.primary3,
            ),
          ),
        if (!isLoading)
          ...listComment.map((item) => Column(
                children: [
                  CommentView(
                      key: ValueKey(item),
                      comment: item,
                      owner: ConfigsCubit.fromContext(context)
                              .usersMap[item.owner] ??
                          UserModel(name: AppText.textUnknown.text),
                  afterDeleteAction: afterDeleteAction,),
                  const ZSpace(h: 12)
                ],
              ))
      ],
    );
  }
}
