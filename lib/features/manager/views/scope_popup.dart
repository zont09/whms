import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/scope_form_cubit.dart';
import 'package:whms/features/manager/widgets/scope_tab/list_member_dropdown.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/input_field.dart';
import 'package:whms/widgets/two_buttons.dart';

class ScopePopup extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScopePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScopeFormCubit(),
      child: BlocBuilder<ScopeFormCubit, int>(builder: (c, s) {
        var cubit = BlocProvider.of<ScopeFormCubit>(c);
        return SizedBox(
          width: ScaleUtils.scaleSize(600, context),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(30, context),
                vertical: ScaleUtils.scaleSize(30, context)),
            child: Form(
              key: _formKey,
              child: Column(//mainAxisSize: MainAxisSize.min,
                children: [
                  ...cubit.scopes.map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InputField(
                              hintText: AppText.hintInputScopeName.text
                                  .replaceAll(
                                      '@', true ? 'sub_scope' : 'scope'),
                              controller: e.titleController),
                          SizedBox(height: ScaleUtils.scaleSize(10, context)),
                          InputField(
                              hintText: AppText.hintInputScopeDescription.text
                                  .replaceAll(
                                      '@', true ? 'sub_scope' : 'scope'),
                              controller: e.desController),
                          SizedBox(height: ScaleUtils.scaleSize(10, context)),
                          ListMemberDropdown(
                              key: Key('manager_${e.id}'),
                              items: cubit.listMember,
                              hintWidget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                      Text(AppText.titleManager.text,
                                          style: TextStyle(
                                              fontSize: ScaleUtils.scaleSize(16, context),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                                              color: ColorConfig.textColor)),
                                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                                    Card(
                                        margin: EdgeInsets.zero,
                                        elevation: ScaleUtils.scaleSize(3, context),
                                        child: CircleAvatar(
                                            backgroundColor: ColorConfig.primary3,
                                            radius: ScaleUtils.scaleSize(10, context),
                                            child: Icon(Icons.add,
                                                color: Colors.white,
                                                size: ScaleUtils.scaleSize(16, context))))
                                  ]),
                              selectedItems: e.selectedManagers,
                              onTap: () =>
                                  cubit.updateManagers(e, isCreate: true)),
                          Wrap(
                              runSpacing: ScaleUtils.scaleSize(5, context),
                              spacing: ScaleUtils.scaleSize(5, context),
                              children: [
                                ...e.selectedManagers.map((user) =>
                                    IntrinsicWidth(
                                        child: ListMemberDropdown(
                                            items: cubit.listMember,
                                            selectedItems: e.selectedManagers,
                                            onTap: () => cubit.updateMembers(e,
                                                isCreate: true),
                                            hintWidget: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          blurRadius: ScaleUtils
                                                              .scaleSize(
                                                                  2, context))
                                                    ]),
                                                padding: EdgeInsets.only(
                                                    left: ScaleUtils.scaleSize(
                                                        3, context),
                                                    right: ScaleUtils.scaleSize(
                                                        10, context),
                                                    top: ScaleUtils.scaleSize(
                                                        3, context),
                                                    bottom:
                                                        ScaleUtils.scaleSize(
                                                            3, context)),
                                                child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      AvatarItem(user.avt,
                                                          size: 24),
                                                      SizedBox(
                                                          width: ScaleUtils
                                                              .scalePadding(
                                                              10, context)),
                                                      Text(user.name,
                                                          style: TextStyle(
                                                              color:
                                                              Colors.black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                              fontSize: ScaleUtils
                                                                  .scaleSize(12,
                                                                  context)))
                                                    ])))))
                              ]),
                          SizedBox(height: ScaleUtils.scaleSize(10, context)),
                          ListMemberDropdown(
                              key: Key(e.id),
                              items: cubit.listMember,
                              hintWidget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(AppText.titleAssigner.text,
                                        style: TextStyle(
                                            fontSize: ScaleUtils.scaleSize(16, context),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                                            color: ColorConfig.textColor)),
                                    SizedBox(width: ScaleUtils.scaleSize(10, context)),
                                    Card(
                                        margin: EdgeInsets.zero,
                                        elevation: ScaleUtils.scaleSize(3, context),
                                        child: CircleAvatar(
                                            backgroundColor: ColorConfig.primary3,
                                            radius: ScaleUtils.scaleSize(10, context),
                                            child: Icon(Icons.add,
                                                color: Colors.white,
                                                size: ScaleUtils.scaleSize(16, context))))
                                  ]),
                              selectedItems: e.selectedMembers,
                              onTap: () =>
                                  cubit.updateMembers(e, isCreate: true)),
                          Wrap(
                              runSpacing: ScaleUtils.scaleSize(5, context),
                              spacing: ScaleUtils.scaleSize(5, context),
                              children: [
                                ...e.selectedMembers.map((user) =>
                                    IntrinsicWidth(
                                        child: ListMemberDropdown(
                                            items: cubit.listMember,
                                            selectedItems: e.selectedMembers,
                                            onTap: () => cubit.updateMembers(e,
                                                isCreate: true),
                                            hintWidget: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        1000),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          blurRadius: ScaleUtils
                                                              .scaleSize(
                                                              2, context))
                                                    ]),
                                                padding: EdgeInsets.only(
                                                    left: ScaleUtils.scaleSize(
                                                        3, context),
                                                    right: ScaleUtils.scaleSize(
                                                        10, context),
                                                    top: ScaleUtils.scaleSize(
                                                        3, context),
                                                    bottom:
                                                    ScaleUtils.scaleSize(
                                                        3, context)),
                                                child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      AvatarItem(user.avt,
                                                          size: 24),
                                                      SizedBox(
                                                          width: ScaleUtils
                                                              .scalePadding(
                                                              10, context)),
                                                      Text(user.name,
                                                          style: TextStyle(
                                                              color:
                                                              Colors.black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                              fontSize: ScaleUtils
                                                                  .scaleSize(12,
                                                                  context)))
                                                    ])))))
                              ]),
                        ],
                      )),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TwoButtons(
                          titleCancel: AppText.btnCancel.text,
                          titleOK: AppText.btnCreate.text,
                          onCancel: () {
                            Navigator.pop(context);
                          },
                          onOK: () async {
                            if (_formKey.currentState!.validate()) {
                              for (int i = 0; i < cubit.scopes.length; i++) {
                                var s = cubit.scopes[i];
                                ScopeModel sm = ScopeModel(
                                  id: s.id,
                                  title: s.titleController.text,
                                  owner: s.owner,
                                  parentScope: s.parentScope,
                                  managers: s.managers,
                                  members: s.members,
                                  description: s.desController.text,
                                  documents: s.documents,
                                  viewers: s.viewers,
                                  enable: true,
                                  shares: s.shares,
                                );
                                cubit.scopes[i] = sm;
                              }
                              await cubit.createScopes(context);
                            } else {
                              debugPrint('Có lỗi trong form');
                            }
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
