import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
//
// class HistoryCardWidget extends StatefulWidget {
//   const HistoryCardWidget({super.key, required this.data, required this.cubit});
//
//   final WorkHistoryData data;
//   final WorkHistoryCubit cubit;
//
//   @override
//   State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
// }
//
// class _HistoryCardWidgetState extends State<HistoryCardWidget> {
//   bool isExpand = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final List<int> weight = [12, 15, 15, 15, 12, 12, 12, 1];
//     return Container(
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
//           color: Colors.white,
//           boxShadow: const [ColorConfig.boxShadow2]),
//       padding: EdgeInsets.symmetric(
//           horizontal: ScaleUtils.scaleSize(16, context),
//           vertical: ScaleUtils.scaleSize(12, context)),
//       child: Column(
//         children: [
//           AbsorbPointer(
//             absorbing: widget.data.numOfTask <= 0,
//             child: InkWell(
//               onTap: () {
//                 switch (widget.data.numOfTask) {
//                   case > 0:
//                     setState(() {
//                       isExpand = !isExpand;
//                     });
//                 }
//               },
//               child: Row(
//                 children: [
//                   Expanded(
//                       flex: weight[0],
//                       child: Text(
//                         widget.data.date,
//                         style: TextStyle(
//                             fontSize: ScaleUtils.scaleSize(14, context),
//                             fontWeight: FontWeight.w500,
//                             color: ColorConfig.textColor,
//                             letterSpacing: -0.02),
//                       )),
//                   Expanded(
//                       flex: weight[1],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(
//                             content: widget.data.logTime,
//                             background: widget.data.background,
//                           ),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[2],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(content: widget.data.workingPoint),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[3],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(
//                               content: widget.data.numOfTask.toString() +
//                                   " nhiệm vụ"),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[4],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(content: widget.data.checkIn),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[5],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(content: widget.data.checkOut),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[6],
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CardView(content: widget.data.sumBreak),
//                         ],
//                       )),
//                   Expanded(
//                       flex: weight[7],
//                       child: widget.data.numOfTask > 0
//                           ? Align(
//                               alignment: Alignment.centerRight,
//                               child: Icon(
//                                 isExpand
//                                     ? Icons.keyboard_arrow_up
//                                     : Icons.keyboard_arrow_down,
//                                 size: ScaleUtils.scaleSize(20, context),
//                                 color: const Color(0xFF646464),
//                               ),
//                             )
//                           : Container()),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 229),
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               return SizeTransition(
//                 sizeFactor: animation,
//                 axisAlignment: 0.0,
//                 child: FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 ),
//               );
//             },
//             child: isExpand
//                 ? ExpandWorkHistoryWidget(
//                     cubit: widget.cubit, date: widget.data.date)
//                 : const SizedBox.shrink(
//                     key: ValueKey<bool>(false),
//                   ),
//           )
//         ],
//       ),
//     );
//   }
// }

class CardView extends StatelessWidget {
  const CardView({
    super.key,
    required this.content,
    this.background = Colors.white,
    this.textColor = ColorConfig.textColor,
    this.borderColor = ColorConfig.border4
  });

  final String content;
  final Color background;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: borderColor),
            color: background),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(11, context),
            vertical: ScaleUtils.scaleSize(2, context)),
        child: Text(
          content.isEmpty ? "-" : content,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(12, context),
              fontWeight: FontWeight.w500,
              color: textColor),
        ),
      ),
    );
  }
}

class WorkHistoryData {
  final String date;
  final String logTime;
  final String workingPoint;
  final int numOfTask;
  final String checkIn;
  final String checkOut;
  final String sumBreak;
  final Color background;

  WorkHistoryData(this.date, this.logTime, this.workingPoint, this.numOfTask,
      this.checkIn, this.checkOut, this.sumBreak, this.background);
}
