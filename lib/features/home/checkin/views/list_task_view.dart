import 'package:flutter/material.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/views/check_out_task_widget.dart';
import 'package:whms/features/home/checkin/widgets/task_widget.dart';
import 'package:whms/untils/scale_utils.dart';

class ListTaskView extends StatelessWidget {
  const ListTaskView({
    super.key,
    required this.cubit,
    required this.cubitSW,
  });

  final dynamic cubit;
  final SelectWorkCubit cubitSW;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(8, context),
            vertical: ScaleUtils.scaleSize(6, context)),
        child: Column(
          children: [
            if (cubit is CheckOutCubit)
              ...cubit.mapGroupTask.entries.map((item) => Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ScaleUtils.scaleSize(4, context)),
                    child: CheckOutTaskWidget(
                        task: item.key,
                        listSub: item.value,
                        info: cubit.mapTaskCheckOutInfo[item.key.id],
                        cubit: cubit),
                  )),
            if (cubit is! CheckOutCubit)
              ...cubit.listWorkSelected.map((item) {
                return Column(
                  children: [
                    TaskWidget(
                      key: ValueKey(item.id),
                      mapScope: cubit.mapScope,
                      workPar: cubit.mapWorkParent[item.parent] ?? "Không có",
                      mapAddress: cubit.mapAddress,
                      work: item,
                      cubitCO: cubit is CheckOutCubit ? cubit : null,
                      cubit: cubitSW,
                      onChangedWorkingTime: (value) {
                        cubit.changeWorkingTime(item, value, context);
                      },
                      removeWork: (work) {
                        if (cubit is CheckOutCubit) {
                          cubit.removeWork(work, context);
                        } else {
                          cubit.removeWork(work);
                        }
                      },
                      onChangeStatus: (value) {
                        cubit.updateWorkStatus(
                            item.copyWith(status: value), context);
                      },
                      workingTime: cubit.mapWorkingTime[item.id] ?? 10,
                      isSelected: cubit is CheckOutCubit
                          ? cubit.listWorkCheckOut.any((e) => e.id == item.id)
                          : true,
                      isAddTask: false,
                    ),
                    SizedBox(height: ScaleUtils.scaleSize(9, context)),
                  ],
                );
              })
          ],
        ),
      ),
    );
  }
}