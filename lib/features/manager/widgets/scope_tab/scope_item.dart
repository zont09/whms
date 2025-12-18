import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/list_scope_cubit.dart';
import 'package:whms/features/manager/blocs/scope_item_cubit.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_choose_member_popup.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_creator.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_member.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/textfield_custom_2.dart';
import 'package:whms/widgets/z_space.dart';

class ScopeItem extends StatelessWidget {
  final ScopeModel model;
  final ScopeItemCubit cubit;

  ScopeItem(this.model, {super.key}) : cubit = ScopeItemCubit(model);

  @override
  Widget build(BuildContext context) {
    var reload = BlocProvider.of<ListScopeCubit>(context);
    return BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<ScopeItemCubit, int>(builder: (c, s) {
          TextEditingController conTitle =
              TextEditingController(text: cubit.scope.title);
          TextEditingController conDes =
              TextEditingController(text: cubit.scope.description);
          return Stack(children: [
            Container(
                key: Key(cubit.scope.id),
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scalePadding(24, context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFieldCustom2(
                                controller: conTitle,
                                onUpdate: (v) {
                                  cubit.updateTitle(v);
                                },
                                paddingContentVer: 0,
                                paddingContentHor: 0,
                                hint: AppText.textHintTypingTitle.text,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                textColor: Colors.black),
                            SizedBox(
                                height: ScaleUtils.scalePadding(5, context)),
                            TextFieldCustom2(
                                controller: conDes,
                                onUpdate: (v) {
                                  cubit.updateDescription(v);
                                },
                                paddingContentVer: 0,
                                paddingContentHor: 0,
                                hint: AppText.textHintTypingTitle.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black),
                            SizedBox(
                                height: ScaleUtils.scalePadding(5, context)),
                            Row(
                              children: [
                                Text(AppText.textManager.text,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(20, context),
                                        fontWeight: FontWeight.w500,
                                        color: ColorConfig.textColor6,
                                        letterSpacing: -0.41,
                                        shadows: const [
                                          ColorConfig.textShadow
                                        ])),
                                const ZSpace(w: 5),
                                InkWell(
                                  onTap: () {
                                    DialogUtils.showAlertDialog(context,
                                        child: ScopeChooseMemberPopup(
                                            updateMember: (v) {
                                              cubit.updateManagers(v);
                                            },
                                            selectedUsers:
                                                cubit.scope.selectedManagers,
                                            users: reload.listMember!));
                                  },
                                  child: Container(
                                    height: ScaleUtils.scaleSize(20, context),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: ScaleUtils.scaleSize(1.75, context),
                                        color: ColorConfig.primary2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.add, weight: 800, size: ScaleUtils.scaleSize(14, context), color: ColorConfig.primary2,),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                                height: ScaleUtils.scalePadding(5, context)),
                            Wrap(
                                spacing: ScaleUtils.scalePadding(10, context),
                                runSpacing:
                                    ScaleUtils.scalePadding(10, context),
                                direction: Axis.horizontal,
                                children: [
                                  ...cubit.scope.selectedManagers.map((user) =>
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ScopeMember(
                                                isSelected: true,
                                                onTap: () {
                                                  DialogUtils.showAlertDialog(
                                                      context,
                                                      child:
                                                          ScopeChooseMemberPopup(
                                                              key: Key(
                                                                  'p_managers_${cubit.scope.id}'),
                                                              updateMember:
                                                                  (v) {
                                                                cubit
                                                                    .updateManagers(
                                                                        v);
                                                              },
                                                              selectedUsers: cubit
                                                                  .scope
                                                                  .selectedManagers,
                                                              users: reload
                                                                  .listMember!));
                                                },
                                                user: user)
                                          ]))
                                ]),
                            SizedBox(
                                height: ScaleUtils.scalePadding(10, context)),
                            Row(
                              children: [
                                Text(AppText.titleMember.text,
                                    style: TextStyle(
                                        fontSize:
                                            ScaleUtils.scaleSize(20, context),
                                        fontWeight: FontWeight.w500,
                                        color: ColorConfig.textColor6,
                                        letterSpacing: -0.41,
                                        shadows: const [
                                          ColorConfig.textShadow
                                        ])),
                                const ZSpace(w: 5),
                                InkWell(
                                  onTap: () {
                                    DialogUtils.showAlertDialog(context,
                                        child: ScopeChooseMemberPopup(
                                            updateMember: (v) {
                                              cubit.updateMembers(v);
                                            },
                                            selectedUsers:
                                                cubit.scope.selectedMembers,
                                            users: reload.listMember!));
                                  },
                                  child: Container(
                                    height: ScaleUtils.scaleSize(20, context),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: ScaleUtils.scaleSize(1.75, context),
                                        color: ColorConfig.primary2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.add, weight: 800, size: ScaleUtils.scaleSize(14, context), color: ColorConfig.primary2,),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                                height: ScaleUtils.scalePadding(5, context)),
                            Wrap(
                                spacing: ScaleUtils.scalePadding(10, context),
                                runSpacing:
                                    ScaleUtils.scalePadding(10, context),
                                direction: Axis.horizontal,
                                children: [
                                  ...cubit.scope.selectedMembers.map((user) =>
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ScopeMember(
                                                isSelected: true,
                                                onTap: () {
                                                  DialogUtils.showAlertDialog(
                                                      context,
                                                      child:
                                                          ScopeChooseMemberPopup(
                                                              key: Key(
                                                                  'p_members_${cubit.scope.id}'),
                                                              updateMember:
                                                                  (v) {
                                                                cubit
                                                                    .updateMembers(
                                                                        v);
                                                              },
                                                              selectedUsers: cubit
                                                                  .scope
                                                                  .selectedMembers,
                                                              users: reload
                                                                  .listMember!));
                                                },
                                                user: user)
                                          ]))
                                ]),
                          ],
                        ),
                      ),

                      // const ZSpace(h: 10),
                      Divider(
                          indent: ScaleUtils.scaleSize(10, context),
                          thickness: ScaleUtils.scaleSize(1, context),
                          color: const Color(0x26000000)),
                      // padding: EdgeInsets.all(ScaleUtils.scalePadding(24, context)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scalePadding(24, context)),
                        child: ScopeCreator(cubit: cubit),
                      )
                    ])),
          ]);
        }));
  }
}
