import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/dropdown_custom.dart';
import 'package:whms/untils/scale_utils.dart';

class DropdownLikeText extends StatelessWidget {
  const DropdownLikeText(
      {super.key,
      required this.options,
      this.initValue,
      this.fontSize = 12,
      this.textColor = ColorConfig.textColor,
      required this.onChanged});

  final List<String> options;
  final String? initValue;
  final double fontSize;
  final Color textColor;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DropDownCubit()..initData(initValue ?? options.firstOrNull ?? ""),
      child: BlocBuilder<DropDownCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<DropDownCubit>(c);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  value: cubit.selectedValue,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: ScaleUtils.scaleSize(16, context),
                        color: textColor,
                      ),
                      SizedBox(width: ScaleUtils.scaleSize(4, context)),
                    ],
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Afacad',
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    fontSize: ScaleUtils.scaleSize(fontSize, context),
                  ),
                  onChanged: (String? newValue) {
                    cubit.changeValue(newValue!);
                    onChanged(newValue);
                  },
                  items: options.map<DropdownMenuItem<String>>((String value) {
                    // final isSelected = value == cubit.selectedValue;
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    );
                  }).toList(),
                  buttonStyleData: ButtonStyleData(
                    height: ScaleUtils.scaleSize(30, context),
                    width: ScaleUtils.scaleSize(140, context),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(4, context)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                    ),
                    // elevation: 2
                  ),
                  iconStyleData: IconStyleData(
                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                    iconSize: ScaleUtils.scaleSize(16, context),
                    iconEnabledColor: textColor,
                    iconDisabledColor: Colors.grey[100],
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: ScaleUtils.scaleSize(200, context),
                    width: ScaleUtils.scaleSize(160, context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(8, context)),
                      color: Colors.white,
                    ),
                    offset: const Offset(0, 0),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: WidgetStateProperty.all<double>(
                          ScaleUtils.scaleSize(6, context)),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: ScaleUtils.scaleSize(40, context),
                    // padding: EdgeInsets.symmetric(left: ScaleUtils.scaleSize(40, context, right: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
