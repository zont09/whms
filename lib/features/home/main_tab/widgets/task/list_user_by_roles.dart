import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/features/manager/widgets/scope_tab/list_member_dropdown.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class ListUserByRoles extends StatelessWidget {
  final DetailAssignCubit cubit;
  final bool isHandlerEdit;
  final bool isOwnerEdit;

  const ListUserByRoles(
      {required this.cubit,
      required this.isHandlerEdit,
      required this.isOwnerEdit,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (cubit.wu.workingPoint > 0 &&
          cubit.wu.type == TypeAssignmentDefine.task.title)
        IgnorePointer(
          ignoring: !isHandlerEdit,
          child: ListMemberDropdown(
              isAddAssigner: cubit.wu.type == TypeAssignmentDefine.task.title,
              key: Key(cubit.wu.id),
              items: cubit.listMember,
              selectedItems: cubit.selectedMembers,
              onTap: () {
                cubit.updateMembers();
              }),
        ),
      if (cubit.wu.workingPoint <= 0 &&
          cubit.wu.type == TypeAssignmentDefine.task.title)
        Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppText.titleAssignee.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(16, context),
                      fontWeight: FontWeight.w600,
                      letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                      color: ColorConfig.textColor)),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              InkWell(
                onTap: () {
                  if (cubit.wu.workingPoint < 1) {
                    ToastUtils.showBottomToast(
                        context, AppText.textSelectWorkingBeforeAssign.text);
                    return;
                  }
                },
                child: Card(
                    margin: EdgeInsets.zero,
                    elevation: ScaleUtils.scaleSize(3, context),
                    child: CircleAvatar(
                        backgroundColor: ColorConfig.primary3,
                        radius: ScaleUtils.scaleSize(10, context),
                        child: Icon(Icons.add,
                            color: Colors.white,
                            size: ScaleUtils.scaleSize(16, context)))),
              )
            ]),
      if(cubit.wu.type == TypeAssignmentDefine.task.title)
      IgnorePointer(
          ignoring: !isHandlerEdit,
          child: Wrap(
              runSpacing: ScaleUtils.scaleSize(5, context),
              spacing: ScaleUtils.scaleSize(5, context),
              children: [
                ...cubit.selectedMembers.map((user) => IntrinsicWidth(
                    child: ListMemberDropdown(
                        isAddAssigner:
                            cubit.wu.type == TypeAssignmentDefine.task.title,
                        height: 32,
                        items: cubit.listMember,
                        selectedItems: cubit.selectedMembers,
                        onTap: () {
                          if (cubit.wu.workingPoint < 1 &&
                              cubit.wu.type ==
                                  TypeAssignmentDefine.task.title) {
                            ToastUtils.showBottomToast(context,
                                AppText.textSelectWorkingBeforeAssign.text);
                            return;
                          }
                          cubit.updateMembers();
                        },
                        hintWidget: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius:
                                          ScaleUtils.scaleSize(2, context))
                                ]),
                            padding: EdgeInsets.only(
                              left: ScaleUtils.scaleSize(3, context),
                              right: ScaleUtils.scaleSize(10, context),
                              top: ScaleUtils.scaleSize(3, context),
                              bottom: ScaleUtils.scaleSize(3, context),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              AvatarItem(user.avt, size: 24),
                              SizedBox(
                                  width: ScaleUtils.scalePadding(10, context)),
                              Text(user.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          ScaleUtils.scaleSize(12, context)))
                            ])))))
              ])),
      IgnorePointer(
        ignoring: !isOwnerEdit,
        child: ListMemberDropdown(
            isAddAssigner: false,
            isAddFollowers: true,
            key: Key(cubit.wu.id),
            items: cubit.listMember,
            selectedItems: cubit.selectedFollowers,
            onTap: () {
              cubit.updateViewer();
            }),
      ),
      IgnorePointer(
          ignoring: !isOwnerEdit,
          child: Wrap(
              runSpacing: ScaleUtils.scaleSize(5, context),
              spacing: ScaleUtils.scaleSize(5, context),
              children: [
                ...cubit.selectedFollowers.map((user) => IntrinsicWidth(
                    child: ListMemberDropdown(
                        isAddAssigner:
                            cubit.wu.type == TypeAssignmentDefine.task.title,
                        height: 32,
                        items: cubit.listMember,
                        selectedItems: cubit.selectedFollowers,
                        onTap: () {
                          cubit.updateViewer();
                        },
                        hintWidget: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius:
                                          ScaleUtils.scaleSize(2, context))
                                ]),
                            padding: EdgeInsets.only(
                              left: ScaleUtils.scaleSize(3, context),
                              right: ScaleUtils.scaleSize(10, context),
                              top: ScaleUtils.scaleSize(3, context),
                              bottom: ScaleUtils.scaleSize(3, context),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              AvatarItem(user.avt, size: 24),
                              SizedBox(
                                  width: ScaleUtils.scalePadding(10, context)),
                              Text(user.name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          ScaleUtils.scaleSize(12, context)))
                            ])))))
              ]))
    ]);
  }
}
