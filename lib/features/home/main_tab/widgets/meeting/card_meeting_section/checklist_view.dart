import 'package:whms/models/meeting_section_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class CheckListView extends StatelessWidget {
  const CheckListView({
    super.key,
    required this.section,
    required this.isEdit,
    required this.onUpdate,
  });

  final MeetingSectionModel section;
  final bool isEdit;
  final Function(MeetingSectionModel p1) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(2.5, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                ...section.checklist.asMap().entries.map((e) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: ScaleUtils.scaleSize(9, context)),
                          child: Icon(Icons.circle,
                              size: ScaleUtils.scaleSize(5, context),
                              color: ColorConfig.textColor),
                        ),
                        const ZSpace(w: 4),
                        Expanded(
                          child: TextFieldCustom(
                            controller: TextEditingController(text: e.value),
                            hint: AppText.textTypingNeedToDo.text,
                            isEdit: isEdit,
                            fontWeight: FontWeight.w500,
                            minLines: null,
                            paddingContentHor: 0,
                            paddingContentVer: 2,
                            onEnter: (v) {
                              if (v.isEmpty) {
                                var newCl = [...section.checklist];
                                newCl.remove(e.value);
                                onUpdate(section.copyWith(checklist: newCl));
                              } else {
                                List<String> tmp = [...section.checklist];
                                tmp[e.key] = v;
                                onUpdate(section.copyWith(
                                    checklist: [...tmp]));
                              }
                            },
                            borderColor: Colors.transparent,
                          ),
                        )
                      ],
                    )),
                if (isEdit)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: ScaleUtils.scaleSize(9, context)),
                        child: Icon(Icons.circle,
                            size: ScaleUtils.scaleSize(5, context),
                            color: ColorConfig.textColor),
                      ),
                      const ZSpace(w: 4),
                      Expanded(
                        child: TextFieldCustom(
                          controller: TextEditingController(),
                          hint: AppText.textTypingNeedToDo.text,
                          isEdit: isEdit,
                          fontWeight: FontWeight.w500,
                          minLines: null,
                          paddingContentHor: 0,
                          paddingContentVer: 2,
                          onEnter: (v) {
                            if (v.isEmpty) return;
                            onUpdate(section.copyWith(
                                checklist: [...section.checklist, v]));
                          },
                          borderColor: Colors.transparent,
                        ),
                      )
                    ],
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
