import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart' as TextUtils;
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';

class DropdownSearchUser extends StatefulWidget {
  final Function(UserModel?)? onChanged;
  final UserModel initItem;
  final List<UserModel> options;
  final double fontSize;
  final double maxWidth;
  final double radius;
  final double maxHeight;
  final Color borderColor;
  final Color textColor;
  final bool centerItem;
  final String? icon;
  final bool isShowDropdownIcon;

  const DropdownSearchUser(
      {super.key,
      required this.onChanged,
      required this.initItem,
      required this.options,
      this.fontSize = 12,
      this.maxWidth = 180,
      this.maxHeight = 32,
      this.radius = 50,
      this.borderColor = ColorConfig.border7,
      this.textColor = ColorConfig.textColor,
      this.centerItem = false,
      this.icon,
      this.isShowDropdownIcon = true});

  @override
  DropdownStringState createState() => DropdownStringState();
}

class DropdownStringState extends State<DropdownSearchUser> {
  late UserModel selectedItem;
  ValueNotifier<bool> isOpen = ValueNotifier(false);
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredOptions = [];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initItem;
    filteredOptions.addAll(widget.options);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(widget.maxWidth, context),
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(
          //     ScaleUtils.scaleSize(widget.radius, context)),
          color: Colors.transparent,
          // border: Border.all(
          //     width: ScaleUtils.scaleSize(1, context),
          //     color: widget.borderColor),
          // boxShadow: const [ColorConfig.boxShadow2]
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isOpen,
        builder: (context, value, child) => DropdownButtonFormField2<UserModel>(
          buttonStyleData: ButtonStyleData(
          height: widget.maxHeight, // Set height for button only
          padding: EdgeInsets.zero,
        ),
          isExpanded: true,
          decoration: InputDecoration(
            constraints: BoxConstraints(
                maxHeight: ScaleUtils.scaleSize(widget.maxHeight, context)),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(0, context)),
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
            return filteredOptions
                .map((item) => CardUserItem(
                      user: item,
                      fontSize: widget.fontSize,
                      isSelected: true,
                      textColor: widget.textColor,
                    ))
                .toList();
          },
          items: filteredOptions.map((item) {
            return DropdownMenuItem<UserModel>(
              alignment: Alignment.centerRight,
              value: item,
              child: CardUserItem(
                user: item,
                fontSize: widget.fontSize,
                isSelected: false,
                textColor: widget.textColor,
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
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
            ),
            scrollbarTheme: ScrollbarThemeData(
              trackVisibility: WidgetStateProperty.all(false),
              thickness: WidgetStateProperty.all(0),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: ScaleUtils.scaleSize(widget.maxHeight, context),
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(4, context),
            ),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: searchController,
            searchInnerWidgetHeight: 40,
            searchInnerWidget: Container(
              height: ScaleUtils.scaleSize(40, context),
              padding: EdgeInsets.only(
                top: ScaleUtils.scaleSize(8, context),
                bottom: ScaleUtils.scaleSize(4, context),
                right: ScaleUtils.scaleSize(8, context),
                left: ScaleUtils.scaleSize(8, context),
              ),
              child: TextField(
                controller: searchController,
                style: TextStyle(
                    fontSize: widget.fontSize, color: ColorConfig.textColor),
                cursorColor: ColorConfig.textColor,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(10, context),
                    vertical: ScaleUtils.scaleSize(8, context),
                  ),
                  hintText: 'Tìm kiếm...',
                  hintStyle: TextStyle(
                    fontSize: ScaleUtils.scaleSize(widget.fontSize, context),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ScaleUtils.scaleSize(4, context),
                      ),
                      borderSide: BorderSide(color: ColorConfig.primary3)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ScaleUtils.scaleSize(4, context),
                      ),
                      borderSide: BorderSide(color: ColorConfig.primary3)),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredOptions = [...widget.options
                        .where((option) =>
                            TextUtils.normalizeString(option.name)
                                .contains(TextUtils.normalizeString(value)) ||
                            option.id == selectedItem.id || value.isEmpty)];
                  });
                },
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return TextUtils.normalizeString(item.value!.name)
                      .contains(TextUtils.normalizeString(searchValue)) ||
                  item.value!.id == selectedItem.id || searchValue.isEmpty;
            },
          ),
        ),
      ),
    );
  }
}

class CardUserItem extends StatelessWidget {
  const CardUserItem({
    super.key,
    required this.user,
    required this.fontSize,
    required this.isSelected,
    required this.textColor,
  });

  final UserModel user;
  final double fontSize;
  final bool isSelected;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(229),
          color: Colors.white,
          border: Border.all(
              width: ScaleUtils.scaleSize(1, context),
              color: isSelected ? Colors.transparent : ColorConfig.border),
      boxShadow: isSelected ? const [ColorConfig.boxShadow2] : null),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(6, context),
          vertical: ScaleUtils.scaleSize(4, context)),
      margin: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(1, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarItem(user.avt, size: 24),
          const ZSpace(w: 4),
          Expanded(
            child: Text(
              user.name,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(12, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.textColor,
                  letterSpacing: -0.41, overflow: TextOverflow.ellipsis),
            ),
          ),
          if (isSelected) const ZSpace(w: 3),
          if (isSelected)
            Image.asset(
              'assets/images/icons/ic_dropdown.png',
              height: ScaleUtils.scaleSize(4, context),
              color: textColor,
            )
        ],
      ),
    );
  }
}
