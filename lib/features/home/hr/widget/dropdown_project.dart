import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';

class DropdownProject extends StatefulWidget {
  final Function(WorkingUnitModel?)? onChanged;
  final WorkingUnitModel initTime;
  final List<WorkingUnitModel> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;

  // TO DO
  const DropdownProject({
    super.key,
    required this.onChanged,
    required this.initTime,
    required this.options,
    this.fontSize = 16,
    this.maxWidth = 80,
    this.maxHeight = 20,
    this.radius = 12,
  });

  @override
  DropdownProjectState createState() => DropdownProjectState();
}

class DropdownProjectState extends State<DropdownProject> {
  late WorkingUnitModel selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(widget.maxWidth, context),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(56, context)),
          color: Colors.white,
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: ColorConfig.primary3),
          boxShadow: const [ColorConfig.boxShadow2]),
      // height: ScaleUtils.scaleSize(widget.maxHeight, context),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) =>
            DropdownButtonFormField2<WorkingUnitModel>(
          isExpanded: true,
          decoration: InputDecoration(
            constraints: BoxConstraints(
                maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context)),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(2, context)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
          ),
          value: selectedItem,
          selectedItemBuilder: (context) {
            return widget.options
                .map((item) => ProjectViewWidget(
                      item: item,
                      fontSize: widget.fontSize,
                      isSelected: true,
                    ))
                .toList();
          },
          items: widget.options.map((item) {
            return DropdownMenuItem<WorkingUnitModel>(
              alignment: Alignment.centerRight,
              value: item,
              child: ProjectViewWidget(
                  item: item, fontSize: widget.fontSize, isSelected: false),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedItem = newValue!;
            });
            widget.onChanged?.call(newValue);
          },
          onMenuStateChange: (v) => isOpen.value = v,
          iconStyleData: const IconStyleData(
            icon: SizedBox.shrink(),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: ScaleUtils.scaleSize(200, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  ScaleUtils.scaleSize(widget.radius, context)),
            ),
            scrollbarTheme: ScrollbarThemeData(
              trackVisibility: WidgetStateProperty.all(false),
              thickness: WidgetStateProperty.all(0),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: ScaleUtils.scaleSize(32, context),
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(4, context),
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectViewWidget extends StatelessWidget {
  const ProjectViewWidget(
      {super.key,
      required this.item,
      required this.fontSize,
      required this.isSelected});

  final WorkingUnitModel item;
  final double fontSize;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: isSelected
            ? null
            : BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(56, context)),
                color: Colors.white,
                border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.primary3)),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(6, context),
            vertical: ScaleUtils.scaleSize(0, context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(item.title,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(fontSize, context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.41,
                        color: ColorConfig.primary3,
                        shadows: const [ColorConfig.textShadow],
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            if (isSelected)
              Image.asset(
                'assets/images/icons/ic_dropdown.png',
                height: ScaleUtils.scaleSize(6, context),
                color: ColorConfig.primary3,
              )
          ],
        ),
      ),
    );
  }
}
