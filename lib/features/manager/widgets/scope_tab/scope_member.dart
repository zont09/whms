import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class ScopeMember extends StatelessWidget {
  final bool isSelected;
  final Function() onTap;
  final UserModel user;
  final bool isShowScope;

  const ScopeMember({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.user,
    this.isShowScope = false,
  });

  @override
  Widget build(BuildContext context) {
    final mapScope = ConfigsCubit.fromContext(context).allScopeMap;
    final listScope =
        user.scopes.where((e) => mapScope[e] != null).map((e) => mapScope[e]!);
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1000),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: ScaleUtils.scaleSize(2, context))
              ]),
          padding: EdgeInsets.only(
              left: ScaleUtils.scaleSize(3, context),
              right: ScaleUtils.scaleSize(10, context),
              top: ScaleUtils.scaleSize(3, context),
              bottom: ScaleUtils.scaleSize(3, context)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AvatarItem(user.avt, size: 24),
            SizedBox(width: ScaleUtils.scalePadding(10, context)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isShowScope && listScope.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(229),
                        color: ColorConfig.primary2),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(4, context),
                        vertical: ScaleUtils.scaleSize(0, context)),
                    child: Text(
                        "${listScope.first.title}${listScope.length > 1 ? " +${listScope.length - 1}" : ""}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: ScaleUtils.scaleSize(9, context))),
                  ),
                Text(user.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: ScaleUtils.scaleSize(12, context))),
              ],
            )
          ])),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(1000), onTap: onTap)))
    ]);
  }
}
