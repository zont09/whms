import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/widgets/scope_tab/scope_item.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/scale_utils.dart';

class ScopeFullItem extends StatelessWidget {
  final FullScopeEntry entry;

  const ScopeFullItem(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(vertical: ScaleUtils.scalePadding(20, context)),
        padding: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(10, context)),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(ScaleUtils.scalePadding(12, context)),
            border: Border.all(
                color: ColorConfig.border,
                width: ScaleUtils.scaleSize(1, context)),
            boxShadow: const [ColorConfig.boxShadow2]),
        child: Column(
          children: [
            ScopeItem(entry.model),
            ...entry.list.map((s) => ScopeItem(s)),
          ],
        ));
  }
}
