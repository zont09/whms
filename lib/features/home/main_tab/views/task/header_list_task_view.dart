import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/features/home/main_tab/views/task/create_task/create_task_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_like_text.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HeaderListTaskView extends StatelessWidget {
  const HeaderListTaskView(
      {super.key,
      required this.cubit,
      required this.tab,
      required this.cubitMT});

  final MainTabCubit cubitMT;
  final TaskMainViewCubit cubit;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(8, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppText.titleTask.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w600,
                color: ColorConfig.textColor),
          ),
          SizedBox(width: ScaleUtils.scaleSize(6, context)),
          Tooltip(
            message:
            "${AppText.textSumWorkingPoint.text}: ${cubit.sumWorkingPoint}",
            child: Container(
              height: ScaleUtils.scaleSize(17, context),
              width: ScaleUtils.scaleSize(17, context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConfig.workingPointCl,
              ),
              padding:
              EdgeInsets.all(ScaleUtils.scaleSize(2, context)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Center(
                  child: Text(
                    "${cubit.sumWorkingPoint}",
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(11, context),
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41),
                  ),
                ),
              ),
            ),
          ),
          const ZSpace(w: 6),
          if (tab == "201" || tab == "203")
            InkWell(
              onTap: () async {
                if(tab == "201") {
                  DialogUtils.showAlertDialog(context,
                      child: CreateTaskView(
                        cubitMT: cubitMT,
                        onAdd: (v) {
                          cubit.addWorkingUnit(v);
                        },
                      ));
                }
                if(tab == "203") {
                  await DialogUtils.showAlertDialog(context,
                      child: CreateAssignmentPopup(
                          typeAssignment: 1000,
                          selectedWorking: WorkingUnitModel(),
                          assignees: [user.id],
                          userId: user.id,
                          reload: (v){},
                          endEvent: (v) {
                            cubitMT.addTaskPersonal(v);
                            cubit.addWorkingUnit(v);
                          },
                          scopes: []));
                  if(context.mounted) {
                    // cubitMT.initData(context);
                  }
                }
              },
              child: Image.asset(
                'assets/images/icons/ic_add_task_2.png',
                height: ScaleUtils.scaleSize(17, context),
              ),
            ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownLikeText(
                options: [
                  AppText.textAll.text,
                  ...cubit.listScope.map((item) => item.title),
                ],
                onChanged: (value) {
                  cubit.changeScope(value);
                },
              ),
            ],
          ))
        ],
      ),
    );
  }
}
