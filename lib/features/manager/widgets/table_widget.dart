import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_routes.dart';
import 'package:whms/untils/scale_utils.dart';

class TableWidget extends StatelessWidget {
  const TableWidget(
      {super.key,
      required this.titleHeader,
      required this.weightHeader,
      required this.listData});

  final List<String> titleHeader;
  final List<int> weightHeader;
  final List<List<String>> listData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(9, context),
              vertical: ScaleUtils.scaleSize(12, context)),
          decoration: BoxDecoration(
              color: ColorConfig.primary2,
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context))),
          child: Row(
            children: [
              ...titleHeader.asMap().entries.map((item) => Expanded(
                    flex: weightHeader[item.key],
                    child: Row(
                      children: [
                        Text(
                          item.value,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(16, context),
                              fontWeight: FontWeight.w500,
                              color: ColorConfig.textPrimary,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (item.key < titleHeader.length - 1)
                          SizedBox(
                            width: ScaleUtils.scaleSize(5, context),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(
          height: ScaleUtils.scaleSize(9, context),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...listData.map(
                  (element) => Container(
                    margin: EdgeInsets.only(bottom: ScaleUtils.scaleSize(9, context)),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(9, context),
                        vertical: ScaleUtils.scaleSize(12, context)),
                    decoration: BoxDecoration(
                        color: ColorConfig.textPrimary,
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(8, context))),
                    child: InkWell(
                      onTap: () {
                        context.go("${AppRoutes.profile}/${element.first}");
                      },
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Row(
                        children: [
                          ...element.sublist(1).asMap().entries.map((item) => Expanded(
                                flex: weightHeader[item.key],
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.value,
                                        style: TextStyle(
                                            fontSize:
                                                ScaleUtils.scaleSize(14, context),
                                            fontWeight: FontWeight.w500,
                                            color: ColorConfig.textSecondary,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    if (item.key < titleHeader.length - 1)
                                      SizedBox(
                                        width: ScaleUtils.scaleSize(5, context),
                                      ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
