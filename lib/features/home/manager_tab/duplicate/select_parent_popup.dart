import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/manager_tab/bloc/duplicate_working_unit_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../untils/text_utils.dart';

class SelectParentPopup extends StatelessWidget {
  const SelectParentPopup({super.key, required this.cubitDp});

  final DuplicateWorkingUnitCubit cubitDp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SelectParentDupWUCubit()..changeListData(cubitDp.listEpic),
      child: BlocBuilder<SelectParentDupWUCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<SelectParentDupWUCubit>(c);
          return Container(
            height: MediaQuery.of(context).size.height * 3 / 5,
            width: ScaleUtils.scaleSize(600, context),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(24, context)),
                color: Colors.white),
            padding: EdgeInsets.symmetric(
                vertical: ScaleUtils.scaleSize(24, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(24, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.titleChooseParentDuplicateWU.text,
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(24, context),
                              fontWeight: FontWeight.w700,
                              color: ColorConfig.textColor6,
                              shadows: const [ColorConfig.textShadow])),
                      if (cubit.epic != null)
                        InkWell(
                            onTap: () {
                              cubit.story = null;
                              cubit.sprint = null;
                              cubit.epic = null;
                              cubit.changeListData(cubitDp.listEpic.toList());
                              cubit.isEnd = false;
                              cubit.EMIT();
                            },
                            child: TaskCardDup(model: cubit.epic!)),
                      if (cubit.epic != null) const ZSpace(h: 5),
                      if (cubit.sprint != null)
                        Row(
                          children: [
                            Image.asset(
                                'assets/images/icons/ic_link_duptask.png',
                                height: ScaleUtils.scaleSize(30, context)),
                            // Icon(Icons.link),
                            const ZSpace(w: 4),
                            InkWell(
                                onTap: () {
                                  cubit.story = null;
                                  cubit.sprint = null;
                                  cubit.changeListData(cubitDp.listSprint
                                      .where((f) => f.parent == cubit.epic!.id)
                                      .toList());
                                  cubit.isEnd = false;
                                  cubit.EMIT();
                                },
                                child: TaskCardDup(model: cubit.sprint!)),
                          ],
                        ),
                      if (cubit.sprint != null) const ZSpace(h: 5),
                      if (cubit.story != null)
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScaleUtils.scaleSize(40, context)),
                          child: Row(
                            children: [
                              Image.asset(
                                  'assets/images/icons/ic_link_duptask.png',
                                  height: ScaleUtils.scaleSize(30, context)),
                              const ZSpace(w: 4),
                              InkWell(
                                  onTap: () {
                                    cubit.story = null;
                                    cubit.changeListData(cubitDp.listStory
                                        .where(
                                            (f) => f.parent == cubit.sprint!.id)
                                        .toList());
                                    cubit.isEnd = false;
                                    cubit.EMIT();
                                  },
                                  child: TaskCardDup(model: cubit.story!)),
                            ],
                          ),
                        ),
                      if (cubit.sprint != null) const ZSpace(h: 5),
                      if (cubit.epic != null)
                        TaperedBar(
                          height: ScaleUtils.scaleSize(1.5, context),
                          color: ColorConfig.primary3,
                        ),
                      const ZSpace(h: 9),
                      if (!cubit.isEnd)
                        SearchField(
                            fontSize: 16,
                            padVer: 4,
                            padHor: 6,
                            controller: cubit.conSearch,
                            onChanged: (v) {
                              cubit.onChangeSearch();
                            }),
                      const ZSpace(h: 9),
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(24, context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!cubit.isEnd)
                          ...cubit.listShow.map((e) => Column(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        if (cubit.epic == null) {
                                          cubit.epic = e;
                                        } else if (cubit.sprint == null) {
                                          cubit.sprint = e;
                                        } else if (cubit.story == null) {
                                          cubit.story = e;
                                        } else {
                                          cubit.isEnd = true;
                                          cubit.EMIT();
                                          return;
                                        }
                                        cubit.changeListData(cubitDp.listWU
                                            .where((f) => f.parent == e.id)
                                            .toList());
                                        if (TypeAssignmentDefineExtension
                                                    .priority(e.type) -
                                                TypeAssignmentDefineExtension
                                                    .priority(
                                                        cubitDp.work.type) ==
                                            1) {
                                          cubit.isEnd = true;
                                          cubit.EMIT();
                                        }
                                      },
                                      child: TaskCardDup(model: e)
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.circular(
                                      //           ScaleUtils.scaleSize(8, context)),
                                      //       color: Colors.white,
                                      //       boxShadow: const [ColorConfig.boxShadow2]),
                                      //   margin: EdgeInsets.symmetric(
                                      //       vertical: ScaleUtils.scaleSize(4, context)),
                                      //   padding: EdgeInsets.symmetric(
                                      //       horizontal:
                                      //           ScaleUtils.scaleSize(6, context),
                                      //       vertical: ScaleUtils.scaleSize(3, context)),
                                      //   child: Text(e.title,
                                      //       style: TextStyle(
                                      //           fontSize:
                                      //               ScaleUtils.scaleSize(16, context),
                                      //           fontWeight: FontWeight.w500,
                                      //           color: ColorConfig.textColor)),
                                      // ),
                                      ),
                                  const ZSpace(h: 9)
                                ],
                              ))
                      ],
                    ),
                  ),
                )),
                const ZSpace(h: 9),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(24, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ZButton(
                          title: AppText.btnCancel.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorBackground: Colors.white,
                          colorBorder: Colors.white,
                          colorTitle: ColorConfig.primary2,
                          paddingHor: 12,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      const ZSpace(w: 9),
                      ZButton(
                          title: AppText.btnOk.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorBackground: const Color(0xFFFF2932),
                          colorBorder: const Color(0xFFFF2932),
                          colorTitle: Colors.white,
                          paddingHor: 24,
                          onPressed: () async {
                            WorkingUnitModel? model;
                            if (cubit.story != null) {
                              model = cubit.story;
                            } else if (cubit.sprint != null) {
                              model = cubit.sprint;
                            } else if (cubit.epic != null) {
                              model = cubit.epic;
                            }
                            debugPrint("====> Model parent: ${model?.title}");
                            if (model != null) {
                              cubitDp.selectParent(model);
                            }
                            Navigator.of(context).pop();
                          })
                    ],
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

class SelectParentDupWUCubit extends Cubit<int> {
  SelectParentDupWUCubit() : super(0);

  WorkingUnitModel? epic;
  WorkingUnitModel? sprint;
  WorkingUnitModel? story;
  final TextEditingController conSearch = TextEditingController();

  List<WorkingUnitModel> listData = [];
  List<WorkingUnitModel> listShow = [];

  bool isEnd = false;

  changeListData(List<WorkingUnitModel> data) {
    listData.clear();
    listShow.clear();
    listData.addAll(data);
    listShow.addAll(data);
    conSearch.text = "";
    EMIT();
  }

  onChangeSearch() {
    if (conSearch.text.isEmpty) {
      listShow.clear();
      listShow.addAll(listData);
    } else {
      listShow.clear();
      listShow.addAll(listData.where(
          (e) => TextUtils.normalizeString(e.title).contains(conSearch.text)));
    }
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}

class TaskCardDup extends StatelessWidget {
  const TaskCardDup({super.key, required this.model, this.remove});

  final WorkingUnitModel model;
  final Function()? remove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: ScaleUtils.scaleSize(520, context)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(229),
          border: Border.all(
              width: ScaleUtils.scaleSize(1.5, context),
              color: ColorConfig.primary3),
          color: Colors.white),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(8, context),
          vertical: ScaleUtils.scaleSize(2, context)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "${TextUtils.firstCharInString(model.type).toUpperCase()}: ${model.title}",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  color: ColorConfig.primary3),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          if (remove != null) const ZSpace(w: 3),
          if (remove != null)
            InkWell(
              onTap: remove!,
              child: Image.asset('assets/images/icons/ic_delete.png',
                  height: ScaleUtils.scaleSize(12, context),
                  color: ColorConfig.primary3),
            )
        ],
      ),
    );
  }
}

class TaperedBar extends StatelessWidget {
  final double height;
  final Color color;

  const TaperedBar({
    Key? key,
    this.height = 4,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _TaperedBarPainter(color),
    );
  }
}

class _TaperedBarPainter extends CustomPainter {
  final Color color;

  _TaperedBarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.25, 0);
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
