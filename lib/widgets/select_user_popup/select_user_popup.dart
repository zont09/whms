import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/widgets/dropdown_search_user_for_manager.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/select_user_popup/select_user_cubit.dart';

class SelectUserPopup extends StatelessWidget {
  const SelectUserPopup(
      {super.key,
      required this.listUsers,
      required this.listSelected,
      required this.onSelect});

  final List<UserModel> listUsers;
  final List<UserModel> listSelected;
  final Function(UserModel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(520, context),
      height: MediaQuery.of(context).size.height * 4 / 5,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: Colors.white),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
      child: BlocProvider(
        create: (context) =>
            SelectUserCubit()..initData(listUsers, listSelected),
        child: BlocBuilder<SelectUserCubit, int>(
          builder: (c, s) {
            var cubit = BlocProvider.of<SelectUserCubit>(c);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.textSelectScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(20, context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                        color: ColorConfig.textColor6,
                        shadows: const [ColorConfig.textShadow])),
                const ZSpace(h: 9),
                SearchField(
                    controller: cubit.conSearch,
                    fontSize: 14,
                    padVer: 4,
                    padHor: 6,
                    onChanged: (v) {
                      cubit.changeSearch();
                    }),
                const ZSpace(h: 9),
                Expanded(
                  child: ScrollConfiguration(
                      behavior: InvisibleScrollBarWidget(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...cubit.listShow.map((e) {
                              return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          ScaleUtils.scaleSize(3.5, context)),
                                  child: InkWell(
                                    onTap: () async {
                                      await onSelect(e);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: CardUserItem(
                                      user: e,
                                      fontSize: 14,
                                      isSelected: false,
                                      textColor: ColorConfig.textColor,
                                    ),
                                  ));
                            })
                          ],
                        ),
                      )),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
