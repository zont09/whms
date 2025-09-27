import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/comment/comment_cubit.dart';
import 'package:whms/widgets/z_space.dart';

class TextFieldComment extends StatelessWidget {
  const TextFieldComment(
      {super.key,
      required this.controller,
      this.radius = 229,
      required this.hint,
      this.minLines = 1,
      this.fontSize = 18,
      required this.isEdit,
      required this.cubit});

  final TextEditingController controller;
  final double radius;
  final String hint;
  final int? minLines;
  final bool isEdit;
  final double fontSize;
  final CommentCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(radius, context)),
          border: Border.all(
            width: ScaleUtils.scaleSize(0.5, context),
            color: const Color(0xFFA6A6A6),
          )),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enabled: isEdit,
                  minLines: 1,
                  maxLines: 3,
                  cursorColor: Colors.black,
                  cursorHeight: ScaleUtils.scaleSize(fontSize, context),
                  controller: controller,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(fontSize, context),
                      fontFamily: 'Afacad',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.41,
                      color: Colors.black),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: TextStyle(
                        fontSize: ScaleUtils.scaleSize(fontSize, context),
                        fontFamily: 'Afacad',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.41,
                        color: ColorConfig.hintText),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ScaleUtils.scaleSize(8, context),
                        horizontal: ScaleUtils.scaleSize(8, context)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent, // Màu viền
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent, // Màu viền
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent, // Màu viền
                      ),
                    ),
                  ),
                ),
                const ZSpace(h: 2),
                Row(
                  children: [
                    const ZSpace(w: 5),
                    IconButtonCustom(
                      fontSize: fontSize,
                      icon: Icons.image,
                      tooltip: AppText.textPickImage.text,
                      onTap: () async {
                        await cubit.pickImage();
                      },
                    ),
                    const ZSpace(w: 5),
                    IconButtonCustom(
                      fontSize: fontSize,
                      icon: Icons.video_camera_back_rounded,
                      tooltip: AppText.textPickVideo.text,
                      onTap: () async {
                        await cubit.pickVideo();
                      },
                    ),
                    const ZSpace(w: 5),
                    IconButtonCustom(
                      fontSize: fontSize,
                      icon: Icons.attachment,
                      tooltip: AppText.textPickFile.text,
                      onTap: () async {
                        await cubit.pickFile();
                      },
                    ),
                  ],
                ),
                const ZSpace(h: 4),
              ],
            ),
          ),
          const ZSpace(w: 9),
          IconButtonCustom(
            fontSize: fontSize * 1.2,
            icon: Icons.send,
            tooltip: AppText.textSendComment.text,
            iconColor: ColorConfig.primary3,
            onTap: () {
            },
          ),
          const ZSpace(w: 9),
        ],
      ),
    );
  }
}

class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom(
      {super.key,
      required this.fontSize,
      required this.tooltip,
      required this.icon,
      required this.onTap,
      this.iconColor = Colors.black,
      this.isEnable = true});

  final double fontSize;
  final String tooltip;
  final IconData icon;
  final Function() onTap;
  final Color iconColor;
  final bool isEnable;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            if(isEnable) {
              onTap();
            }
          },
          borderRadius: BorderRadius.circular(229),
          splashColor: isEnable ? Colors.grey.withOpacity(0.5) : Colors.transparent,
          hoverColor: Colors.grey.withOpacity(0.2),
          child: IntrinsicHeight(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.amber.withOpacity(0.2)
              ),
              child: Icon(icon,
                  size: ScaleUtils.scaleSize(fontSize, context),
                  color: isEnable ? iconColor : const Color(0xFF666666)),
            ),
          ),
        ),
      ),
    );
  }
}
