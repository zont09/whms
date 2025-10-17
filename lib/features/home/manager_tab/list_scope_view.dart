import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class ListScopeView extends StatelessWidget {
  final ManagementCubit managementCubit;
  const ListScopeView({required this.managementCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: ScaleUtils.scaleSize(4, context),
                    offset: Offset(0, ScaleUtils.scaleSize(2, context)))
              ],
              border: Border.all(color: const Color(0xFFD7D7D7), width: 0),
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(ScaleUtils.scaleSize(8, context))),
            ),
            child: Column(children: [
              ...managementCubit.listScope!.map((e) => Material(
                  color: e.id == managementCubit.selectedScope!.id
                      ? ColorConfig.primary3
                      : Colors.transparent,
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(ScaleUtils.scaleSize(
                          (managementCubit.listScope!.indexOf(e) !=
                                  managementCubit.listScope!.length - 1)
                              ? 0
                              : 8,
                          context))),
                  child: InkWell(
                      onTap: () => managementCubit.chooseScope(e),
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(ScaleUtils.scaleSize(
                              (managementCubit.listScope!.indexOf(e) !=
                                      managementCubit.listScope!.length - 1)
                                  ? 0
                                  : 8,
                              context))),
                      child: Column(children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: ScaleUtils.scaleSize(12, context)),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Container()),
                              Expanded(
                                  flex: 3,
                                  child: Text(e.title,
                                      style: TextStyle(
                                          color: e.id ==
                                                  managementCubit
                                                      .selectedScope!.id
                                              ? Colors.white
                                              : ColorConfig.textColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: ScaleUtils.scaleSize(
                                              14, context))))
                            ],
                          ),
                        ),
                        if (managementCubit.listScope!.indexOf(e) !=
                            managementCubit.listScope!.length - 1)
                          Container(
                              height: ScaleUtils.scaleSize(1, context),
                              width: double.maxFinite,
                              color: const Color(0xFFD7D7D7))
                      ]))))
            ]));
  }
}
