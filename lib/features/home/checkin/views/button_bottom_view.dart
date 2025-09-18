import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/widgets/check_in_button.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class ButtonBottomView extends StatelessWidget {
  const ButtonBottomView({
    super.key,
    required this.cubit,
  });

  final CheckInCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: ScaleUtils.scaleSize(9, context),
            horizontal: ScaleUtils.scaleSize(0, context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ZButton(
                title: AppText.btnCancel.text,
                icon: "",
                colorTitle: const Color(0xFFBF1D1E),
                colorBackground: Colors.white,
                colorBorder: Colors.white,
                sizeTitle: 16,
                paddingHor: 20,
                paddingVer: 6,
                fontWeight: FontWeight.w600,
                onPressed: () {
                  cubit.tab == 0
                      ? Navigator.of(context).pop()
                      : cubit.changeTab(0);
                }),
            if (cubit.tab == 0)
              SizedBox(width: ScaleUtils.scaleSize(18, context)),
            if (cubit.tab == 0) CheckInButton(cubit: cubit),
            if (cubit.tab == 1)
              ZButton(
                  paddingHor: 14,
                  title: AppText.btnAdd.text,
                  icon: "",
                  colorBackground: const Color(0xFFFF474E),
                  colorBorder: const Color(0xFFFF474E),
                  sizeTitle: 16,
                  paddingVer: 6,
                  fontWeight: FontWeight.w600,
                  onPressed: () async {
                    DialogUtils.showLoadingDialog(context);
                    await cubit.selectWork(
                        BlocProvider.of<SelectWorkCubit>(context).selectWork,
                        context);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    cubit.changeTab(0);
                  }),
          ],
        ));
  }
}
