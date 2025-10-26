import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:flutter/material.dart';

class OVIssueListView extends StatelessWidget {
  const OVIssueListView({
    super.key,
    required this.cubit,
  });

  final OverviewTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    // final bool isNoDataIssue = cubit.sprintSelected.isNotEmpty ||
    //     ((cubit.epicSelected.isNotEmpty &&
    //             (!cubit.mapListIssue
    //                     .containsKey('epic_${cubit.epicSelected}') ||
    //                 cubit.mapListIssue['epic_${cubit.epicSelected}']!
    //                     .isEmpty)) ||
    //         (cubit.epicSelected.isEmpty &&
    //             (!cubit.mapListIssue
    //                     .containsKey('scope_${cubit.scopeSelected}') ||
    //                 cubit.mapListIssue['scope_${cubit.scopeSelected}']!
    //                     .isEmpty)));
    return const SizedBox.shrink();
    // return Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         AppText.titleListIssue.text,
    //         style: TextStyle(
    //             fontSize: ScaleUtils.scaleSize(16, context),
    //             fontWeight: FontWeight.w600,
    //             letterSpacing: -0.02,
    //             color: ColorConfig.textColor,
    //             shadows: const [ColorConfig.textShadow]),
    //       ),
    //       const ZSpace(h: 9),
    //       if (cubit.loadingIssue > 0)
    //         const Center(
    //           child: CircularProgressIndicator(
    //             color: ColorConfig.primary3,
    //           ),
    //         ),
    //       if (cubit.loadingIssue == 0 &&
    //           cubit.epicSelected.isNotEmpty &&
    //           cubit.sprintSelected.isEmpty &&
    //           !isNoDataIssue)
    //         ...cubit.mapListIssue['epic_${cubit.epicSelected}']!.take(3).map(
    //             (item) => Column(children: [
    //                   CardIssueOverviewWidget(issue: item),
    //                   const ZSpace(h: 8)
    //                 ])),
    //       if (cubit.loadingIssue == 0 &&
    //           cubit.epicSelected.isEmpty &&
    //           cubit.sprintSelected.isEmpty &&
    //           !isNoDataIssue)
    //         ...cubit.mapListIssue['scope_${cubit.scopeSelected}']!.take(3).map(
    //             (item) => Column(children: [
    //                   CardIssueOverviewWidget(issue: item),
    //                   const ZSpace(h: 8)
    //                 ])),
    //       if (cubit.loadingIssue == 0 &&
    //           cubit.epicSelected.isNotEmpty &&
    //           cubit.sprintSelected.isEmpty &&
    //           !isNoDataIssue &&
    //           cubit.mapListIssue['epic_${cubit.epicSelected}']!.length > 3)
    //         Align(
    //             alignment: Alignment.centerRight,
    //             child: InkWell(
    //                 onTap: () {
    //                   context.go(
    //                       '${AppRoutes.issues}/${cubit.scopeSelected}&${cubit.epicSelected}');
    //                 },
    //                 child: Text(
    //                   AppText.textViewMore.text,
    //                   style: TextStyle(
    //                       fontSize: ScaleUtils.scaleSize(14, context),
    //                       fontWeight: FontWeight.w600,
    //                       color: ColorConfig.textColor6,
    //                       decoration: TextDecoration.underline,
    //                       decorationColor: ColorConfig.textColor6),
    //                 ))),
    //       if (cubit.loadingIssue == 0 &&
    //           cubit.epicSelected.isEmpty &&
    //           cubit.sprintSelected.isEmpty &&
    //           !isNoDataIssue &&
    //           cubit.mapListIssue['scope_${cubit.scopeSelected}']!.length > 3)
    //         Align(
    //             alignment: Alignment.centerRight,
    //             child: InkWell(
    //                 onTap: () {
    //                   context.go('${AppRoutes.issues}/${cubit.scopeSelected}');
    //                 },
    //                 child: Text(
    //                   AppText.textViewMore.text,
    //                   style: TextStyle(
    //                       fontSize: ScaleUtils.scaleSize(14, context),
    //                       fontWeight: FontWeight.w600,
    //                       color: ColorConfig.textColor6,
    //                       decoration: TextDecoration.underline,
    //                       decorationColor: ColorConfig.textColor6),
    //                 ))),
    //       if (cubit.loadingIssue == 0 && isNoDataIssue)
    //         NoDataWidget(
    //             imgSize: 60,
    //             fontSizeTitle: 16,
    //             fontSizeContent: 12,
    //             data: "thông tin")
    //     ]);
  }
}
