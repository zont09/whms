import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class CheckOutTabView extends StatelessWidget {
  const CheckOutTabView({
    super.key,
    required this.cubit,
  });

  final CheckOutCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: const Color(0xFFF7F9FF)),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  cubit.changeTab(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(8, context)),
                      border: Border.all(
                          width: ScaleUtils.scaleSize(1, context),
                          color: cubit.tab == 0
                              ? ColorConfig.border4
                              : Colors.transparent),
                      color: cubit.tab == 0 ? Colors.white : Colors.transparent,
                      boxShadow: [if (cubit.tab == 0) ColorConfig.boxShadow]),
                  padding: EdgeInsets.symmetric(
                      vertical: ScaleUtils.scaleSize(4, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/icons/ic_check_in.png',
                          color: Colors.black,
                          height: ScaleUtils.scaleSize(24, context)),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      Text(
                        AppText.titleCheckOutVSub.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(16, context),
                            fontWeight: FontWeight.w500,
                            color: ColorConfig.textColor,
                            letterSpacing: -0.41),
                      )
                    ],
                  ),
                ),
              )),
          Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  cubit.changeTab(1);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(8, context)),
                      border: Border.all(
                          width: ScaleUtils.scaleSize(1, context),
                          color: cubit.tab == 1
                              ? ColorConfig.border4
                              : Colors.transparent),
                      color: cubit.tab == 1 ? Colors.white : Colors.transparent,
                      boxShadow: [if (cubit.tab == 1) ColorConfig.boxShadow]),
                  padding: EdgeInsets.symmetric(
                      vertical: ScaleUtils.scaleSize(4, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/icons/ic_break_time.png',
                          color: Colors.black,
                          height: ScaleUtils.scaleSize(24, context)),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      Text(
                        AppText.titleBreakTimeVSub.text,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(16, context),
                            fontWeight: FontWeight.w500,
                            color: ColorConfig.textColor,
                            letterSpacing: -0.41),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
