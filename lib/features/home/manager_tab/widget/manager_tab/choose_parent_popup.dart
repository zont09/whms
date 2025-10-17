import 'package:whms/configs/reload_cubit.dart';
import 'package:whms/features/home/manager_tab/bloc/choose_parent_popup_cubit.dart';
import 'package:whms/features/home/manager_tab/drag_and_drop_tree_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/loading_widget.dart';
import 'package:whms/widgets/two_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ChooseParentPopup extends StatelessWidget {
  final WorkingUnitModel model;
  final WorkingUnitModel directParent;
  final List<WorkingUnitModel> listParent;
  const ChooseParentPopup(this.model, this.directParent,
      {required this.listParent, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ChooseParentPopupCubit()..init(model, listParent),
        child: SizedBox(
            width: ScaleUtils.scaleSize(550, context),
            child: BlocBuilder<ChooseParentPopupCubit, int>(builder: (c, s) {
              var cubit = BlocProvider.of<ChooseParentPopupCubit>(c);
              if (cubit.newParent == null) {
                return const LoadingWidget();
              }
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedSwitcher(
                      duration: kThemeAnimationDuration,
                      child: DefaultIndentGuide(
                          guide: IndentGuide.connectingLines(
                              color: Colors.grey.shade400,
                              thickness: ScaleUtils.scaleSize(1, context),
                              strokeCap: StrokeCap.round,
                              pathModifier: (p) => p,
                              roundCorners: true),
                          child: Column(children: [
                            SizedBox(height: ScaleUtils.scaleSize(20, context)),
                            Expanded(child: DragAndDropTreeView(cubit)),
                            SizedBox(height: ScaleUtils.scaleSize(60, context))
                          ]))),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(
                                  ScaleUtils.scaleSize(20, context))),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(
                                    0, -ScaleUtils.scaleSize(4, context)),
                                blurRadius: ScaleUtils.scaleSize(10, context))
                          ]),
                      padding: EdgeInsets.only(
                          top: ScaleUtils.scalePadding(12, context),
                          right: ScaleUtils.scalePadding(12, context),
                          bottom: ScaleUtils.scalePadding(12, context)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TwoButtons(
                                titleCancel: AppText.btnCancel.text,
                                titleOK: AppText.btnUpdate.text,
                                onCancel: () async {
                                  await cubit.reset(directParent);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                onOK: () async {
                                  if (TypeAssignmentDefineExtension.priority(
                                          cubit.wu.type) >
                                      TypeAssignmentDefineExtension.priority(
                                          cubit.newParent!.type)) {
                                    DialogUtils.showLoadingDialog(c);
                                    await cubit.submitParent(context);
                                    if (c.mounted) {
                                      await BlocProvider.of<ReloadCubit>(c)
                                          .reload(ReloadEvent.manager);
                                      Navigator.pop(c);
                                      Navigator.pop(c);
                                    }
                                  } else {
                                    ToastUtils.showBottomToast(
                                        context,
                                        AppText.toastWarningParent.text
                                            .replaceAll('@',
                                                '"${cubit.wu.type} ${cubit.wu.title}"')
                                            .replaceAll('#',
                                                '"${cubit.newParent!.type} ${cubit.newParent!.title}"'));
                                  }
                                })
                          ]))
                ],
              );
            })));
  }
}
