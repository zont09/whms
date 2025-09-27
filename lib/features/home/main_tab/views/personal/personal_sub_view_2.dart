import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class PersonalSubView2 extends StatelessWidget {
  const PersonalSubView2({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: ScaleUtils.scaleSize(20, context)),
      child: Column(
        children: [

        ],
      ),),
    );
  }
}
