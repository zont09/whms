import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/member_item.dart';

class CreatorWidget extends StatelessWidget {
  final DetailAssignCubit cubit;
  final UserModel user;
  const CreatorWidget({required this.cubit, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        if (!cubit.wu.scopes.contains(cubit.wu.owner))
          MemberItem(
              onTap: () {},
              user: user
              ),
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
                  border:
                  Border.all(color: ColorConfig.primary3),
                  borderRadius: BorderRadius.circular(
                      ScaleUtils.scaleSize(1000, context))),
              child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius:
                        ScaleUtils.scaleSize(12, context),
                        backgroundColor: ColorConfig.primary3,
                        child: Text(
                          cubit.ownerScope?.title ?? AppText.textUnknown.text
                              .substring(0, 2)
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScaleUtils.scaleSize(
                                  12, context)),
                        ),
                      ),
                      SizedBox(
                          width: ScaleUtils.scaleSize(
                              5, context)),
                      Text(cubit.ownerScope?.title ?? AppText.textUnknown.text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: ColorConfig.primary3,
                              fontSize: ScaleUtils.scaleSize(
                                  16, context),
                              fontWeight: FontWeight.w600,
                              letterSpacing:
                              ScaleUtils.scaleSize(
                                  -0.41, context)))
                    ])
                  ]))
      ],
    );
  }
}
