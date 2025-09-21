import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/form_text_field.dart';
import 'package:whms/widgets/z_space.dart';

import '../configs/color_config.dart' show ColorConfig;

class DateFieldCustom extends StatefulWidget {
  const DateFieldCustom({
    Key? key,
    required this.controller,
    this.fontSize = 14,
    this.textColor = ColorConfig.textSecondary,
    this.hintText = "",
    this.colorHint = ColorConfig.hintText,
    required this.title,
    this.initialDate,
    this.onDateSelected,
    this.start,
    required this.isEdit,
  }) : super(key: key);
  final TextEditingController controller;
  final double fontSize;
  final Color textColor;
  final String title;
  final String hintText;
  final Color colorHint;
  final DateTime? initialDate;
  final bool isEdit;
  final DateTime? start;
  final Function(DateTime)? onDateSelected;

  @override
  _DateFieldCustomState createState() => _DateFieldCustomState();
}

class _DateFieldCustomState extends State<DateFieldCustom> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    widget.controller.text = _formatDate(_selectedDate);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectDate({DateTime? start}) async {
    final DateTime firstDate = start ?? DateTime(1900);
    if (_selectedDate.isBefore(firstDate)) {
      _selectedDate = firstDate;
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: start ?? DateTime(1900),
        lastDate: DateTime(2100),
        locale: const Locale('vi', 'VN'),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ColorConfig.primary1,
                  surface: Colors.white,
                ),
              ),
              child: child!);
        });
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.controller.text = _formatDate(picked);
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/icons/profile_icon/ic_birthday.png',
                height: ScaleUtils.scaleSize(24, context), color: ColorConfig.primary1),
            const ZSpace(w: 4),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: ScaleUtils.scaleSize(widget.fontSize + 1, context),
                color: widget.textColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: ScaleUtils.scaleSize(5, context)),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: widget.textColor,
              selectionColor: widget.textColor.withOpacity(0.3),
              selectionHandleColor: widget.textColor,
            ),
          ),
          child: InkWell(
            onTap: () async {
              if (widget.isEdit) {
                await _selectDate(start: widget.start);
              }
            },
            child: Container(
              decoration: BoxDecoration(
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
              child: FormTextField(widget: widget),
            ),
          ),
        ),
      ],
    );
  }
}
