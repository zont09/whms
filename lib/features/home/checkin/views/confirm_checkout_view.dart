import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/z_space.dart';

class ConfirmCheckoutView extends StatelessWidget {
  const ConfirmCheckoutView({super.key,
    required this.logTime,
    required this.timeDoingTask,
    required this.workingPoint});

  final String logTime;
  final String timeDoingTask;
  final String workingPoint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfirmCheckoutCubit(),
      child: BlocBuilder<ConfirmCheckoutCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<ConfirmCheckoutCubit>(c);
          return SizedBox(
            width: ScaleUtils.scaleSize(436, context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleConfirm.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(28, context),
                    color: ColorConfig.primary2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ScaleUtils.scaleSize(12, context)),
                Text(
                  AppText.textConfirmCheckOut.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(20, context),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const ZSpace(h: 12),
                LineConfirmCheckOut(
                    mainColor: const Color(0xFF2C7300),
                    background: const Color(0xFFDFFEF5),
                    title: AppText.titleLogTime.text,
                    value: logTime,
                    isSelected: cubit.isCheckLogTime,
                    onSelect: () {
                      cubit.isCheckLogTime = !cubit.isCheckLogTime;
                      cubit.EMIT();
                    }),
                const ZSpace(h: 9),
                LineConfirmCheckOut(
                    mainColor: const Color(0xFF2C7300),
                    background: const Color(0xFFDFFEF5),
                    title: AppText.textSumTimeDoingTask.text,
                    value: timeDoingTask,
                    isSelected: cubit.isDoingTaskTime,
                    onSelect: () {
                      cubit.isDoingTaskTime = !cubit.isDoingTaskTime;
                      cubit.EMIT();
                    }),
                const ZSpace(h: 9),
                LineConfirmCheckOut(
                    mainColor: const Color(0xFFE65100),
                    background: const Color(0xFFFFE5D7),
                    title: AppText.textSumWorkingPoint.text,
                    value: workingPoint,
                    isSelected: cubit.isWorkingPoint,
                    onSelect: () {
                      cubit.isWorkingPoint = !cubit.isWorkingPoint;
                      cubit.EMIT();
                    }),
                const ZSpace(h: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ZButton(
                      title: AppText.btnCancel.text,
                      colorBackground: Colors.white,
                      colorTitle: ColorConfig.error,
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
                      colorBackground: ColorConfig.primary3,
                      colorBorder: ColorConfig.primary3,
                      sizeTitle: 16,
                      icon: "",
                      paddingHor: 20,
                      onPressed: () {
                        if (!cubit.isWorkingPoint || !cubit.isDoingTaskTime ||
                            !cubit.isCheckLogTime) {
                          ToastUtils.showBottomToast(context,
                              AppText.textPleaseCheckedAllToCheckout.text);
                          return;
                        }
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ConfirmCheckoutCubit extends Cubit<int> {
  ConfirmCheckoutCubit() : super(0);

  bool isCheckLogTime = false;
  bool isDoingTaskTime = false;
  bool isWorkingPoint = false;

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}

class LineConfirmCheckOut extends StatelessWidget {
  const LineConfirmCheckOut({super.key,
    required this.mainColor,
    required this.background,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onSelect});

  final Color mainColor;
  final Color background;
  final String title;
  final String value;
  final bool isSelected;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(229), color: background),
            padding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(4, context),
                horizontal: ScaleUtils.scaleSize(8, context)),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w500,
                          color: mainColor,
                          letterSpacing: -0.02,
                          overflow: TextOverflow.ellipsis),
                    )),
                const ZSpace(w: 9),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(229),
                      color: mainColor),
                  padding: EdgeInsets.symmetric(
                      vertical: ScaleUtils.scaleSize(3, context),
                      horizontal: ScaleUtils.scaleSize(5, context)),
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(14, context),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.02,
                        overflow: TextOverflow.ellipsis),
                  ),
                )
              ],
            ),
          ),
        ),
        const ZSpace(w: 9),
        InkWell(
          onTap: () {
            onSelect();
          },
          child: Image.asset(
              'assets/images/icons/ic_checkbox_${isSelected
                  ? "active"
                  : "inactive"}.png',
              height: ScaleUtils.scaleSize(16, context)),
        )
      ],
    );
  }
}
