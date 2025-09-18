import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/no_task_view.dart';
import 'package:whms/features/home/checkin/widgets/header_task_table.dart';
import 'package:whms/features/home/checkin/widgets/search_field_with_dropdown.dart';
import 'package:whms/features/home/checkin/widgets/task_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_like_text.dart';

class SelectWorkView extends StatelessWidget {
  const SelectWorkView({super.key, required this.cubitMA, this.onTapTitle});

  final dynamic cubitMA;
  final Function()? onTapTitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectWorkCubit, int>(
      builder: (c, s) {
        var cubit = BlocProvider.of<SelectWorkCubit>(c);
        return Container(
          color: Colors.white,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: ScaleUtils.scaleSize(20, context)),
            SearchFieldWithDropdown(
                onChangedTextField: (value) {
                  cubit.changeSearchField(value);
                },
                dropdown: DropdownLikeText(
                  initValue: AppText.titleDoing.text,
                    options: [
                      AppText.textAll.text,
                      AppText.titleDoing.text,
                      AppText.textNone.text,
                      AppText.textByFinished.text
                    ],
                    fontSize: 14,
                    onChanged: (value) {
                      cubit.changeStatusFilter(value);
                    }),
                controller: cubit.searchController),
            SizedBox(height: ScaleUtils.scaleSize(15, context)),
            if (cubit.listShow.isEmpty)
              Expanded(
                  child: Center(
                      child: NoTaskView(
                          sizeImg: 120,
                          sizeContent: 16,
                          sizeTitle: 16,
                          tab: cubit.listCanChoose.isNotEmpty
                              ? "-2001"
                              : "-2004"))),
            if (cubit.listShow.isNotEmpty)
              HeaderTaskTable(
                cubit: cubit,
                isAddTask: true,
                isShowSelectedAll: !cubit.isSelectOne,
                onTapTitle: () {
                  cubit.changeSortTitle();
                  if(onTapTitle != null) {
                    onTapTitle!();
                  }
                },
              ),
            if (cubit.listShow.isNotEmpty)
              SizedBox(height: ScaleUtils.scaleSize(9, context)),
            if (cubit.listShow.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(8, context),
                      vertical: ScaleUtils.scaleSize(6, context)),
                  child: Column(children: [
                    ...cubit.listShow.map((item) {
                      return Column(children: [
                        TaskWidget(
                            key: ValueKey(item.id),
                            mapScope: cubit.mapScope,
                            workPar: cubitMA.mapWorkParent[item.parent] ??
                                "Không có",
                            mapAddress: cubitMA.mapAddress,
                            work: item,
                            cubit: cubit,
                            onChangedWorkingTime: (value) {},
                            onChangeStatus: (value) {},
                            removeWork: (v) {},
                            isSelected: cubit.isSelectOne
                                ? cubit.workSelected == item
                                : cubit.selectWork.contains(item)),
                        SizedBox(height: ScaleUtils.scaleSize(9, context))
                      ]);
                    })
                  ]),
                )),
              )
          ]),
        );
      },
    );
  }
}
