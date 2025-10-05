import 'package:whms/features/home/main_tab/blocs/select_file_popup_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/comment/file_view_widget.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class SelectFilePopup extends StatelessWidget {
  const SelectFilePopup({super.key, required this.onUpload});

  final Function(FileAttachmentModel) onUpload;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectFilePopupCubit(),
      child: BlocBuilder<SelectFilePopupCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<SelectFilePopupCubit>(c);
          return Container(
            width: ScaleUtils.scaleSize(590, context),
            height: MediaQuery.of(context).size.height * 3 / 5,
            padding: EdgeInsets.all(ScaleUtils.scaleSize(22, context)),
            child: ScrollConfiguration(
              behavior: InvisibleScrollBarWidget(),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.titleAddFileAttachment.text,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(24, context),
                                fontWeight: FontWeight.w500,
                                color: ColorConfig.textColor6,
                                letterSpacing: -0.41,
                                height: 1.5,
                                shadows: const [ColorConfig.textShadow]),
                          ),
                          Text(AppText.textAddFileAttachmentDescription.text,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(16, context),
                                  fontWeight: FontWeight.w400,
                                  color: ColorConfig.textColor7,
                                  letterSpacing: -0.41,
                                  height: 1.5)),
                          const ZSpace(h: 9),
                          Text(
                            AppText.textNameFileAttachment.text,
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w500,
                                color: ColorConfig.textColor6,
                                shadows: const [ColorConfig.textShadow]),
                          ),
                          const ZSpace(h: 5),
                          TextFieldCustom(
                              controller: cubit.conTitle,
                              hint: AppText.textHintTitleFileAttachment.text,
                              isEdit: true),
                          const ZSpace(h: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (cubit.optionSelected != 0) {
                                    cubit.changeOption(0);
                                  }
                                },
                                child: Icon(
                                  cubit.optionSelected == 0
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: ScaleUtils.scaleSize(16, context),
                                  color: cubit.optionSelected == 0
                                      ? ColorConfig.primary3
                                      : const Color(0xFFB7B7B7),
                                ),
                              ),
                              const ZSpace(w: 6),
                              Text(
                                AppText.textLinkAttachment.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(14, context),
                                    fontWeight: FontWeight.w500,
                                    color: ColorConfig.textColor6,
                                    shadows: const [ColorConfig.textShadow]),
                              ),
                            ],
                          ),
                          const ZSpace(h: 5),
                          TextFieldCustom(
                              controller: cubit.conLink,
                              hint: AppText.textHintLinkFileAttachment.text,
                              isEdit: true),
                          const ZSpace(h: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (cubit.optionSelected != 1) {
                                    cubit.changeOption(1);
                                  }
                                },
                                child: Icon(
                                  cubit.optionSelected == 1
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: ScaleUtils.scaleSize(16, context),
                                  color: cubit.optionSelected == 1
                                      ? ColorConfig.primary3
                                      : const Color(0xFFB7B7B7),
                                ),
                              ),
                              const ZSpace(w: 6),
                              Text(
                                AppText.textFileAttachment.text,
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(14, context),
                                    fontWeight: FontWeight.w500,
                                    color: ColorConfig.textColor6,
                                    shadows: const [ColorConfig.textShadow]),
                              ),
                            ],
                          ),
                          const ZSpace(h: 5),
                          if (cubit.fileSelected != null)
                            FileViewWidget(
                                title: cubit.fileSelected!.name,
                                onRemove: () {
                                  cubit.removeFile();
                                }),
                          if (cubit.fileSelected == null)
                            InkWell(
                              onTap: () async {
                                final file = await FileUtils.pickFile();
                                if (file != null) {
                                  if (file.size > 25 * 1024 * 1024) {
                                    if (context.mounted) {
                                      ToastUtils.showBottomToast(context,
                                          "File được chọn không được vượt quá 25MB!");
                                    }
                                  } else {
                                    cubit.selectFile(file);
                                  }
                                }
                              },
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: Radius.circular(
                                    ScaleUtils.scaleSize(12, context)),
                                padding:
                                    EdgeInsets.all(ScaleUtils.scaleSize(6, context)),
                                color: ColorConfig.primary3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(
                                      ScaleUtils.scaleSize(12, context))),
                                  child: Container(
                                    height: ScaleUtils.scaleSize(120, context),
                                    width: double.infinity,
                                    color: const Color(0xFFFFEAEA),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            "assets/images/icons/ic_upload_3.png",
                                            height:
                                                ScaleUtils.scaleSize(29, context)),
                                        const ZSpace(h: 9),
                                        Text(
                                          AppText.textPickFileInHere.text,
                                          style: TextStyle(
                                              fontSize:
                                                  ScaleUtils.scaleSize(14, context),
                                              fontWeight: FontWeight.w400,
                                              color: ColorConfig.textColor),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const ZSpace(h: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ZButton(
                          title: AppText.btnCancel.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorTitle: ColorConfig.primary2,
                          colorBackground: Colors.white,
                          colorBorder: Colors.white,
                          paddingHor: 20,
                          paddingVer: 4,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      const ZSpace(w: 6),
                      ZButton(
                          title: AppText.btnAdd.text,
                          icon: "",
                          sizeTitle: 18,
                          fontWeight: FontWeight.w600,
                          colorTitle: Colors.white,
                          colorBackground: ColorConfig.primary2,
                          colorBorder: ColorConfig.primary2,
                          paddingHor: 20,
                          paddingVer: 4,
                          onPressed: () async {
                            if(cubit.conTitle.text.isEmpty) {
                              ToastUtils.showBottomToast(
                                  context, "Vui lòng nhập tên");
                              return;
                            }
                            if (cubit.optionSelected == 0 &&
                                cubit.conLink.text.isEmpty) {
                              ToastUtils.showBottomToast(
                                  context, "Vui lòng nhập đường dẫn");
                              return;
                            }
                            if (cubit.optionSelected == 1 &&
                                cubit.fileSelected == null) {
                              ToastUtils.showBottomToast(
                                  context, "Vui lòng chọn một file");
                              return;
                            }
                            DialogUtils.showLoadingDialog(context);
                            final model = await cubit.createFile();
                            onUpload(model);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
