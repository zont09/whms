import 'package:flutter/material.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/untils/scale_utils.dart';

class StatusCard extends StatelessWidget {
  const StatusCard(
      {super.key,
      required this.status,
      this.isDropdown = false,
      this.fontSize = 10});

  final int status;
  final bool isDropdown;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    StatusWorkingDefine statusDf = StatusWorkingExtension.fromValue(status);
    return IntrinsicHeight(
      child: Container( 
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
            color: statusDf.colorBackground
        ),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(8, context),
            vertical: ScaleUtils.scaleSize(4, context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(statusDf.description,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(fontSize, context),
                    fontWeight: FontWeight.w500,
                    color: statusDf.colorTitle)),
            if (status >= 100 && status < 400)
              SizedBox(width: ScaleUtils.scaleSize(4, context)),
            if (status >= 100 && status < 400)
              Container(
                alignment: Alignment.center,
                // width: ScaleUtils.scaleSize(15, context),
                // height: ScaleUtils.scaleSize(15, context),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(229), color: statusDf.colorTitle),
                padding: EdgeInsets.symmetric(horizontal:  ScaleUtils.scaleSize(4, context), vertical: ScaleUtils.scaleSize(2, context)),
                child: Text(
                  "${status % 100}%",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(fontSize - 1, context),
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            // if(isDropdown)
            //   SizedBox(width: ScaleUtils.scaleSize(5, context),),
            // if(isDropdown)
            //   Icon(Icons.arrow_drop_down, size: ScaleUtils.scaleSize(10, context), color: Colors.black,),
          ],
        ),
      ),
    );
  }
}
