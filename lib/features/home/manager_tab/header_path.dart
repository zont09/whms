import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/choose_parent_popup.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/widgets/hover_text.dart';

class HeaderPath extends StatelessWidget {
  final bool isPermission;
  const HeaderPath(this.isPermission, {super.key});

  @override
  Widget build(BuildContext context) {
    var managementCubit = BlocProvider.of<ManagementCubit>(context);
    return Padding(
        padding: EdgeInsets.only(
            top: ScaleUtils.scaleSize(5, context),
            left: ScaleUtils.scaleSize(20, context)),
        child: Row(children: [
          ...managementCubit.link.map((e) => Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.type,
                        style: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                            fontSize: ScaleUtils.scaleSize(7, context))),
                    HoverText(
                        text: e.title,
                        onTap: () => managementCubit.chooseWorkingUnit(e))
                  ],
                ),
                if (managementCubit.link.indexOf(e) !=
                    managementCubit.link.length - 1)
                  Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ScaleUtils.scaleSize(5, context),
                        horizontal: ScaleUtils.scaleSize(7, context),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                              opacity: 0,
                              child: Text('/',
                                  style: TextStyle(
                                      height: 1,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                      fontSize:
                                          ScaleUtils.scaleSize(7, context)))),
                          Text('/',
                              style: TextStyle(
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.primary1,
                                  fontSize: ScaleUtils.scaleSize(11, context)))
                        ],
                      ))
              ])),
          SizedBox(width: ScaleUtils.scaleSize(10, context)),
          if (managementCubit.selectedWorking!.level != 1)
            Material(
                color: Colors.transparent,
                child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (isPermission) {
                        DialogUtils.showAlertDialog(context,
                            barrierDismissible: false,
                            child: ChooseParentPopup(
                              managementCubit.selectedWorking!,
                              managementCubit.directParent!,
                              listParent: managementCubit.workings,
                            ));
                      } else {
                        ToastUtils.showBottomToast(
                            context, AppText.toastNotCreator.text);
                      }
                    },
                    child: Container(
                        padding:
                            EdgeInsets.all(ScaleUtils.scaleSize(5, context)),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset('assets/images/icons/ic_edit.png',
                            width: ScaleUtils.scaleSize(16, context),
                            height: ScaleUtils.scaleSize(16, context)))))
        ]));
  }
}
