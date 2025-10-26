import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/home/overview/views/overview_main_view.dart';
import 'package:whms/features/home/overview/widgets/overview_side_bar.dart';
import 'package:whms/widgets/app_bar/new_app_bar.dart';
import 'package:whms/widgets/loading_widget.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.tab});

  final String tab;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          BlocProvider(
            create: (context) => OverviewTabCubit(ConfigsCubit.fromContext(context))..initData(context),
            child: BlocBuilder<OverviewTabCubit, int>(
              builder: (c, s) {
                var cubit = BlocProvider.of<OverviewTabCubit>(c);
                return Column(
                  children: [
                    const NewAppBar(isHome: true, tab: 2),
                    Expanded(
                        child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: OverviewSideBar(
                              curTab: tab,
                              cubit: cubit,
                            )),
                        Expanded(
                            flex: 4,
                            child:
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.white,
                              child: s == 0
                                  ? LoadingWidget()
                                  : OverviewMainView(tab: tab, cubit: cubit),
                            )),
                      ],
                    ))
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
