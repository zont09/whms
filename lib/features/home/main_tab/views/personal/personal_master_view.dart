import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/views/personal/personal_main_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class PersonalMasterView extends StatefulWidget {
  const PersonalMasterView({super.key, required this.cubit});

  final MainTabCubit cubit;

  @override
  State<PersonalMasterView> createState() => _PersonalMasterViewState();
}

class _PersonalMasterViewState extends State<PersonalMasterView> {
  String tab = AppText.titleOverview.text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey("key_personal_master_view_${tab}"),
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
        child: PersonalMainView(cubitMT: widget.cubit),
      ),
    );
  }
}
