import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class LoginInfoView extends StatelessWidget {
  const LoginInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(left: ScaleUtils.scalePadding(0, context)),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: ColorConfig.primary4,
        // padding: EdgeInsets.symmetric(
        //     horizontal: ScaleUtils.scaleSize(150, context)),
        child: Container(
          width: ScaleUtils.scaleSize(591, context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Text(
                    AppText.titleLoginSlogan.text,
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(40, context),
                      fontWeight: FontWeight.w800,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = ColorConfig.primary1,
                    ),
                  ),
                  Text(
                    AppText.titleLoginSlogan.text,
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(40, context),
                      fontWeight: FontWeight.w800,
                      color: Colors.white, // Màu chữ
                      shadows: [
                        BoxShadow(
                          blurRadius: 4,
                          color: ColorConfig.shadow,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScaleUtils.scaleSize(8, context)),
              Text(
                AppText.textIntroduceLogin.text,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(20, context),
                    fontWeight: FontWeight.w500,
                    letterSpacing: ScaleUtils.scaleSize(-0.41, context),
                    color: ColorConfig.textPrimary,
                    fontFamily: 'Afacad'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ScaleUtils.scaleSize(50, context)),
              // LogoCenterView(listLogo: listLogo)
            ],
          ),
        ),
      ),
    );
  }
}


