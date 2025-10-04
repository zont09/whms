import 'package:flutter/material.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class MemberItem extends StatelessWidget {
  final Function() onTap;
  final UserModel user;
  final bool isSelected;
  const MemberItem(
      {required this.onTap,
      required this.user,
      this.isSelected = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: ScaleUtils.scaleSize(2, context),
                  )
                ]),
            padding: EdgeInsets.only(
              left: ScaleUtils.scaleSize(3, context),
              right: ScaleUtils.scaleSize(10, context),
              top: ScaleUtils.scaleSize(3, context),
              bottom: ScaleUtils.scaleSize(3, context),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AvatarItem(user.avt, size: 24),
              SizedBox(width: ScaleUtils.scalePadding(10, context)),
              Text(user.name,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: ScaleUtils.scaleSize(12, context))),
              if (isSelected)
                Container(
                    margin: EdgeInsets.only(
                        right: ScaleUtils.scalePadding(12, context)),
                    child: Image.asset('assets/images/icons/ic_check.png',
                        width: ScaleUtils.scaleSize(20, context),
                        height: ScaleUtils.scaleSize(20, context)))
            ])),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(1000),
            onTap: onTap,
          ),
        ))
      ],
    );
  }
}
