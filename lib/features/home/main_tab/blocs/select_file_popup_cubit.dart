import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/services/file_attachment_service.dart';
import 'package:whms/untils/file_utils.dart';

class SelectFilePopupCubit extends Cubit<int> {
  SelectFilePopupCubit() : super(0);

  final FileAttachmentService _fileAttachmentService =
      FileAttachmentService.instance;

  final TextEditingController conTitle = TextEditingController();
  final TextEditingController conLink = TextEditingController();
  PlatformFile? fileSelected;

  int optionSelected = 0; // 0: link - 1: file

  selectFile(PlatformFile file) {
    fileSelected = file;
    EMIT();
  }

  createFile() async {
    if (optionSelected == 0) {
      final model = FileAttachmentModel(
        id: FirebaseFirestore.instance
            .collection("file_attachment")
            .doc()
            .id,
        title: conTitle.text,
        type: "link",
        source: conLink.text,
        createdAt: DateTime.now(),
      );
      _fileAttachmentService.addFileAttachmentNote(model);
      return model;
    } else {
      String idF = FirebaseFirestore.instance
          .collection("file_attachment")
          .doc()
          .id;
      final url = await _fileAttachmentService.uploadFile(
          fileSelected!, idF, conTitle.text);
      String type = "other";
      if (FileUtils.isImage(fileSelected!)) {
        type = "image";
      } else if (FileUtils.isVideo(fileSelected!)) {
        type = "video";
      } else if (FileUtils.isAudio(fileSelected!)) {
        type = "audio";
      } else if (FileUtils.isDocument(fileSelected!)) {
        type = "doc";
      }
      final model = FileAttachmentModel(
        id: idF,
        title: conTitle.text,
        type: type,
        source: url ?? "",
        createdAt: DateTime.now(),
      );
      _fileAttachmentService.addFileAttachmentNote(model);
      return model;
    }
  }

  removeFile() {
    fileSelected = null;
    EMIT();
  }

  changeOption(int v) {
    optionSelected = v;
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
