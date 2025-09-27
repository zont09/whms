import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/views/task/form_category_title.dart';
import 'package:whms/features/home/main_tab/widgets/task/choose_datetime_item.dart';
import 'package:whms/features/home/main_tab/widgets/task/choose_multiple_scope.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_priority_dropdown.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_type_dropdown.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_working_point_dropdown.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/assignment_popup_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class CreateAssignmentForm extends StatelessWidget {
  final AssignmentPopupCubit cubit;
  final bool isSubtask;
  final bool isSub;
  final int typeAssignment;
  final List<String> ancestries;

  const CreateAssignmentForm(
      {required this.cubit,
      required this.isSubtask,
      this.isSub = false,
      this.ancestries = const [],
      required this.typeAssignment,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(30, context),
              vertical: ScaleUtils.scaleSize(30, context)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    isSubtask
                        ? AppText.titleCreateSubtask.text
                        : AppText.titleCreateAssignment.text,
                    style: TextStyle(
                        shadows: [
                          BoxShadow(
                              blurRadius: ScaleUtils.scaleSize(2, context),
                              color: const Color(0x1A000000),
                              offset:
                                  Offset(0, ScaleUtils.scaleSize(2, context)))
                        ],
                        color: ColorConfig.textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: ScaleUtils.scaleSize(-0.41, context),
                        fontSize: ScaleUtils.scaleSize(20, context))),
                SizedBox(height: ScaleUtils.scaleSize(5, context)),
                if (!isSubtask)
                  Row(children: [
                    FormCategoryTitle(AppText.titleChooseTypeOfAssignment.text),
                    AbsorbPointer(
                        absorbing: typeAssignment == 1000,
                        child: ListAssignmentDropdown(
                            selector: cubit.selectedType,
                            items: TypeAssignmentDefineExtension.listType(
                                typeAssignment),
                            onChanged: (v) => cubit.chooseType(v!)))
                  ]),
                SizedBox(height: ScaleUtils.scaleSize(10, context)),
                FormCategoryTitle(AppText.titleName.text),
                SizedBox(height: ScaleUtils.scaleSize(5, context)),
                InputField(
                    hintText: AppText.hintInputNameAssignment.text.replaceAll(
                        '@', cubit.selectedType.title.toLowerCase()),
                    controller: cubit.conName),
                SizedBox(height: ScaleUtils.scaleSize(10, context)),
                FormCategoryTitle(AppText.titleDescription.text),
                SizedBox(height: ScaleUtils.scaleSize(5, context)),
                FormatTextField(
                  initialContent: cubit.conDes.text,
                    fixedLines: 6,
                    onContentChanged: (v) => cubit.conDes.text = v),
                SizedBox(height: ScaleUtils.scaleSize(10, context)),
                if (isSub && ancestries.isNotEmpty)
                  Row(children: [
                    FormCategoryTitle(AppText.titleLink.text),
                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                    Expanded(
                        child: Row(children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: ScaleUtils.scaleSize(5, context),
                              horizontal: ScaleUtils.scaleSize(10, context)),
                          decoration: BoxDecoration(
                              color: ColorConfig.primary5,
                              borderRadius: BorderRadius.circular(1000)),
                          child: Row(children: [
                            ...ancestries.map((e) => Tooltip(
                                message: e,
                                child: Text(
                                    '$e${ancestries.indexOf(e) != ancestries.length - 1 ? ' > ' : ''}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: ColorConfig.primary1,
                                        fontSize: ScaleUtils.scaleSize(
                                            10, context)))))
                          ]))
                    ]))
                  ]),
                if (isSub && ancestries.isNotEmpty)
                  SizedBox(height: ScaleUtils.scaleSize(10, context)),
                Row(children: [
                  // if (cubit.selectedType != TypeAssignmentDefine.epic &&
                  //     cubit.selectedType != TypeAssignmentDefine.story &&
                  //     cubit.selectedType != TypeAssignmentDefine.okrs )
                  //   Row(children: [
                  //     FormCategoryTitle(AppText.titleStartDate.text),
                  //     SizedBox(width: ScaleUtils.scaleSize(10, context)),
                  //     ChooseDatetimeItem(
                  //         icon: 'assets/images/icons/ic_calendar3.png',
                  //         controller: cubit.conStartDate,
                  //         initialStart: DateTime.now(),
                  //         onTap: (v) => cubit.buildUI()),
                  //     SizedBox(width: ScaleUtils.scaleSize(20, context))
                  //   ]),
                  if (cubit.selectedType != TypeAssignmentDefine.epic &&
                      cubit.selectedType != TypeAssignmentDefine.okrs)
                    Row(children: [
                      FormCategoryTitle(cubit.selectedType.title !=
                              TypeAssignmentDefine.story.title && cubit.selectedType.title !=
                          TypeAssignmentDefine.task.title
                          ? AppText.titleEndDate.text
                          : AppText.titleDeadline.text),
                      SizedBox(width: ScaleUtils.scaleSize(10, context)),
                      ChooseDatetimeItem(
                          icon: 'assets/images/icons/ic_calendar3.png',
                          controller: cubit.conEndDate,
                          initialStart: DateTime.now(),
                          onTap: (v) => cubit.buildUI())
                    ])
                ]),
                SizedBox(height: ScaleUtils.scaleSize(10, context)),
                if (cubit.selectedType == TypeAssignmentDefine.okrs)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChooseMultipleScope(
                            title: AppText.titleChooseScope.text,
                            items: cubit.listScope,
                            selectedItems: cubit.selectedScope,
                            onTap: () => cubit.buildUI()),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          ...cubit.selectedScope.map((e) => Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  right: ScaleUtils.scaleSize(5, context)),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ScaleUtils.scaleSize(10, context)),
                              height: ScaleUtils.scaleSize(28, context),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1000),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                        color: Colors.black.withOpacity(0.2))
                                  ]),
                              child: Text(e.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      letterSpacing:
                                          ScaleUtils.scaleSize(-0.33, context),
                                      fontSize:
                                          ScaleUtils.scaleSize(12, context),
                                      color: ColorConfig.textColor))))
                        ]),
                        SizedBox(height: ScaleUtils.scaleSize(10, context)),
                        // ChooseMultipleScope(
                        //     title: AppText.titleChooseGroupOKRs.text,
                        //     items: cubit.listOkrsGroup,
                        //     selectedItems: cubit.selectedScopeOkrs,
                        //     onTap: () => cubit.buildUI()),
                        // Row(mainAxisSize: MainAxisSize.min, children: [
                        //   ...cubit.selectedScopeOkrs.map((e) => Container(
                        //       alignment: Alignment.center,
                        //       margin: EdgeInsets.only(
                        //           right: ScaleUtils.scaleSize(5, context)),
                        //       padding: EdgeInsets.symmetric(
                        //           horizontal:
                        //           ScaleUtils.scaleSize(10, context)),
                        //       height: ScaleUtils.scaleSize(28, context),
                        //       decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(1000),
                        //           boxShadow: [
                        //             BoxShadow(
                        //                 blurRadius: 2,
                        //                 offset: const Offset(0, 1),
                        //                 color: Colors.black.withOpacity(0.2))
                        //           ]),
                        //       child: Text(e.title,
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.w500,
                        //               letterSpacing:
                        //               ScaleUtils.scaleSize(-0.33, context),
                        //               fontSize:
                        //               ScaleUtils.scaleSize(12, context),
                        //               color: ColorConfig.textColor))))
                        // ])
                      ]),
                if (cubit.selectedType == TypeAssignmentDefine.task)
                  Row(children: [
                    FormCategoryTitle(AppText.titleSettingWorkingUnit.text
                        .replaceAll('@', cubit.selectedType.title)),
                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                    ListPriorityDropdown(
                        selector: cubit.selectedPriority,
                        onChanged: (v) => cubit.choosePriority(v!)),
                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                    ChooseDatetimeItem(
                        controller: cubit.conExecuteDate,
                        initialStart: DateTime.now(),
                        onTap: (v) {}),
                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                    if (cubit.selectedType == TypeAssignmentDefine.task)
                      ListWorkingPointDropdown(
                          selector: cubit.selectedWP,
                          onChanged: (v) => cubit.chooseWP(v!))
                  ])
              ])),
    );
  }
}
