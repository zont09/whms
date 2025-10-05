import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class MoreOptionMeetingButton extends StatelessWidget {
  const MoreOptionMeetingButton(
      {super.key, this.onUpdate, this.onDelete, this.afterAction});

  final Function()? onUpdate;
  final Function()? onDelete;
  final Function()? afterAction;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
        style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(4),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                side: BorderSide(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border))),
            padding: WidgetStateProperty.all(EdgeInsets.zero)),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Image.asset('assets/images/icons/ic_expand.png',
                height: ScaleUtils.scaleSize(16, context)),
          );
        },
        menuChildren: [
          if (onUpdate != null)
            ItemMoreOption(
              title: AppText.textEdit.text,
              icon: "assets/images/icons/ic_edit.png",
              onPressed: onUpdate!,
              afterAction: afterAction,
              isConfirm: false,
              ctx: context,
            ),
          if (onDelete != null)
            ItemMoreOption(
              title: AppText.textDelete.text,
              icon: "assets/images/icons/ic_delete.png",
              onPressed: onDelete!,
              afterAction: afterAction,
              isConfirm: true,
              ctx: context,
            ),
        ]);
  }
}

class ItemMoreOption extends StatelessWidget {
  const ItemMoreOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.afterAction,
    required this.isConfirm,
    required this.ctx,
  });

  final String title;
  final String icon;
  final Function() onPressed;
  final Function()? afterAction;
  final bool isConfirm;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: IntrinsicHeight(
            // Wrap với IntrinsicHeight
            child: MenuItemButton(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () async {
                  bool isOk = true;
                  if (isConfirm) {
                    isOk = await DialogUtils.showConfirmDialog(
                        ctx,
                        AppText.titleConfirm.text,
                        AppText.textConfirmDelete.text);
                  }
                  if (!isOk) return;
                  await onPressed();
                  if (afterAction != null) {
                    await afterAction!();
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(12, context),
                        vertical: ScaleUtils.scaleSize(6, context)),
                    child: Row(
                      children: [
                        Image.asset(icon,
                            height: ScaleUtils.scaleSize(12, context),
                            color: ColorConfig.textColor),
                        const ZSpace(w: 3),
                        Text(title,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(10, context),
                                color: ColorConfig.textColor)),
                      ],
                    )))));
  }
}
