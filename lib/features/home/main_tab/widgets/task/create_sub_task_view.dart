import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/input_field.dart';

class CreateSubTaskView extends StatelessWidget {
  const CreateSubTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateSubTaskCubit(),
      child: BlocBuilder<CreateSubTaskCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<CreateSubTaskCubit>(c);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  ScaleUtils.scaleSize(12, context)),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(ScaleUtils.scaleSize(32, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.titleCreateSubtask.text.toUpperCase(),
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(24, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textColor6,
                        letterSpacing: -0.41,
                        shadows: const [ColorConfig.textShadow])),
                Text(AppText.textCreateSubTaskDescription.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(16, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.41,
                        color: ColorConfig.textColor7)),
                SizedBox(height: ScaleUtils.scaleSize(18, context)),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppText.titleLink.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(14, context),
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.41,
                              color: ColorConfig.textColor6)),
                      SizedBox(width: ScaleUtils.scaleSize(5, context)),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                ScaleUtils.scaleSize(12, context)),
                            color: const Color(0xFFedf8ff)),
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(8, context),
                            vertical: ScaleUtils.scaleSize(4, context)),
                        child: Text("Story 1 > Sprint 1  > Task 1",
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(12, context),
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.02,
                                color: ColorConfig.primary3)),
                      )
                    ]
                ),
                SizedBox(height: ScaleUtils.scaleSize(9, context)),
                Text(AppText.titleNameTask.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(14, context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                        color: ColorConfig.textColor6)),
                SizedBox(height: ScaleUtils.scaleSize(9, context)),
                InputField(hintText: AppText.textCreateNameForTask.text,
                    controller: cubit.conName, radius: 90,),
                SizedBox(height: ScaleUtils.scaleSize(9, context)),
                Text(AppText.titleDescription.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(14, context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                        color: ColorConfig.textColor6)),
                SizedBox(height: ScaleUtils.scaleSize(9, context)),
                InputField(hintText: AppText.textTaskDescription.text,
                    controller: cubit.conDes, minLines: 5, radius: 11,),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CreateSubTaskCubit extends Cubit<int> {
  CreateSubTaskCubit() : super(0);

  final TextEditingController conName = TextEditingController();
  final TextEditingController conDes = TextEditingController();
  int duration = 30;

  initData() {

  }

  updateDuration(int value) {
    duration = value;
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}