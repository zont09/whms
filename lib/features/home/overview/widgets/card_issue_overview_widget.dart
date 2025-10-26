// import 'package:whms/untils/app_text.dart';
// import 'package:whms/configs/color_config.dart';
// import 'package:daily/features/home/widget/issues/issue_widget/issue_type_view.dart';
// import 'package:daily/models/issue_model.dart';
// import 'package:whms/untils/date_time_utils.dart';
// import 'package:whms/untils/scale_utils.dart';
// import 'package:whms/widgets/z_space.dart';
// import 'package:flutter/material.dart';
//
// class CardIssueOverviewWidget extends StatelessWidget {
//   const CardIssueOverviewWidget(
//       {super.key, required this.issue});
//
//   final IssueModel issue;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
//           color: Colors.white,
//           boxShadow: const [ColorConfig.boxShadow2]),
//       padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             issue.title,
//             style: TextStyle(
//                 fontSize: ScaleUtils.scaleSize(12, context),
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: -0.02,
//                 color: ColorConfig.textColor,
//                 overflow: TextOverflow.ellipsis),
//             maxLines: 2,
//           ),
//           const ZSpace(h: 2),
//           Row(
//             children: [
//               Text(
//                 AppText.textTypeIssue.text,
//                 style: TextStyle(
//                     fontSize: ScaleUtils.scaleSize(12, context),
//                     fontWeight: FontWeight.w400,
//                     color: ColorConfig.textColor6,
//                     letterSpacing: -0.41),
//               ),
//               const ZSpace(w: 4),
//               IssueTypeView(issue: issue),
//             ],
//           ),
//           const ZSpace(h: 2),
//           Text(
//             DateTimeUtils.formatFullDateTime(issue.createAt.toDate()),
//             style: TextStyle(
//                 fontSize: ScaleUtils.scaleSize(12, context),
//                 fontWeight: FontWeight.w400,
//                 color: ColorConfig.textColor6,
//                 letterSpacing: -0.41),
//           ),
//         ],
//       ),
//     );
//   }
// }
