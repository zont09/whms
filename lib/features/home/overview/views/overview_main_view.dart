import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:flutter/material.dart';
import 'package:whms/features/home/overview/views/other_info_view.dart';
import 'package:whms/features/home/overview/views/overview_data_view.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';

class OverviewMainView extends StatefulWidget {
  const OverviewMainView({super.key, required this.tab, required this.cubit});

  final String tab;
  final OverviewTabCubit cubit;

  @override
  State<OverviewMainView> createState() => _OverviewMainViewState();
}

class _OverviewMainViewState extends State<OverviewMainView> {
  @override
  void initState() {
    super.initState();
    if (widget.tab == "1") {
      if (widget.cubit.listScopeUser.isNotEmpty) {
        widget.cubit.changeTabSelected(widget.cubit.listScopeUser.first.id);
      }
    } else {
      widget.cubit.changeTabSelected(widget.tab);
    }
  }

  @override
  void didUpdateWidget(OverviewMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      if (widget.tab == "1") {
        if (widget.cubit.listScopeUser.isNotEmpty) {
          widget.cubit.changeTabSelected(widget.cubit.listScopeUser.first.id);
        }
      } else {
        widget.cubit.changeTabSelected(widget.tab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: InvisibleScrollBarWidget(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 27,
                child: Container(
                  child: SingleChildScrollView(
                    child: OverviewDataView(cubit: widget.cubit,)
                  ),
                )),
            // Expanded(flex: 10, child: OtherInfoView(cubit: widget.cubit))
          ],
        ));
  }
}
