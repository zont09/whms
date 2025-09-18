import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class TaskGeneralView extends StatelessWidget {
  const TaskGeneralView({
    super.key,
    required this.work,
    required this.mapAddress,
    required this.mapScope,
  });

  final WorkingUnitModel work;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, ScopeModel> mapScope;

  @override
  Widget build(BuildContext context) {
    final List<ScopeModel> scopes =
    work.scopes.map((item) => mapScope[item] ?? ScopeModel()).toList();
    // debugPrint("=====> Scopes: ${mapScope.length} - ${mapScope[work.scopes.first] ?? ""} - ${work.scopes.firstOrNull}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(direction: Axis.horizontal, children: [
          if (scopes.isNotEmpty)
            Tooltip(
                richMessage: TextSpan(
                  text: scopes[0].title + (scopes.length > 2 ? '\n' : ''),
                  style: const TextStyle(color: Colors.white),
                  children: [
                    ...scopes.skip(1).map((item) {
                      final isLast = item == scopes.skip(1).last;
                      return TextSpan(text: item.title + (isLast ? '' : '\n'));
                    })
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                ),
                child: Text(AppText.titleScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(11, context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA6A6A6)))),
          if (scopes.isEmpty)
            Tooltip(
                message: AppText.titlePersonal.text,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                ),
                child: Text(AppText.titleScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(11, context),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA6A6A6)))),
          if (mapAddress[work.id] != null && mapAddress[work.id]!.isNotEmpty)
            Text(" > ",
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(11, context),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFA6A6A6))),
          if (mapAddress[work.id] != null)
            for (int i = mapAddress[work.id]!.length - 1; i >= 0; i--)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Tooltip(
                    message: mapAddress[work.id]![i].title,
                    child: Text(mapAddress[work.id]![i].type,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(11, context),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFA6A6A6)))),
                if (i > 0)
                  Text(" > ",
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(11, context),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA6A6A6)))
              ])
        ]),
        SizedBox(height: ScaleUtils.scaleSize(2, context)),
        Text(
          work.title,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(14, context),
              fontWeight: FontWeight.w500,
              color: ColorConfig.textColor,
              overflow: TextOverflow.ellipsis,
              letterSpacing: -0.02),
          maxLines: 3,
        ),
      ],
    );
  }
}