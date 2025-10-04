import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/attachment_files_view.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/detail_assign_more.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/detail_assignment_setting.dart';
import 'package:whms/features/home/main_tab/views/task/list_scope_in_detail.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/title_view.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_user_by_roles.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_choose_member_popup.dart';
import 'package:whms/main.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/format_text_field/editable_format_text_field.dart';
import 'package:whms/widgets/member_item.dart';
import 'package:whms/widgets/path_view.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailAssignmentView extends StatelessWidget {
  final WorkingUnitModel model;
  final Color background;
  final List<UserModel> assignees;
  final Function(WorkingUnitModel) reload;
  final Function()? endEvent;
  final Function(WorkingUnitModel)? edited;
  final Function(String)? call;
  final DetailAssignCubit cubit;
  final List<ScopeModel> allScopes;
  final int isTaskToday;
  final Function(WorkingUnitModel)? onDoToday;
  final Function(WorkingUnitModel)? onRemoveToday;
  final Function(WorkingUnitModel)? onDoing;
  final Function(WorkingUnitModel, WorkingUnitModel)? onUpdate;
  final List<WorkingUnitModel> listPath;
  final Function(WorkingUnitModel)? onTapPath;
  final UserModel userCf;
  final ConfigsCubit cfC;

  DetailAssignmentView(this.model, this.assignees, this.allScopes,
      {this.background = Colors.amber,
      required this.reload,
      this.endEvent,
      this.call,
      this.edited,
      this.isTaskToday = 0,
      this.onDoToday,
      this.onRemoveToday,
      this.onDoing,
      this.onUpdate,
      this.listPath = const [],
      this.onTapPath,
      required this.userCf,
      required this.cfC,
      super.key})
      : cubit = DetailAssignCubit(model, userCf, cfC)
          ..init(allScopes, cfC.mapWorkChild);

  @override
  Widget build(BuildContext context) {
    final configCubit = ConfigsCubit.fromContext(context);
    return BlocListener<ConfigsCubit, ConfigsState>(
      listenWhen: (pre, cur) => cur.updatedEvent == ConfigStateEvent.task,
      listener: (cc, ss) {
        if (ss.updatedEvent == ConfigStateEvent.task &&
            ss.data is WorkingUnitModel &&
            ss.data.id == cubit.wu.id) {
          cubit.wu = ss.data;
          cubit.buildUI();
        }
      },
      child: BlocBuilder<DetailAssignCubit, int>(
          bloc: cubit,
          key: Key(cubit.key),
          builder: (c, s) {
            TextEditingController conDes =
                TextEditingController(text: cubit.wu.description);
            TextEditingController conName =
                TextEditingController(text: cubit.wu.title);
            return Padding(
                padding: EdgeInsets.only(
                    left: ScaleUtils.scaleSize(20, context),
                    top: ScaleUtils.scaleSize(10, context),
                    right: ScaleUtils.scaleSize(15, context)),
                child: Stack(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (listPath.isNotEmpty)
                          PathWorkingUnitView(
                              listPath: listPath.reversed.toList(),
                              onTap: onTapPath),
                        if (listPath.isNotEmpty) const ZSpace(h: 10),
                        TitleView(
                            isOwnerEdit: isOwnerEdit,
                            cubit: cubit,
                            call: call,
                            conName: conName),
                        SizedBox(height: ScaleUtils.scaleSize(10, context)),
                        DetailAssignmentSetting(
                            cubit: cubit,
                            isHandlerEdit: isHandlerEdit,
                            onUpdate: onUpdate,
                            isOwnerEdit: isOwnerEdit),
                        SizedBox(height: ScaleUtils.scaleSize(10, context)),
                        Text(AppText.titleDescription.text,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(16, context),
                                fontWeight: FontWeight.w600,
                                letterSpacing:
                                    ScaleUtils.scaleSize(-0.33, context),
                                color: ColorConfig.textColor)),
                        EditableFormatTextField(
                            isPermissionEdit: isHandlerEdit,
                            text: cubit.wu.description,
                            textStyle: TextStyle(
                                color: ColorConfig.textColor,
                                fontWeight: FontWeight.w400,
                                letterSpacing:
                                    ScaleUtils.scaleSize(-0.02 * 16, context),
                                fontSize: ScaleUtils.scaleSize(16, context)),
                            onSubmit: (v) {
                              cubit.updateDescription(v);
                            },
                            controller: conDes),
                        SizedBox(height: ScaleUtils.scaleSize(10, context)),
                        AttachmentFilesView(
                          work: cubit.wu,
                          onUpdate: onUpdate ?? (v, o) {},
                        ),
                        SizedBox(height: ScaleUtils.scaleSize(20, context)),
                        // CreatorWidget(
                        //     cubit: cubit,
                        //     user: configs.usersMap[cubit.wu.owner]),
                        Row(
                          children: [
                            Text(
                                cubit.wu.scopes.contains(cubit.wu.owner)
                                    ? AppText.headerOwner.text
                                    : AppText.titleCreator.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(16, context),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing:
                                        ScaleUtils.scaleSize(-0.33, context),
                                    color: ColorConfig.textColor)),
                            SizedBox(width: ScaleUtils.scaleSize(10, context)),
                            if (!cubit.wu.scopes.contains(cubit.wu.owner) &&
                                configs.usersMap.containsKey(cubit.wu.owner))
                              MemberItem(
                                  onTap: () {},
                                  user: configs.usersMap[cubit.wu.owner]),
                            if (cubit.wu.scopes.contains(cubit.wu.owner))
                              cubit.ownerScope == null
                                  ? const CircularProgressIndicator()
                                  : Container(
                                      padding: EdgeInsets.all(
                                          ScaleUtils.scaleSize(4, context)),
                                      decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x26000000),
                                              offset: Offset(1, 1),
                                              blurRadius: 5.9,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          color: Colors.white,
                                          border: Border.all(
                                              color: ColorConfig.primary3),
                                          borderRadius: BorderRadius.circular(
                                              ScaleUtils.scaleSize(
                                                  1000, context))),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              CircleAvatar(
                                                radius: ScaleUtils.scaleSize(
                                                    12, context),
                                                backgroundColor:
                                                    ColorConfig.primary3,
                                                child: Text(
                                                  cubit.ownerScope?.title ??
                                                      AppText.textUnknown.text
                                                          .substring(0, 2)
                                                          .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          ScaleUtils.scaleSize(
                                                              12, context)),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: ScaleUtils.scaleSize(
                                                      5, context)),
                                              Text(
                                                  cubit.ownerScope?.title ??
                                                      AppText.textUnknown.text,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color:
                                                          ColorConfig.primary3,
                                                      fontSize:
                                                          ScaleUtils.scaleSize(
                                                              16, context),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing:
                                                          ScaleUtils.scaleSize(
                                                              -0.41, context)))
                                            ])
                                          ]))
                          ],
                        ),
                        SizedBox(height: ScaleUtils.scaleSize(10, context)),
                        ListUserByRoles(
                            cubit: cubit,
                            isHandlerEdit: isHandlerEdit,
                            isOwnerEdit: isOwnerEdit),
                        if (cubit.wu.type != TypeAssignmentDefine.task.title)
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppText.titleAssigner.text,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(16, context),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: ScaleUtils.scaleSize(
                                            -0.33, context),
                                        color: ColorConfig.textColor)),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(10, context)),
                                InkWell(
                                  onTap: () {
                                    DialogUtils.showAlertDialog(context,
                                        child: ScopeChooseMemberPopup(
                                            users: configCubit.allUsers
                                                .where((e) => e.scopes.any(
                                                    (f) => cubit.wu.scopes
                                                        .contains(f)))
                                                .toList(),
                                            selectedUsers:
                                                cubit.selectedHandlers,
                                            updateMember: (v) {
                                              cubit.updateHandlers();
                                            }));
                                  },
                                  child: Card(
                                      margin: EdgeInsets.zero,
                                      elevation:
                                          ScaleUtils.scaleSize(3, context),
                                      child: CircleAvatar(
                                          backgroundColor: ColorConfig.primary3,
                                          radius:
                                              ScaleUtils.scaleSize(10, context),
                                          child: Icon(Icons.add,
                                              color: Colors.white,
                                              size: ScaleUtils.scaleSize(
                                                  16, context)))),
                                ),
                              ]),
                        if (cubit.wu.type != TypeAssignmentDefine.task.title)
                          const ZSpace(h: 10),
                        if (cubit.wu.type != TypeAssignmentDefine.task.title)
                          Wrap(children: [
                            ...cubit.wu.handlers.map((e) => Container(
                                margin: EdgeInsets.only(
                                    right: ScaleUtils.scaleSize(5, context),
                                    bottom: ScaleUtils.scaleSize(5, context)),
                                child: MemberItem(
                                    onTap: () {},
                                    user: configCubit.usersMap[e] ??
                                        UserModel(
                                            name: AppText.textUnknown.text))))
                          ]),
                        if (cubit.wu.type != TypeAssignmentDefine.task.title &&
                            cubit.wu.type != TypeAssignmentDefine.subtask.title)
                          ListScopeInDetail(
                              isPermission: cubit.wu.type ==
                                      TypeAssignmentDefine.okrs.title
                                  ? isHandlerEdit
                                  : isOwnerEdit,
                              cubit.selectedScopes, updateScopes: (v) {
                            cubit.updateScopes(v);
                          }),
                        if (cubit.wu.type == TypeAssignmentDefine.task.title)
                          const ZSpace(h: 9),
                        // if (cubit.wu.type == TypeAssignmentDefine.task.title)
                        //   CommentTaskView(
                        //       work: cubit.wu,
                        //       listComment: cubit.listComments,
                        //       isLoading: cubit.loadingComment > 0,
                        //       afterSendAction: (v) {
                        //         cubit.addNewComment(v);
                        //       },
                        //       afterDeleteAction: (v) {
                        //         cubit.deleteComment(v);
                        //       })
                      ]),
                  DetailAssignMore(
                      cubit: cubit,
                      endEvent: endEvent,
                      isTaskToday: isTaskToday,
                      edited: edited,
                      reload: reload,
                      onDoToday: onDoToday ?? (v) {},
                      onRemoveToday: onRemoveToday ?? (v) {},
                      onDoing: onDoing ?? (v) {},
                      onUpdate: onUpdate ?? (v, o) {},
                      userId: configs.user.id)
                ]));
          }),
    );
  }

  dynamic get configs => getIt<ConfigsCubit>();

  bool get isOwnerEdit =>
      cubit.wu.owner == configs.user.id ||
      cubit.wu.handlers.contains(configs.user.id);

  bool get isHandlerEdit =>
      cubit.wu.owner == configs.user.id ||
      cubit.wu.assignees.contains(configs.user.id);
}
