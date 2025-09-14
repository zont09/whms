import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator(
      {super.key,
      required this.maxPage,
      this.initPage = 1,
      this.cntPage = 5,
      required this.onChangePage});

  final int maxPage;
  final int initPage;
  final int cntPage;
  final Function(int) onChangePage;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  int currentPage = 1;
  int start = 1;
  int end = 1;

  @override
  void initState() {
    selectPage(widget.initPage);
    super.initState();
  }

  selectPage(int v) {
    currentPage = max(1, min(widget.maxPage, v));
    int cnt = widget.cntPage ~/ 2;
    start = max(currentPage - cnt, 1);
    cnt = widget.cntPage - (currentPage - start + 1);
    end = min(currentPage + cnt, widget.maxPage);
    if (end - start + 1 < widget.cntPage) {
      cnt = widget.cntPage - (end - currentPage + 1);
      start = max(currentPage - cnt, 1);
    }
    widget.onChangePage(currentPage);
  }

  @override
  Widget build(BuildContext context) {
    const double size = 35;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              selectPage(currentPage - 1);
            });
          },
          child: Container(
            height: ScaleUtils.scaleSize(size, context),
            width: ScaleUtils.scaleSize(size, context),
            decoration: BoxDecoration(
                color: ColorConfig.primary3,
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
                border: Border.all(
                    width: ScaleUtils.scaleSize(2, context),
                    color: Colors.transparent),
                boxShadow: const [ColorConfig.boxShadow]),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_left,
                size: ScaleUtils.scaleSize(30, context),
                color: Colors.white,
              ),
            ),
          ),
        ),
        const ZSpace(w: 8),
        ...List.generate(
            end - start + 1,
            (index) => ItemPageIndicator(
                page: index + start,
                size: size,
                isSelected: index + start == currentPage,
                onTap: () {
                  setState(() {
                    selectPage(index + start);
                  });
                })),
        const ZSpace(w: 8),
        InkWell(
          onTap: () {
            setState(() {
              selectPage(currentPage + 1);
            });
          },
          child: Container(
            height: ScaleUtils.scaleSize(size, context),
            width: ScaleUtils.scaleSize(size, context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ColorConfig.primary3,
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
                border: Border.all(
                    width: ScaleUtils.scaleSize(2, context),
                    color: Colors.transparent),
                boxShadow: const [ColorConfig.boxShadow]),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_right,
                size: ScaleUtils.scaleSize(30, context),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemPageIndicator extends StatelessWidget {
  const ItemPageIndicator(
      {super.key,
      required this.size,
      required this.page,
      required this.isSelected,
      required this.onTap});

  final double size;
  final int page;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          height: ScaleUtils.scaleSize(size, context),
          width: ScaleUtils.scaleSize(size, context),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(4, context)),
              border: Border.all(
                  width: ScaleUtils.scaleSize(2, context),
                  color:
                      isSelected ? ColorConfig.primary3 : Colors.transparent),
              boxShadow: const [ColorConfig.boxShadow]),
          margin: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(4, context)),
          child: Center(
            child: Text("$page",
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(16, context),
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          )),
    );
  }
}
