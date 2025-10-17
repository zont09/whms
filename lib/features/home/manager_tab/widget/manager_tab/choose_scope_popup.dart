import 'package:whms/features/home/main_tab/blocs/choose_scope_popup_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/widgets/search_field.dart';

class ChooseScopePopup extends StatelessWidget {
  final List<ScopeModel> selectedScopes;
  final Function(List<ScopeModel>) updateScopes;
  const ChooseScopePopup(this.selectedScopes,
      {required this.updateScopes, super.key});

  @override
  Widget build(BuildContext context) {
    var conSearch = TextEditingController();
    return BlocProvider(
      create: (context) => ChooseScopePopupCubit(selectedScopes),
      child: BlocBuilder<ChooseScopePopupCubit, int>(builder: (c, s) {
        var cubit = BlocProvider.of<ChooseScopePopupCubit>(c);
        return SizedBox(
          width: ScaleUtils.scaleSize(400, context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ScaleUtils.scaleSize(20, context)),
              Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(20, context)),
                  height: ScaleUtils.scaleSize(40, context),
                  child: SearchField(
                      controller: conSearch,
                      onChanged: (v) => cubit.search(v))),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ScaleUtils.scaleSize(10, context)),
                    ...cubit.listScopes.map(
                      (scope) => InkWell(
                        onTap: () {
                          if (cubit.selectedScopes.length == 1 &&
                              scope.isSelected) {
                            ToastUtils.showBottomToast(
                                context,
                                AppText.toastLeastOne.text
                                    .replaceAll('@', 'scope'));
                          } else {
                            cubit.chooseScope(scope);
                            updateScopes(cubit.selectedScopes);
                          }
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(30, context),
                                vertical: ScaleUtils.scaleSize(2, context)),
                            child: Row(
                              children: [
                                Icon(
                                    scope.isSelected
                                        ? Icons.check_box_outlined
                                        : Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: ScaleUtils.scaleSize(24, context)),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(10, context)),
                                Text(scope.title,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            ScaleUtils.scaleSize(12, context)))
                              ],
                            )),
                      ),
                    ),
                    SizedBox(height: ScaleUtils.scaleSize(20, context))
                  ],
                ),
              ))
            ],
          ),
        );
      }),
    );
  }
}
