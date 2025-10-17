import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/empty_document_view.dart';

class ListDocumentView extends StatelessWidget {
  const ListDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: ScaleUtils.scaleSize(10, context),
            right: ScaleUtils.scaleSize(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddButton(AppText.titleDocumentAndInstruction.text, onTap: () {}),
            Align(
              alignment: Alignment.center,
              child: EmptyDocumentView(
                  title: AppText.titleEmptyDocument.text,
                  txt: AppText.txtEmptyDocument.text),
            ),
            SizedBox(height: ScaleUtils.scaleSize(20, context)),
            AddButton(AppText.titleAttachmentFile.text, onTap: () {}),
            Align(
                alignment: Alignment.center,
                child: EmptyDocumentView(
                    title: AppText.titleEmptyAttachment.text,
                    txt: AppText.txtEmptyAttachment.text))
          ],
        ),
      ),
    );
  }
}
