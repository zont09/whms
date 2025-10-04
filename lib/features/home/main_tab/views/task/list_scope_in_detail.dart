import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/choose_scope_popup.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';

class ListScopeInDetail extends StatelessWidget {
  final bool isPermission;
  final List<ScopeModel> scopes;
  final Function(List<ScopeModel>) updateScopes;
  const ListScopeInDetail(this.scopes,
      {required this.updateScopes, this.isPermission = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ScaleUtils.scaleSize(10, context)),
        Row(children: [
          Text(AppText.txtListScope.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textColor)),
          SizedBox(width: ScaleUtils.scaleSize(10, context)),
          ...scopes.map(
            (e) => Container(
                alignment: Alignment.center,
                margin:
                    EdgeInsets.only(right: ScaleUtils.scaleSize(5, context)),
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(10, context)),
                height: ScaleUtils.scaleSize(32, context),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1000),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                          color: Colors.black.withOpacity(0.2))
                    ]),
                child: Text(e.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                        fontSize: ScaleUtils.scaleSize(12, context),
                        color: ColorConfig.textColor))),
          ),
          IconButton(
              onPressed: () {
                if (isPermission) {
                  DialogUtils.showAlertDialog(context,
                      child:
                          ChooseScopePopup(scopes, updateScopes: updateScopes));
                } else {
                  ToastUtils.showBottomToast(
                      context, AppText.toastNotCreator.text);
                }
              },
              splashRadius: ScaleUtils.scaleSize(12, context),
              icon: Image.asset('assets/images/icons/ic_edit.png',
                  width: ScaleUtils.scaleSize(22, context),
                  height: ScaleUtils.scaleSize(22, context)))
        ])
      ],
    );
  }
}
