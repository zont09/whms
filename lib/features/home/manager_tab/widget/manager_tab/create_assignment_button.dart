import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class CreateAssignmentButton extends StatelessWidget {
  final String title;
  final String icon;
  final Function() onTap;
  const CreateAssignmentButton(
      {required this.title,
      required this.onTap,
      this.icon = 'assets/images/icons/ic_epic.png',
      super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          decoration:
              const BoxDecoration(gradient: ColorConfig.gradientPrimary4),
          padding:
              EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(15, context)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              title,
              style: TextStyle(
                  shadows: [
                    BoxShadow(
                        blurRadius: ScaleUtils.scaleSize(3, context),
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                  ],
                  color: Colors.white,
                  fontSize: ScaleUtils.scaleSize(15, context),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(width: ScaleUtils.scaleSize(10, context)),
            Container(
                width: ScaleUtils.scaleSize(16, context),
                height: ScaleUtils.scaleSize(16, context),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: ScaleUtils.scaleSize(3, context),
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(0, ScaleUtils.scaleSize(2, context)))
                    ]),
                child: Icon(Icons.add,
                    size: ScaleUtils.scaleSize(12, context),
                    color: ColorConfig.primary3))
          ])),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  splashColor: Colors.grey.withOpacity(0.3), onTap: onTap)))
    ]);
  }
}
