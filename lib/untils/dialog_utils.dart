import 'dart:async';
import 'dart:ui_web';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/views/confirm_checkout_view.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'dart:html' as html;

import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/audio_dialog.dart';
import 'package:whms/widgets/custom_button.dart';

class DialogUtils {
  static showAlertVersion(BuildContext context,
      {required Function() reload}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scalePadding(20, context)),
            ),
            child: Container(
                constraints: BoxConstraints(
                    maxWidth: ScaleUtils.scaleSize(450, context),
                    minWidth: MediaQuery.of(context).size.width * 0.1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(
                      ScaleUtils.scalePadding(20, context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: ScaleUtils.scaleSize(4, context),
                      offset: Offset(0, ScaleUtils.scaleSize(2, context)),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(20, context)),
                      color: Colors.white),
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cập nhật website',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(20, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Vui lòng nhấn "OK" để lấy phiên bản website mới nhất',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: ScaleUtils.scaleSize(40, context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ZButton(
                              title: AppText.btnOk.text.toUpperCase(),
                              colorBackground: ColorConfig.error,
                              colorBorder: ColorConfig.error,
                              sizeTitle: 16,
                              icon: "",
                              paddingVer: 3,
                              paddingHor: 20,
                              onPressed: () async {
                                await reload();
                              }),
                        ],
                      ),
                    ],
                  ),
                )));
      },
    );
  }

  static Future<bool> showConfirmCheckoutDialog(
      BuildContext context,
      String title,
      int wp,
      int wt,
      int lt,
      String message, {
        Color mainColor = ColorConfig.primary2,
        Color confirmColor = ColorConfig.error,
        Color cancelColor = ColorConfig.primary3,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.all(ScaleUtils.scaleSize(25, context)),
        content: ConfirmCheckoutView(
          logTime: DateTimeUtils.formatDuration(lt),
          workingPoint: "$wp điểm",
          timeDoingTask: DateTimeUtils.formatDuration(wt),
        ),
      ),
    ).then((value) => value ?? false);
  }

  static showAlertDialog(BuildContext context,
      {bool barrierDismissible = true, required Widget child}) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scalePadding(20, context)),
            ),
            child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    minWidth: MediaQuery.of(context).size.width * 0.1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(
                      ScaleUtils.scalePadding(20, context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: ScaleUtils.scaleSize(4, context),
                      offset: Offset(0, ScaleUtils.scaleSize(2, context)),
                    ),
                  ],
                ),
                child: child));
      },
    );
  }

  static Future<void> handleDialog(
    BuildContext context,
    Future<ResponseModel<dynamic>> Function() action,
    void Function() resetFields, {
    bool isShowDialogSuccess = true,
    bool isShowDialogError = true,
    required String successMessage,
    required String successTitle,
    required String failedMessage,
    required String failedTitle,
  }) async {
    try {
      showLoadingDialog(context);
      ResponseModel<dynamic> response = await action();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      // Hiển thị dialog thành công
      if (context.mounted &&
          response.status == ResponseStatus.ok &&
          isShowDialogSuccess) {
        await showResultDialog(context, successTitle, successMessage,
            mainColor: ColorConfig.primary2);
      }

      if (context.mounted &&
          response.status == ResponseStatus.error &&
          isShowDialogError) {
        await showResultDialog(context, failedTitle,
            "$failedMessage${response.error != null ? ". ${response.error?.text}" : ""}",
            mainColor: ColorConfig.error);
      }

      // Gọi hàm để reset các trường
      resetFields();
    } catch (e) {
      // Đóng loading dialog nếu có lỗi xảy ra
      debugPrint("=====> Co loi xay ra: $e");
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Hiển thị dialog lỗi
      if (context.mounted && isShowDialogError) {
        await showResultDialog(context, AppText.titleFailed.text,
            AppText.textHasError.text + e.toString(),
            mainColor: ColorConfig.mainLogin);
      }
    }
  }

  static Future<void> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: ColorConfig.primary1,
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showResultDialog(
      BuildContext context, String title, String message,
      {Color mainColor = ColorConfig.primary2}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Cùng kiểu bo góc
        ),
        contentPadding: EdgeInsets.all(ScaleUtils.scaleSize(25, context)),
        // Cùng padding
        content: SizedBox(
          width: ScaleUtils.scaleSize(436, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(24, context),
                  color: mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ScaleUtils.scaleSize(20, context)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(18, context),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(25, context),
          vertical: ScaleUtils.scaleSize(24, context),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZButton(
                title: AppText.btnOk.text,
                colorBackground: mainColor,
                // Dùng màu chính
                colorBorder: mainColor,
                sizeTitle: 18,
                icon: "",
                paddingHor: 35,
                // Đảm bảo padding giống Confirm
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    Color mainColor = ColorConfig.primary2,
    Color confirmColor = ColorConfig.primary2,
    Color cancelColor = ColorConfig.primary3,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.all(ScaleUtils.scaleSize(25, context)),
        content: SizedBox(
          width: ScaleUtils.scaleSize(436, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(24, context),
                  color: mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ScaleUtils.scaleSize(20, context)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(18, context),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(25, context),
            vertical: ScaleUtils.scaleSize(24, context)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZButton(
                title: AppText.btnCancel.text,
                colorBackground: Colors.white,
                colorTitle: cancelColor,
                sizeTitle: 16,
                icon: "",
                paddingHor: 35,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop(false);
                  }
                },
              ),
              SizedBox(width: ScaleUtils.scaleSize(20, context)),
              ZButton(
                title: AppText.btnConfirm.text,
                colorBackground: confirmColor,
                colorBorder: confirmColor,
                sizeTitle: 16,
                icon: "",
                paddingHor: 20,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  static void showVideoDialog(BuildContext context, PlatformFile file) {
    // Tạo Blob URL
    final blob = html.Blob([file.bytes], 'video/${file.extension}');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Tạo video element
    final videoElement = html.VideoElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..controls = true
      ..autoplay = true;

    // Register view factory
    final viewType = 'video-player-${DateTime.now().millisecondsSinceEpoch}';
    platformViewRegistry.registerViewFactory(
        viewType, (int viewId) => videoElement);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: HtmlElementView(viewType: viewType),
          ),
        );
      },
    ).then((_) {
      // Cleanup
      videoElement.removeAttribute('src');
      html.Url.revokeObjectUrl(url);
    });
  }

  static void showAudioDialog(BuildContext context, PlatformFile file) {
    DialogUtils.showAlertDialog(
      context,
      child: AudioDialog(file: file),
    );
  }
}

enum DialogState { success, error }
