import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class DropdownCustom extends StatelessWidget {
  const DropdownCustom({
    super.key,
    required this.options,
    this.defaultValue,
    this.onChanged,
    required this.title,
    this.fontSize = 14,
    this.textColor = ColorConfig.textSecondary,
    this.hintText = "",
    this.colorHint = ColorConfig.hintText,
    required this.isEdit,
  });

  final List<String> options;
  final String? defaultValue;
  final Function(String?)? onChanged;
  final String title;
  final double fontSize;
  final Color textColor;
  final String hintText;
  final Color colorHint;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final String selectedValue = defaultValue ?? options.first;
    String icon = "account";
    if(title == AppText.titleRole.text) {
      icon = "role";
    } else if(title == AppText.titleGender.text) {
      icon = "gender";
    } else if(title == AppText.titleDepartments.text) {
      icon = "department";
    } else if(title == AppText.titleWorkType.text) {
      icon = "type";
    } else if(title == AppText.titleStatus.text) {
      icon = "status";
    } else if(title == AppText.titleIdStaff.text) {
      icon = "code_user";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/icons/profile_icon/ic_$icon.png',
                height: ScaleUtils.scaleSize(24, context), color: ColorConfig.primary1),
            const ZSpace(w: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: ScaleUtils.scaleSize(fontSize + 1, context),
                color: ColorConfig.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScaleUtils.scaleSize(5, context),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: AbsorbPointer(
            absorbing: !isEdit,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScaleUtils.scaleSize(8, context),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    color: ColorConfig.shadow,
                  ),
                ],
              ),
              child: InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: ScaleUtils.scaleSize(11.5, context),
                    horizontal: ScaleUtils.scaleSize(12, context),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFFFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ScaleUtils.scaleSize(8, context),
                    ),
                    borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ScaleUtils.scaleSize(8, context),
                    ),
                    borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
                  ),
                ),
                child: BlocProvider(
                  create: (context) => DropDownCubit()..initData(selectedValue),
                  child: BlocBuilder<DropDownCubit, int>(
                    builder: (c, s) {
                      var cubit = BlocProvider.of<DropDownCubit>(c);
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isDense: true,
                          value: cubit.selectedValue,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: ScaleUtils.scaleSize(28, context),
                          style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(fontSize, context),
                            color: textColor,
                          ),
                          onChanged: (String? newValue) {
                            if (onChanged != null) {
                              onChanged!(newValue);
                            }
                            cubit.changeValue(newValue!);
                          },
                          items: options.map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize:
                                        ScaleUtils.scaleSize(fontSize, context),
                                    color: textColor,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DropDownCubit extends Cubit<int> {
  DropDownCubit() : super(0);

  String selectedValue = "";

  initData(String defaultValue) {
    selectedValue = defaultValue;
  }

  changeValue(String newValue) {
    selectedValue = newValue;
    emit(state + 1);
  }
}
