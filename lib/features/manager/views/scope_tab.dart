import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/list_scope_cubit.dart';
import 'package:whms/features/manager/views/scope_popup.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_full_item.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/loading_widget.dart';
import 'package:whms/widgets/page_indicator.dart';
import 'package:whms/widgets/search_field.dart';

class ScopeTab extends StatelessWidget {
  final TextEditingController controllerSearch;
  final TextEditingController titleController;
  final TextEditingController desController;

  ScopeTab({super.key})
      : controllerSearch = TextEditingController(),
        titleController = TextEditingController(),
        desController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListScopeCubit()..load(),
      child: BlocBuilder<ListScopeCubit, int>(
          builder: (c, list) {
        var cubit = BlocProvider.of<ListScopeCubit>(c);
        if (list == 0) {
          return const LoadingWidget();
        }
        if (cubit.listFull.isEmpty) const Text('no data');

        return SingleChildScrollView(
            //key: Key('${list.length}'),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scalePadding(150, context),
                vertical: ScaleUtils.scalePadding(20, context)),
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
                    AppText.txtListScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(28, context),
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),

                SizedBox(height: ScaleUtils.scaleSize(20, context)),
                CustomButton(
                    title: AppText.btnAddScope.text,
                    icon: 'assets/images/icons/ic_add_meeting.png',
                    colorBackground: Colors.white,
                    colorBorder: Colors.white,
                    colorTitle: ColorConfig.primary2,
                    isShadow: true,
                    sizeTitle: 14,
                    sizeIcon: 24,
                    paddingVer: 6,
                    paddingHor: 8,
                    fontWeight: FontWeight.w600,
                    onPressed: () async {
                      await DialogUtils.showAlertDialog(context,
                          child: ScopePopup());
                      await cubit.load();
                    }),
                // SearchField(
                //   controller: controllerSearch,
                //   mainColor: ColorConfig.primary1,
                //   onChanged: (v) {},
                // ),
                // SizedBox(
                //   height: ScaleUtils.scaleSize(20, context),
                // ),
                // Row(
                //   children: [
                //     CustomButton(
                //         title: AppText.btnAddScope.text,
                //         icon: 'assets/images/icons/ic_add.png',
                //         colorIcon: Colors.white,
                //         onPressed: () async {
                //           await DialogUtils.showAlertDialog(context,
                //               child: ScopePopup());
                //           await cubit.load();
                //         }),
                //     SizedBox(width: ScaleUtils.scaleSize(10, context)),
                //     CustomButton(
                //         title: AppText.btnFilterWork.text,
                //         icon: 'assets/images/icons/ic_filter_1.png',
                //         onPressed: () {}),
                //   ],
                // ),
                SizedBox(height: ScaleUtils.scaleSize(20, context)),
                SearchField(
                  controller: cubit.conSearch,
                  mainColor: ColorConfig.primary1,
                  padVer: 5,
                  padHor: 10,
                  onChanged: (value) {
                    cubit.onChangeSearch();
                  },
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ...cubit.listShow
                          .skip((cubit.currentPage - 1) * cubit.itemPerPage)
                          .take(cubit.itemPerPage)
                          .map((f) => ScopeFullItem(f)),
                      PageIndicator(
                          maxPage: cubit.maxPage,
                          initPage: cubit.currentPage,
                          onChangePage: (v) {
                            cubit.changePage(v);
                          })
                    ],
                  ),
                )
              ],
            ));
      }),
    );
  }
}
