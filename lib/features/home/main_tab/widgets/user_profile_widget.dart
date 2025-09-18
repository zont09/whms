import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var user = ConfigsCubit.fromContext(context).user;
    return InkWell(
      onTap: () {
        context.go("${AppRoutes.profile}/${user.id}");
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarItem(user.avt, size: 45),
          SizedBox(width: ScaleUtils.scaleSize(10, context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleUtils.scaleSize(14, context),
                      fontWeight: FontWeight.w600)),
              // SizedBox(height: ScaleUtils.scaleSize(5, context)),
              Text(user.email,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleUtils.scaleSize(10, context),
                      fontWeight: FontWeight.w400))
            ],
          )
        ],
      ),
    );
  }
}
