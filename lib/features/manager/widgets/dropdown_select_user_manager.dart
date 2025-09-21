import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/dropdown_search_user_for_manager.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class DropdownSelectUserManager extends StatelessWidget {
  const DropdownSelectUserManager({
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

  final List<UserModel> options;
  final UserModel? defaultValue;
  final Function(UserModel?)? onChanged;
  final String title;
  final double fontSize;
  final Color textColor;
  final String hintText;
  final Color colorHint;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/icons/profile_icon/ic_${title == AppText.titleOwner.text ? "handler" : "leader"}.png',
              height: ScaleUtils.scaleSize(24, context), color: ColorConfig.primary1
            ),
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
        SizedBox(height: ScaleUtils.scaleSize(5, context)),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
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
                    vertical: ScaleUtils.scaleSize(5, context),
                    horizontal: ScaleUtils.scaleSize(0, context),
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
                child: DropdownSearchUserForManager(
                  maxHeight: 40,
                  onChanged: (v) {
                    if (onChanged != null) {
                      onChanged!(v);
                    }
                  },
                  initItem: defaultValue ?? UserModel(),
                  options: options,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
