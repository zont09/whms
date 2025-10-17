import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/editable_text_widget.dart';
import 'package:whms/widgets/mouse_click_popup.dart';
import 'package:whms/widgets/select_icon_and_emoji/select_icon_and_emoji_popup.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TitleView extends StatelessWidget {
  const TitleView({
    super.key,
    required this.isOwnerEdit,
    required this.cubit,
    required this.call,
    required this.conName,
  });

  final bool isOwnerEdit;
  final DetailAssignCubit cubit;
  final Function(String p1)? call;
  final TextEditingController conName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (cubit.wu.type == TypeAssignmentDefine.task.title)
          MouseClickPopup(
              key: MouseClickPopup.popupKey,
              width: ScaleUtils.scaleSize(250, context),
              height: ScaleUtils.scaleSize(400, context),
              popup: SelectIconAndEmojiPopup(onSelect: (v) {
                cubit.updateIconForTask(v);
                MouseClickPopup.popupKey.currentState?.removeOverlay();
              }),
              child: Container(
                child: cubit.avtTask == null
                    ? Image.asset(
                        'assets/images/icons/task_icon/icon/ic_task.png',
                        height: ScaleUtils.scaleSize(25, context),
                        color: ColorConfig.primary3,
                      )
                    : (cubit.avtTask!.isNotEmpty
                        ? Image.asset(cubit.avtTask!,
                            height: ScaleUtils.scaleSize(25, context),
                            color: cubit.avtTask!.contains("emoji")
                                ? null
                                : ColorConfig.primary3)
                        : Image.asset(
                            'assets/images/icons/task_icon/icon/ic_task.png',
                            height: ScaleUtils.scaleSize(25, context),
                            color: ColorConfig.primary3,
                          )),
              )),
        if (cubit.wu.type == TypeAssignmentDefine.epic.title)
          AbsorbPointer(
            key: Key("key_avt_epic_${cubit.avtWork?.bytes}"),
            absorbing: !isOwnerEdit,
            child: InkWell(
              onTap: () async {
                final image =
                    await FileUtils.pickFile(fileType: FileType.image);
                if (image != null) {
                  cubit.updateIcon(image);
                }
              },
              child: Container(
                height: ScaleUtils.scaleSize(26, context),
                width: ScaleUtils.scaleSize(26, context),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: ScaleUtils.scaleSize(1, context),
                        color: ColorConfig.border7)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(229),
                  child: cubit.state == 0
                      ? const CircularProgressIndicator(
                          color: ColorConfig.primary3)
                      : (cubit.avtWork != null
                          ? Image.memory(cubit.avtWork!.bytes!,
                              height: ScaleUtils.scaleSize(25, context))
                          : Image.asset('assets/images/icons/ic_epic.png',
                              height: ScaleUtils.scaleSize(25, context))),
                ),
              ),
            ),
          ),
        if (cubit.wu.type == TypeAssignmentDefine.epic.title ||
            cubit.wu.type == TypeAssignmentDefine.task.title)
          const ZSpace(w: 9),
        Expanded(
          child: EditableTextWidget(
              isPermissionEdit: isOwnerEdit,
              text: cubit.wu.title,
              type: cubit.wu.type,
              textStyle: TextStyle(
                  color: ColorConfig.textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.02 * 16, context),
                  fontSize: ScaleUtils.scaleSize(16, context)),
              onSubmit: (v) {
                cubit.updateTitle(v);
                call!(v);
              },
              controller: conName),
        ),
      ],
    );
  }
}
