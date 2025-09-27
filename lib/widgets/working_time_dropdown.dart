import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/time_card.dart';

class WorkingTimeDropdown extends StatefulWidget {
  final Function(int?)? onChanged;
  final int initTime;
  final bool isAddTask;
  final bool isRemove;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final bool isEdit;

  // TO DO
  const WorkingTimeDropdown({
    super.key,
    required this.onChanged,
    required this.initTime,
    required this.isAddTask,
    this.isRemove = true,
    this.fontSize = 8,
    this.maxWidth = 80,
    this.maxHeight = 20,
    this.radius = 12,
    required this.isEdit,
  });

  @override
  WorkingTimeDropdownState createState() => WorkingTimeDropdownState();
}

class WorkingTimeDropdownState extends State<WorkingTimeDropdown> {
  late int selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  List<int> items = [0, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570, 600, 630, 660, 690, 720, 750, 780, 810, 840, 870, 900, 930, 960, 990, 1020, 1050, 1080, 1110, 1140, 1170, 1200, 1230, 1260, 1290, 1320, 1350, 1380, 1410, 1440];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initTime;
    // items.addAll(generateList());
  }

  List<int> generateList() {
    final List<int> items = [];
    int current = 60;

    while (current <= 240) {
      items.add(current);
      current += 30;
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.isEdit,
      child: Container(
        width: ScaleUtils.scaleSize(widget.maxWidth, context),
        decoration: BoxDecoration(
          color: ColorConfig.timeSecondary,
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(widget.radius, context)),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isOpen,
          builder: (context, value, child) => DropdownButtonFormField2<int>(
            isExpanded: true,
            decoration: InputDecoration(
              constraints: BoxConstraints(
                maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(2, context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius / 2),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0),
              ),
            ),
            value: selectedItem,
            selectedItemBuilder: (context) {
              return items
                  .map((item) => ItemSelected(
                        item: item,
                        fontSize: widget.fontSize,
                      ))
                  .toList();
            },
            items: items.map((item) {
              return DropdownMenuItem<int>(
                alignment: Alignment.centerRight,
                value: item,
                child: TimeCard(
                  time: DateTimeUtils.formatDuration(item),
                  fontSize: widget.fontSize,
                  paddingVer: 4,
                  paddingHor: 6,
                ),
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
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(widget.radius, context)),
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
      ),
    );
  }
}

class ItemSelected extends StatelessWidget {
  const ItemSelected({super.key, required this.item, required this.fontSize});

  final int item;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimeCard(
          time: DateTimeUtils.formatDuration(item),
          fontSize: fontSize,
          paddingVer: 2,
          paddingHor: 4,
        ),
        Image.asset(
          'assets/images/icons/ic_dropdown.png',
          height: ScaleUtils.scaleSize(4, context),
        )
      ],
    );
  }
}
