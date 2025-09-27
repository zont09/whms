import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/checkin/widgets/task_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class TaskPreview extends StatelessWidget {
  const TaskPreview({super.key, required this.task, required this.width});

  final WorkingUnitModel task;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(width, context),
      // decoration: BoxDecoration(
      //     borderRadius:
      //         BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
      //     color: Colors.white,
      //     boxShadow: const [ColorConfig.boxShadow]),
      // padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor,
                letterSpacing: -0.41,
                overflow: TextOverflow.ellipsis),
            maxLines: 1,
          ),
          const ZSpace(h: 4),
          Row(
            children: [
              StatusCard(status: task.status),
              const ZSpace(w: 5),
              if(task.priority.isNotEmpty)
              PriorityViewWidget(work: task),
            ],
          ),
          const ZSpace(h: 4),
          Text(
            AppText.titleDescription.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(12, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor6,
                shadows: const [ColorConfig.textShadow],
                letterSpacing: -0.41,
                overflow: TextOverflow.ellipsis),
            maxLines: 1,
          ),
          const ZSpace(h: 4),
          FormatTextView(
            content: task.description,
            fontSize: 10,
            maxLines: 2,
          )
        ],
      ),
    );
  }
}
