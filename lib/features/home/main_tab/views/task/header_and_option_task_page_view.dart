import 'package:whms/features/home/main_tab/blocs/task_main_page_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/dropdown_scope.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HeaderAndOptionTaskPageView extends StatelessWidget {
  const HeaderAndOptionTaskPageView({
    super.key,
    required this.cubit,
    required this.user,
    required this.mapScope,
  });

  final TaskMainPageCubit? cubit;
  final UserModel user;
  final Map<String, ScopeModel> mapScope;

  @override
  Widget build(BuildContext context) {
    final nullScope = ScopeModel();
    return Padding(
      padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(25, context),
              vertical: ScaleUtils.scaleSize(20, context))
          .copyWith(bottom: 12),
      child: Row(children: [
        Image.asset('assets/images/icons/ic_list_task.png',
            height: ScaleUtils.scaleSize(20, context),
            color: const Color(0xFFBF0000)),
        SizedBox(width: ScaleUtils.scaleSize(5, context)),
        Text(AppText.titleTaskList.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(18, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor)),
        const Spacer(),
        DropdownString(
          onChanged: (v) {
            if (cubit != null) {
              cubit!.changeStatusTask(v!);
            }
          },
          initItem: cubit?.filterStatusTask ?? AppText.textAll.text,
          options: [
            AppText.textAll.text,
            AppText.textByUnFinished.text,
            AppText.textByFinished.text,
            AppText.titleDoing.text,
            AppText.textNone.text,
            AppText.textCancelled.text
          ],
          radius: 8,
          textColor: const Color(0xFF191919),
          fontSize: 14,
          maxWidth: 160,
          centerItem: true,
        ),
        const ZSpace(w: 8),
        DropdownString(
          onChanged: (v) {
            if (cubit != null) {
              cubit!.changeStatusClosed(v!);
            }
          },
          initItem: cubit?.filterStatusClosed ?? AppText.textAll.text,
          options: [
            AppText.textAll.text,
            AppText.textClosed.text,
            AppText.textOpened.text,
          ],
          radius: 8,
          textColor: const Color(0xFF191919),
          fontSize: 14,
          maxWidth: 160,
          centerItem: true,
        ),
        const ZSpace(w: 8),
        DropdownScope(
            fontSize: 14,
            maxWidth: 120,
            maxHeight: 30,
            radius: 8,
            onChanged: (v) {
              if (cubit != null) {
                cubit!.changeScope(v!);
              }
            },
            initTime: cubit?.filterScope ?? nullScope,
            options: [
              if (cubit != null) cubit!.scopeFull,
              if(cubit == null) nullScope,
              ...user.scopes
                  .where((e) => mapScope.containsKey(e) && mapScope[e] != null)
                  .map((e) => mapScope[e]!)
            ]),
        const ZSpace(w: 8),
        SizedBox(
          width: ScaleUtils.scaleSize(220, context),
          child: SearchField(
              controller: cubit?.searchCon ?? TextEditingController(),
              onChanged: (v) {
                if (cubit != null) {
                  cubit!.changeSearchField(v);
                }
              },
              fontSize: 14,
              padVer: 2,
              padHor: 4,
              hintText: AppText.textSearchTask.text),
        )
      ]),
    );
  }
}
