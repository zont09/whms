import 'package:whms/features/home/overview/views/ov_document_and_annouce.dart';
import 'package:whms/features/home/overview/views/ov_file_attachments_view.dart';
import 'package:whms/features/home/overview/views/ov_issue_list_view.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/no_data_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class OtherInfoView extends StatelessWidget {
  const OtherInfoView({super.key, required this.cubit});

  final OverviewTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000), // Màu #0000001A
                          offset: Offset(0, 4), // Tương ứng với 0px 4px
                          blurRadius: 4, // Tương ứng với 4px
                          spreadRadius: 0, // Tương ứng với 0px
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/icons/ic_okr.png',
                      height: ScaleUtils.scaleSize(24, context),
                      color: const Color(0xFFBF0000),
                    ),
                  ),
                  const ZSpace(w: 5),
                  Text(
                    AppText.titleListOkrs.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(16, context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.02,
                        color: ColorConfig.textColor,
                        shadows: const [ColorConfig.textShadow]),
                  ),
                ],
              ),
              const ZSpace(h: 9),
              const NoDataWidget(
                  imgSize: 60,
                  fontSizeTitle: 16,
                  fontSizeContent: 12,
                  data: "OKRS"),
              const ZSpace(h: 18),
              OVIssueListView(cubit: cubit),
              const ZSpace(h: 18),
              const OVDocumentAndAnnouce(),
              const ZSpace(h: 18),
              const OvFileAttachmentsView()
            ],
          ),
        ),
      ),
    );
  }
}
