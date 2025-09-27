import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class DetailTaskView extends StatelessWidget {
  const DetailTaskView({
    super.key,
    required this.work,
    required this.cubit,
    required this.tab,
    required this.cubitMT,
  });

  final TaskMainViewCubit cubit;
  final MainTabCubit cubitMT;
  final WorkingUnitModel work;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    final configCubit = ConfigsCubit.fromContext(context);
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(14, context)),
        border: Border.all(
          width: ScaleUtils.scaleSize(1, context),
          color: ColorConfig.border5,
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(1, 1),
            blurRadius: 5.9,
            spreadRadius: 0,
            color: const Color(0xFF000000).withOpacity(0.16),
          ),
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(
        vertical: ScaleUtils.scaleSize(5, context),
        horizontal: ScaleUtils.scaleSize(5, context),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: []),
    );
  }
}
