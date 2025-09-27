import 'package:flutter/material.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';

class DocumentAndAnnounceView extends StatelessWidget {
  const DocumentAndAnnounceView({super.key, required this.cubit});

  final MainTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.all( ScaleUtils.scaleSize(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const AnnounceView(),
            // SizedBox(height: ScaleUtils.scaleSize(28, context),),
            // MeetingView(cubit: cubit,),
            // SizedBox(height: ScaleUtils.scaleSize(28, context),),
            // const NoteView()
          ],
        ),
      ),
    );
  }
}


