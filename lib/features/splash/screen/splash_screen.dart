import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Center(
        // child: Image.asset(
        //   'assets/images/logo/pls.png',
        //   height: ScaleUtils.scaleSize(200, context),
        // ),
      ),
    );
  }
}
