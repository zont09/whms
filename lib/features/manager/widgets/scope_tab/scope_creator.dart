import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/manager/blocs/list_scope_cubit.dart';
import 'package:whms/features/manager/blocs/scope_item_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class ScopeCreator extends StatelessWidget {
  final String avatar;
  final ScopeItemCubit cubit;

  const ScopeCreator({this.avatar = '', required this.cubit, super.key});

  @override
  Widget build(BuildContext context) {
    var reload = BlocProvider.of<ListScopeCubit>(context);
    return Row(
      children: [
        // Text(AppText.txtCreatorScope.text,
        //     style: TextStyle(
        //       color: ColorConfig.textColor,
        //       fontWeight: FontWeight.w600,
        //       fontSize: ScaleUtils.scaleSize(16, context),
        //     )),
        // SizedBox(width: ScaleUtils.scalePadding(10, context)),
        // CircleAvatar(
        //   radius: ScaleUtils.scaleSize(16, context),
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(10000),
        //     child: Image.network(
        //       avatar,
        //       errorBuilder: (_, __, ___) =>
        //           Container(color: ColorConfig.border),
        //     ),
        //   ),
        // ),
        const Spacer(),
        InkWell(
          onTap: () async {
            final isOk = await DialogUtils.showConfirmDialog(
                context,
                AppText.titleConfirmDelete.text,
                AppText.textConfirmDeleteScope.text
                    .replaceAll('@', cubit.scope.title));
            if(isOk) {
              await cubit.remove();
              await reload.load();
            }
          },
          child: Image.asset('assets/images/icons/ic_trash.png',
              height: ScaleUtils.scaleSize(24, context)),
        )
      ],
    );
  }
}
