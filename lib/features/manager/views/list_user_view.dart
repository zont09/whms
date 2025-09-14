import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/user_tab_cubit.dart';
import 'package:whms/features/manager/views/user_tab.dart';
import 'package:whms/features/manager/widgets/navigator_page.dart';
import 'package:whms/features/manager/widgets/table_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/z_space.dart';

class ListUserView extends StatelessWidget {
  const ListUserView({
    super.key,
    required this.controllerSearch,
    required this.dataPerPage,
    required this.listHeader,
    required this.listWeight,
    required this.cubitUser,
  });

  final TextEditingController controllerSearch;
  final int dataPerPage;
  final List<String> listHeader;
  final List<int> listWeight;
  final UserTabCubit cubitUser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataTableCubit()..initData(),
      child: BlocBuilder<DataTableCubit, int>(
        builder: (cc, ss) {
          var cubitData = BlocProvider.of<DataTableCubit>(cc);
          return Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(150, context),
                vertical: ScaleUtils.scaleSize(20, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFBF0000),
                        Color(0xFF590000),
                      ],
                      stops: [0.2237, 1.6053],
                    ).createShader(bounds);
                  },
                  child: Text(
                    AppText.txtListStaff.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(28, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: ScaleUtils.scaleSize(15, context)),
                Row(
                  children: [
                    CustomButton(
                        title: AppText.btnAddStaff.text,
                        icon: 'assets/images/icons/ic_add.png',
                        colorBackground: Colors.white,
                        colorBorder: Colors.white,
                        colorTitle: ColorConfig.primary2,
                        isShadow: true,
                        sizeTitle: 14,
                        sizeIcon: 24,
                        paddingVer: 6,
                        paddingHor: 8,
                        fontWeight: FontWeight.w600,
                        onPressed: () {
                          cubitUser.changeMode(1);
                        }),
                    const Spacer(),
                    DropdownString(
                        onChanged: (v) {
                          cubitData.onChangeRole(v!);
                        },
                        maxWidth: 120,
                        maxHeight: 32,
                        radius: 8,
                        initItem: cubitData.filterRole,
                        options: [
                          AppText.textAllRole.text,
                          AppText.textManager.text,
                          AppText.textSubManager.text,
                          AppText.textHandler.text,
                          AppText.textTasker.text,
                        ]),
                    const ZSpace(w: 12),
                    DropdownString(
                        onChanged: (v) {
                          cubitData.onChangeDepartment(v!);
                        },
                        maxWidth: 120,
                        maxHeight: 32,
                        radius: 8,
                        initItem: cubitData.filterDepartment,
                        options: [
                          AppText.textAllDepartment.text,
                          AppText.textTeamIT.text,
                          AppText.textTeamDesigns.text,
                          AppText.textTeamData.text,
                          AppText.textTeamSales.text,
                          AppText.textTeamSupports.text,
                          AppText.textTeamMarketing.text,
                          AppText.textTeamHR.text,
                          AppText.textTeamOther.text
                        ])
                  ],
                ),
                SizedBox(height: ScaleUtils.scaleSize(10, context)),
                SearchField(
                  controller: cubitData.conSearch,
                  mainColor: ColorConfig.primary1,
                  padVer: 5,
                  padHor: 10,
                  onChanged: (value) {
                    cubitData.onChangeSearch();
                  },
                ),
                SizedBox(height: ScaleUtils.scaleSize(15, context)),
                Expanded(
                  child: BlocProvider(
                    create: (context) => NavigatorPageCubit(
                        (cubitData.listData.length - 1) ~/ dataPerPage + 1),
                    child: BlocBuilder<NavigatorPageCubit, int>(
                      builder: (c, s) {
                        var cubit = BlocProvider.of<NavigatorPageCubit>(c);
                        cubitData.stream.listen((_) {
                          cubit.updateNum(
                            (cubitData.listData.length - 1) ~/ dataPerPage + 1,
                          );
                        });
                        return Column(
                          children: [
                            Expanded(
                                child: TableWidget(
                                    titleHeader: listHeader,
                                    weightHeader: listWeight,
                                    listData: cubitData.listData.sublist(
                                        (s - 1) * dataPerPage,
                                        min(s * dataPerPage - 1,
                                            cubitData.listData.length)))),
                            SizedBox(height: ScaleUtils.scaleSize(9, context)),
                            NavigatorPage(cubit: cubit),
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
