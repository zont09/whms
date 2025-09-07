import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';

class NavigatorPage extends StatelessWidget {
  const NavigatorPage({super.key, required this.cubit});

  final NavigatorPageCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: cubit.previousPage,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(6, context)),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
                color: ColorConfig.primary2),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
            child: Center(
              child: Icon(
                Icons.arrow_left_sharp,
                size: ScaleUtils.scaleSize(28, context),
                color: ColorConfig.textPrimary,
              ),
            ),
          ),
        ),
        ...List.generate(
            cubit.num,
            (item) => GestureDetector(
                  onTap: () => cubit.moveTo(item + 1),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(6, context)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(4, context)),
                        color: ColorConfig.textPrimary,
                        border: Border.all(
                          width: 1,
                          color: cubit.state == item + 1
                              ? ColorConfig.primary2
                              : ColorConfig.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              color: ColorConfig.shadow,
                              offset: const Offset(0, 2))
                        ]),
                    padding: EdgeInsets.symmetric(
                      vertical: ScaleUtils.scaleSize(5, context),
                      horizontal: ScaleUtils.scaleSize(6, context),
                    ),
                    child: IntrinsicWidth(
                      child: Stack(
                        children: [
                          Center(
                            child: Opacity(
                              opacity: 0,
                              child: Text(
                                "00",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(14, context),
                                    color: ColorConfig.textSecondary),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              (item + 1).toString(),
                              style: TextStyle(
                                  // fontWeight: cubit.state == item + 1 ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: ScaleUtils.scaleSize(14, context),
                                  color: ColorConfig.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        // SizedBox(width: ScaleUtils.scaleSize(12, context),),
        GestureDetector(
          onTap: cubit.nextPage,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(6, context)),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
                color: ColorConfig.primary2),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
            child: Center(
              child: Icon(
                Icons.arrow_right,
                size: ScaleUtils.scaleSize(28, context),
                color: ColorConfig.textPrimary,
              ),
            ),
          ),
        )
      ],
    );
  }
}
