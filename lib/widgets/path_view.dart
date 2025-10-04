import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/widgets/personal/task_preview.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart' show ScaleUtils;
import 'package:whms/widgets/hover_text.dart';
import 'package:whms/widgets/mouse_hover_popup.dart';

class PathWorkingUnitView extends StatelessWidget {
  const PathWorkingUnitView({
    super.key,
    required this.listPath,
    this.onTap,
  });

  final List<WorkingUnitModel> listPath;
  final Function(WorkingUnitModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            top: ScaleUtils.scaleSize(5, context)),
        child: Row(children: [
          ...listPath.map((e) => Row(children: [
                MousePopup(
                  width: 400,
                  popupContent: TaskPreview(task: e, width: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.type,
                          style: TextStyle(
                              height: 1,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              fontSize: ScaleUtils.scaleSize(7, context))),
                      HoverText(
                          text: e.title,
                          onTap: () {
                            if (onTap != null) {
                              onTap!(e);
                            }
                          })
                    ],
                  ),
                ),
                if (listPath.indexOf(e) != listPath.length - 1)
                  Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ScaleUtils.scaleSize(5, context),
                        horizontal: ScaleUtils.scaleSize(7, context),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                              opacity: 0,
                              child: Text('/',
                                  style: TextStyle(
                                      height: 1,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                      fontSize:
                                          ScaleUtils.scaleSize(7, context)))),
                          Text('/',
                              style: TextStyle(
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.primary1,
                                  fontSize: ScaleUtils.scaleSize(11, context)))
                        ],
                      ))
              ])),
        ]));
  }
}
