import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/task/recommend/recommend_button.dart';
import 'package:whms/features/manager/widgets/scope_tab/list_member_dropdown.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/user_model.dart';

class ListUserByRoles extends StatelessWidget {
  final DetailAssignCubit cubit;
  final bool isHandlerEdit;
  final bool isOwnerEdit;

  const ListUserByRoles({
    required this.cubit,
    required this.isHandlerEdit,
    required this.isOwnerEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cubit.wu.workingPoint > 0 &&
            cubit.wu.type == TypeAssignmentDefine.task.title)
          IgnorePointer(
            ignoring: !isHandlerEdit,
            child: ListMemberDropdownForDetailAssignment(
              isAddAssigner: cubit.wu.type == TypeAssignmentDefine.task.title,
              key: Key(cubit.wu.id),
              items: cubit.listMember,
              selectedItems: cubit.selectedMembers,
              onTap: () {
                cubit.updateMembers();
              },
              task: cubit.wu,
              isHandlerEdit: isHandlerEdit,
            ),
          ),
        if (cubit.wu.workingPoint <= 0 &&
            cubit.wu.type == TypeAssignmentDefine.task.title)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppText.titleAssignee.text,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textColor,
                ),
              ),
              SizedBox(width: ScaleUtils.scaleSize(10, context)),
              InkWell(
                onTap: () {
                  if (cubit.wu.workingPoint < 1) {
                    ToastUtils.showBottomToast(
                      context,
                      AppText.textSelectWorkingBeforeAssign.text,
                    );
                    return;
                  }
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: ScaleUtils.scaleSize(3, context),
                  child: CircleAvatar(
                    backgroundColor: ColorConfig.primary3,
                    radius: ScaleUtils.scaleSize(10, context),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: ScaleUtils.scaleSize(16, context),
                    ),
                  ),
                ),

              ),
              const ZSpace(w: 12),
              if(cubit.wu.type == TypeAssignmentDefine.task.title)
                IgnorePointer(
                  ignoring: !isHandlerEdit,
                  child: EmployeeRecommendationIconButton(task: cubit.wu),
                ),
            ],
          ),

        if (cubit.wu.type == TypeAssignmentDefine.task.title)
          IgnorePointer(
            ignoring: !isHandlerEdit,
            child: Wrap(
              runSpacing: ScaleUtils.scaleSize(5, context),
              spacing: ScaleUtils.scaleSize(5, context),
              children: [
                ...cubit.selectedMembers.map(
                  (user) => IntrinsicWidth(
                    child: ListMemberDropdown(
                      isAddAssigner:
                          cubit.wu.type == TypeAssignmentDefine.task.title,
                      height: 32,
                      items: cubit.listMember,
                      selectedItems: cubit.selectedMembers,
                      onTap: () {
                        if (cubit.wu.workingPoint < 1 &&
                            cubit.wu.type == TypeAssignmentDefine.task.title) {
                          ToastUtils.showBottomToast(
                            context,
                            AppText.textSelectWorkingBeforeAssign.text,
                          );
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
                              blurRadius: ScaleUtils.scaleSize(2, context),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.only(
                          left: ScaleUtils.scaleSize(3, context),
                          right: ScaleUtils.scaleSize(10, context),
                          top: ScaleUtils.scaleSize(3, context),
                          bottom: ScaleUtils.scaleSize(3, context),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AvatarItem(user.avt, size: 24),
                            SizedBox(
                              width: ScaleUtils.scalePadding(10, context),
                            ),
                            Text(
                              user.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: ScaleUtils.scaleSize(12, context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
            },
          ),
        ),
        IgnorePointer(
          ignoring: !isOwnerEdit,
          child: Wrap(
            runSpacing: ScaleUtils.scaleSize(5, context),
            spacing: ScaleUtils.scaleSize(5, context),
            children: [
              ...cubit.selectedFollowers.map(
                (user) => IntrinsicWidth(
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
                            blurRadius: ScaleUtils.scaleSize(2, context),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                        left: ScaleUtils.scaleSize(3, context),
                        right: ScaleUtils.scaleSize(10, context),
                        top: ScaleUtils.scaleSize(3, context),
                        bottom: ScaleUtils.scaleSize(3, context),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarItem(user.avt, size: 24),
                          SizedBox(width: ScaleUtils.scalePadding(10, context)),
                          Text(
                            user.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: ScaleUtils.scaleSize(12, context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListMemberDropdownForDetailAssignment extends StatelessWidget {
  final List<UserModel> items;
  final List<UserModel> selectedItems;
  final Function() onTap;
  final TextEditingController textEditingController;
  final Widget? hintWidget;
  final double height;
  final bool isShowHint;
  final bool isAddAssigner;
  final bool isAddFollowers;
  final bool canSelectAssignee;
  final WorkingUnitModel task;
  final bool isHandlerEdit;

  ListMemberDropdownForDetailAssignment({
    required this.items,
    this.hintWidget,
    this.isShowHint = true,
    required this.selectedItems,
    required this.onTap,
    this.height = 42,
    this.isAddAssigner = false,
    this.isAddFollowers = false,
    this.canSelectAssignee = true,
    required this.task,
    required this.isHandlerEdit,
    super.key,
  }) : textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var config = context.read<ConfigsCubit>();
    List<DropdownMenuItem<UserModel>> dropdownItems = items
        .map(
          (item) => DropdownMenuItem<UserModel>(
        value: item,
        child: DropdownMenuItem(
          value: item,
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              var isSelected = selectedItems.contains(item);
              final validKey = item.scopes.firstWhere(
                    (key) => config.allScopeMap[key] != null,
                orElse: () => '',
              );
              return InkWell(
                onTap: () {
                  isSelected
                      ? selectedItems.remove(item)
                      : selectedItems.add(item);
                  if (isAddAssigner) {
                    if (!isSelected) {
                      selectedItems.clear();
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                  }
                  menuSetState(() {});
                  onTap();
                },
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(16, context),
                  ),
                  child: Row(
                    children: [
                      AvatarItem(item.avt, size: 32),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.scopes.isNotEmpty &&
                                config.allScopeMap[validKey] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScaleUtils.scaleSize(
                                    5,
                                    context,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1000),
                                  color: ColorConfig.primary2,
                                ),
                                child: Text(
                                  '${config.allScopeMap[validKey]!.title} ${item.scopes.length - 1 == 0 ? '' : '+${item.scopes.length - 1}'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScaleUtils.scaleSize(
                                      8,
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              item.name,
                              style: TextStyle(
                                height: 1,
                                fontSize: ScaleUtils.scaleSize(14, context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank,
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(16, context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    )
        .toList();

    return Row(
      key: ValueKey(selectedItems.hashCode),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ScaleUtils.scaleSize(height, context),
          child: IntrinsicWidth(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<UserModel>(
                isExpanded: true,
                iconStyleData: IconStyleData(icon: Container()),
                hint: hintWidget ?? hintButton(context, isHint: true),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: ScaleUtils.scaleSize(50, context),
                  searchInnerWidget: Container(
                    height: ScaleUtils.scaleSize(50, context),
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: AppText.titleSearch.text,
                        hintStyle: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(8, context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) => item.value!.name
                      .toString()
                      .toLowerCase()
                      .contains(searchValue.toLowerCase()),
                ),
                dropdownStyleData: DropdownStyleData(
                  width: ScaleUtils.scaleSize(300, context),
                  maxHeight: ScaleUtils.scaleSize(500, context),
                ),
                items: dropdownItems,
                value: selectedItems.isEmpty ? null : selectedItems.last,
                onChanged: (value) {},
                selectedItemBuilder: (context) =>
                    items.map((item) => hintWidget ?? hintButton(context)).toList(),
                buttonStyleData: ButtonStyleData(
                  height: ScaleUtils.scaleSize(height, context),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: ScaleUtils.scaleSize(height, context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
        // Tách icon AI ra ngoài dropdown
        if (task.type == TypeAssignmentDefine.task.title && isHandlerEdit)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: EmployeeRecommendationIconButton(task: task),
          ),
      ],
    );
  }

  Widget hintButton(context, {bool isHint = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isHint
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (isShowHint)
          Text(
            isAddFollowers
                ? AppText.titleFollowers.text
                : AppText.titleAssignee.text,
            style: TextStyle(
              fontSize: ScaleUtils.scaleSize(16, context),
              fontWeight: FontWeight.w600,
              letterSpacing: ScaleUtils.scaleSize(-0.33, context),
              color: ColorConfig.textColor,
            ),
          ),
        if (isShowHint) SizedBox(width: ScaleUtils.scaleSize(10, context)),
        Card(
          margin: EdgeInsets.zero,
          elevation: ScaleUtils.scaleSize(3, context),
          child: CircleAvatar(
            backgroundColor: ColorConfig.primary3,
            radius: ScaleUtils.scaleSize(10, context),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: ScaleUtils.scaleSize(16, context),
            ),
          ),
        ),
        // Xóa icon AI khỏi đây
      ],
    );
  }
}
