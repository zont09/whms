import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/select_icon_and_emoji/select_icon_and_emoji_popup_cubit.dart';
import 'package:whms/widgets/z_space.dart';

class SelectIconAndEmojiPopup extends StatelessWidget {
  const SelectIconAndEmojiPopup({super.key, required this.onSelect});

  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectIconAndEmojiPopupCubit()..initData(context),
      child: BlocBuilder<SelectIconAndEmojiPopupCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<SelectIconAndEmojiPopupCubit>(c);
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  boxShadow: const [ColorConfig.boxShadow2],
                  color: Colors.white),
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(20, context),
                  vertical: ScaleUtils.scaleSize(12, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppText.titleIcon.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(14, context),
                          fontWeight: FontWeight.w500,
                          color: ColorConfig.textColor6,
                          shadows: const [ColorConfig.textShadow],
                          letterSpacing: -0.02)),
                  const ZSpace(h: 5),
                  Wrap(
                      direction: Axis.horizontal,
                      runSpacing: ScaleUtils.scaleSize(8, context),
                      spacing: ScaleUtils.scaleSize(8, context),
                      children: [
                        if (cubit.pathIcon.isEmpty)
                          ...List.generate(
                              20,
                              (i) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: ScaleUtils.scaleSize(20, context),
                                      height: ScaleUtils.scaleSize(20, context),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )),
                        if (cubit.pathIcon.isNotEmpty)
                          ...cubit.pathIcon.map((e) => InkWell(
                                onTap: () {
                                  onSelect(e);
                                },
                                child: Container(
                                    child: Image.asset(e,
                                        height:
                                            ScaleUtils.scaleSize(22, context), color: ColorConfig.primary3,)),
                              ))
                      ]),
                  const ZSpace(h: 15),
                  Text(AppText.titleEmoji.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(14, context),
                          fontWeight: FontWeight.w500,
                          color: ColorConfig.textColor6,
                          shadows: const [ColorConfig.textShadow],
                          letterSpacing: -0.02)),
                  const ZSpace(h: 5),
                  Wrap(
                      direction: Axis.horizontal,
                      runSpacing: ScaleUtils.scaleSize(8, context),
                      spacing: ScaleUtils.scaleSize(8, context),
                      children: [
                        if (cubit.pathEmoji.isEmpty)
                          ...List.generate(
                              40,
                                  (i) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: ScaleUtils.scaleSize(20, context),
                                  height: ScaleUtils.scaleSize(20, context),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )),
                        if (cubit.pathEmoji.isNotEmpty)
                          ...cubit.pathEmoji.map((e) => InkWell(
                            onTap: () {
                              onSelect(e);
                            },
                            child: Container(
                                child: Image.asset(e,
                                    height:
                                    ScaleUtils.scaleSize(22, context))),
                          ))
                      ])
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
