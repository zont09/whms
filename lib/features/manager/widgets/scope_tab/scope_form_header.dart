import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class ScopeFormHeader extends StatelessWidget {
  final String id;
  final bool isSubScope;
  final Function() onTap;
  const ScopeFormHeader(
      {required this.id,
      required this.isSubScope,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: ScaleUtils.scalePadding(10, context)),
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scalePadding(5, context)),
          decoration: BoxDecoration(
              color: isSubScope ? ColorConfig.primary2 : ColorConfig.primary1,
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scalePadding(5, context))),
          child: Text(
            'ID - ${isSubScope ? 'SubScope' : 'Scope'} $id',
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
        if (isSubScope)
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: ScaleUtils.scalePadding(10, context)),
                padding: EdgeInsets.symmetric(
                    vertical: ScaleUtils.scaleSize(2, context),
                    horizontal: ScaleUtils.scaleSize(10, context)),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: ScaleUtils.scaleSize(4, context),
                          offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                    ],
                    borderRadius: BorderRadius.circular(1000),
                    color: ColorConfig.redState),
                child: Text(AppText.btnRemoveSubScope.text,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: ScaleUtils.scaleSize(12, context))),
              ),
              Positioned.fill(
                  bottom: ScaleUtils.scalePadding(10, context),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(1000),
                      onTap: onTap,
                    ),
                  ))
            ],
          )
      ],
    );
  }
}
