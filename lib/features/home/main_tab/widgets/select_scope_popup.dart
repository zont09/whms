import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/select_scope_cubit.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/search_field.dart';
import 'package:whms/widgets/z_space.dart';

class SelectScopePopup extends StatelessWidget {
  const SelectScopePopup(
      {super.key,
      required this.listScope,
      required this.listSelected,
      required this.onSelect});

  final List<ScopeModel> listScope;
  final List<ScopeModel> listSelected;
  final Function(ScopeModel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(520, context),
      height: MediaQuery.of(context).size.height * 4 / 5,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: Colors.white),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
      child: BlocProvider(
        create: (context) =>
            SelectScopeCubit()..initData(listScope, listSelected),
        child: BlocBuilder<SelectScopeCubit, int>(
          builder: (c, s) {
            var cubit = BlocProvider.of<SelectScopeCubit>(c);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppText.textSelectScope.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(20, context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                        color: ColorConfig.textColor6,
                        shadows: const [ColorConfig.textShadow])),
                const ZSpace(h: 9),
                SearchField(
                    controller: cubit.conSearch,
                    fontSize: 14,
                    padVer: 4,
                    padHor: 6,
                    onChanged: (v) {
                      cubit.changeSearch();
                    }),
                const ZSpace(h: 9),
                Expanded(
                  child: ScrollConfiguration(
                      behavior: InvisibleScrollBarWidget(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...cubit.listShow.map((e) {
                              final isSelected = cubit.listSelected.any((i) => i.id == e.id);
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical:
                                        ScaleUtils.scaleSize(3.5, context)),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (!isSelected) {
                                          cubit.selectScope(e);
                                        } else {
                                          cubit.removeScope(e);
                                        }
                                        onSelect(e);
                                      },
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_box_rounded
                                            : Icons.check_box_outline_blank,
                                        size: ScaleUtils.scaleSize(20, context),
                                        color: isSelected
                                            ? ColorConfig.primary3
                                            : ColorConfig.textColor,
                                      ),
                                    ),
                                    const ZSpace(w: 9),
                                    Expanded(child: ScopeCard(scope: e))
                                  ],
                                ),
                              );
                            })
                          ],
                        ),
                      )),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScopeCard extends StatelessWidget {
  const ScopeCard({super.key, required this.scope, this.remove});

  final ScopeModel scope;
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
              scope.title,
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
