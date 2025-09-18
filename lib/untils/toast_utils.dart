import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:whms/untils/scale_utils.dart';

class ToastUtils {
  static message(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showBottomToast(BuildContext context, String text, {int duration = 2}) {
    final fToast = FToast()..init(context);
    Widget toast = Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(10, context),
            vertical: ScaleUtils.scaleSize(5, context)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            // color: Colors.white,
            color: Colors.black),
        child: Row(mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info,
              size: ScaleUtils.scaleSize(30, context),
              color: Colors.grey,
            ),
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
            Flexible(
              child: Text(
                text,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(15, context),
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration),
    );
  }
}
