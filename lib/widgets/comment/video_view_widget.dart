import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class VideoViewWidget extends StatelessWidget {
  const VideoViewWidget({super.key, required this.title, this.isAudio = false});

  final String title;
  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(ScaleUtils.scaleSize(4, context)),
        child: Container(
          width: ScaleUtils.scaleSize(90, context),
          height: ScaleUtils.scaleSize(60, context),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(ScaleUtils.scaleSize(6, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1.5, context),
                color: ColorConfig.border2),
          ),
          child: Column(
            children: [
              Container(
                height: ScaleUtils.scaleSize(40, context),
                width: double.infinity,
                child: Center(
                  child: Icon(
                    isAudio ? Icons.audio_file_outlined :
                    Icons.ondemand_video,
                    size: ScaleUtils.scaleSize(30, context),
                    color: ColorConfig.border2,
                  ),
                ),
              ),
              Container(
                height: ScaleUtils.scaleSize(1.5, context),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: ScaleUtils.scaleSize(1.5, context),
                          color: ColorConfig.border2,
                        ))),
              ),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(4, context)),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(10, context),
                            fontWeight: FontWeight.w500,
                            color: ColorConfig.textColor,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}