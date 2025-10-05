import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class NoTaskView extends StatelessWidget {
  const NoTaskView(
      {super.key,
      required this.tab,
      this.sizeImg = 300,
      this.sizeTitle = 28,
      this.sizeContent = 20,
      this.paddingHor = 150,
      this.spacing = 5,
      this.isShowFullScreen = true,
      this.isShowButtonPersonal = true});

  final String tab;
  final double sizeImg;
  final double sizeTitle;
  final double sizeContent;
  final bool isShowButtonPersonal;
  final bool isShowFullScreen;
  final double paddingHor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    String title = '';
    String content = '';

    switch (tab) {
      case "2":
        title = AppText.titleNoTask.text;
        content = AppText.textNoTask.text;
        break;
      case "201":
        title = AppText.titleNoTaskToday.text;
        content = AppText.textNoTaskToday.text;
        break;
      case "202":
        title = AppText.titleNoTaskTop.text;
        content = AppText.textNoTaskTop.text;
        break;
      case "203":
        title = AppText.titleNoTaskPersonal.text;
        content = AppText.textNoTaskPersonal.text;
        break;
      case "204":
        title = AppText.titleNoTaskAssign.text;
        content = AppText.textNoTaskAssign.text;
        break;
      case "-229":
        title = AppText.titleNoTaskInScope.text;
        content = AppText.textNoTaskInScope.text;
        break;
      case "-2001":
        content = AppText.textNoFindTask.text;
        break;
      case "-2004":
        title = AppText.textNoTaskForCheckIn.text;
        break;
      case "-2005":
        title = AppText.textNoDocAndAnnounce.text;
        break;
      case "-2006":
        title = AppText.textNoMeeting.text;
        break;
      case "-2007":
        title = AppText.textNoNote.text;
        break;
      case "meeting_today":
        title = AppText.titleNoMeetingToday.text;;
        break;
    }
    return Container(
      height: isShowFullScreen ? double.infinity : null,
      width: isShowFullScreen ? double.infinity : null,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(paddingHor, context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/img_no_task.png',
              height: ScaleUtils.scaleSize(sizeImg, context)),
          SizedBox(height: ScaleUtils.scaleSize(spacing, context)),
          Text(
            title,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(sizeTitle, context),
                fontWeight: FontWeight.w600,
                color: ColorConfig.textTertiary),
            textAlign: TextAlign.center,
          ),
          Text(
            content,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(sizeContent, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textTertiary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScaleUtils.scaleSize(15, context)),
          if (tab == "203" && isShowButtonPersonal)
            ZButton(
                title: AppText.btnCreateTask.text,
                icon: "",
                sizeTitle: 22,
                colorTitle: Colors.white,
                colorBackground: ColorConfig.primary4,
                colorBorder: ColorConfig.primary4,
                paddingHor: 20,
                paddingVer: 4,
                onPressed: () async {
                  debugPrint("[THINK] ====> on tap here???");
                  await DialogUtils.showAlertDialog(context,
                      child: CreateAssignmentPopup(
                          typeAssignment: 1000,
                          selectedWorking: WorkingUnitModel(),
                          assignees: [user.id],
                          userId: user.id,
                          reload: (v) {},
                          scopes: []));
                  if (context.mounted) {
                    // BlocProvider.of<MainTabCubit>(context).initData(context);
                  }
                })
        ],
      ),
    );
  }
}
