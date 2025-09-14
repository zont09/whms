import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/blocs/choose_members_cubit.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_member.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/search_field.dart';

class ScopeChooseMemberPopup extends StatelessWidget {
  final List<UserModel> users;
  final List<UserModel> selectedUsers;
  final Function(List<UserModel>) updateMember;
  const ScopeChooseMemberPopup(
      {required this.users,
      required this.selectedUsers,
      required this.updateMember,
      super.key});

  @override
  Widget build(BuildContext context) {
    var conSearch = TextEditingController();
    return BlocProvider(
      create: (context) => ChooseMembersCubit(users, selectedUsers),
      child: BlocBuilder<ChooseMembersCubit, int>(builder: (c, s) {
        var cubit = BlocProvider.of<ChooseMembersCubit>(c);
        return SizedBox(
          width: ScaleUtils.scaleSize(400, context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ScaleUtils.scaleSize(20, context)),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(20, context)),
                height: ScaleUtils.scaleSize(40, context),
                child: SearchField(
                    controller: conSearch, onChanged: (v) => cubit.search(v)),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: ScaleUtils.scaleSize(10, context)),
                    ...cubit.listUsers.map(
                      (user) => InkWell(
                        onTap: () {
                          cubit.chooseMember(user);
                          updateMember(cubit.selectedUsers);
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(30, context),
                                vertical: ScaleUtils.scaleSize(3, context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ScopeMember(
                                  isShowScope: true,
                                    isSelected: true, onTap: () {}, user: user),
                                Icon(
                                    user.isSelected
                                        ? Icons.check_box_outlined
                                        : Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: ScaleUtils.scaleSize(24, context))
                              ],
                            )),
                      ),
                    ),
                    SizedBox(height: ScaleUtils.scaleSize(20, context))
                  ],
                ),
              ))
            ],
          ),
        );
      }),
    );
  }
}
