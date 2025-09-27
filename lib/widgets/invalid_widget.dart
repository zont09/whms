import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class InvalidWidget extends StatelessWidget {
  const InvalidWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
      ),
      child: Container(
        width: ScaleUtils.scaleSize(500, context),
        height: ScaleUtils.scaleSize(500 * 730 / 1550, context),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
              child: Image.asset(
                'assets/images/img_invalid.png',
                width: ScaleUtils.scaleSize(500, context),
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.only(
                  bottom: ScaleUtils.scaleSize(15, context),
                  right: ScaleUtils.scaleSize(15, context)),
              child: ZButton(
                  paddingVer: 5,
                  title: AppText.btnBackHome.text,
                  icon: '',
                  onPressed: () => context.go(AppRoutes.mainTab),
                  isShadow: true),
            )
          ],
        ),
      ),
    );
  }
}
