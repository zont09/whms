import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/services/comment_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';

class CommentCubit extends Cubit<int> {
  CommentCubit(BuildContext ctx) : super(0) {
    context = ctx;
  }

  late BuildContext context;

  final CommentService _commentService = CommentService.instance;

  final TextEditingController content = TextEditingController();
  List<PlatformFile> listImages = [];
  List<PlatformFile> listFiles = [];
  List<PlatformFile> listVideos = [];
  String position = "";
  String type = "";
  String parent = "";
  int sendCmt = 0;

  bool isEmptyContent = true;

  final double maxImages = 10 * 1024 * 1024;
  final double maxVideos = 50 * 1024 * 1024;
  final double maxFiles = 50 * 1024 * 1024;

  double sizeImages = 0;
  double sizeVideos = 0;
  double sizeFiles = 0;

  String errorMaxCapacity = "";

  initData(String t, String p, String par) {
    position = p;
    type = t;
    parent = par;
    EMIT();
  }

  selectImages(List<PlatformFile> files) {
    errorMaxCapacity = "";
    for (var file in files) {
      if (file.size + sizeImages <= maxImages) {
        listImages.add(file);
        sizeImages += file.size;
      } else {
        errorMaxCapacity += "${file.name}\n";
      }
    }
    if (errorMaxCapacity.isNotEmpty) {
      DialogUtils.showResultDialog(context, AppText.titleCapacityExceeded.text,
          "Tổng dung lượng các ảnh không được vượt quá 10MB. Các ảnh dưới đây sẽ không được chọn:\n$errorMaxCapacity");
    }
    EMIT();
  }

  removeImages(PlatformFile file) {
    listImages.remove(file);
    sizeImages -= file.size;
    EMIT();
  }

  selectVideos(List<PlatformFile> files) {
    errorMaxCapacity = "";
    for (var file in files) {
      if (file.size + sizeVideos <= maxVideos) {
        listVideos.add(file);
        sizeVideos += file.size;
      } else {
        errorMaxCapacity += "${file.name}\n";
      }
    }
    if (errorMaxCapacity.isNotEmpty) {
      DialogUtils.showResultDialog(context, AppText.titleCapacityExceeded.text,
          "Tổng dung lượng các video không được vượt quá 50MB. Các video dưới đây sẽ không được chọn:\n$errorMaxCapacity");
    }
    EMIT();
  }

  removeVideos(PlatformFile file) {
    listVideos.remove(file);
    sizeVideos -= file.size;
    EMIT();
  }

  selectFiles(List<PlatformFile> files) {
    errorMaxCapacity = "";
    for (var file in files) {
      if (file.size + sizeFiles <= maxFiles) {
        listFiles.add(file);
        sizeFiles += file.size;
      } else {
        errorMaxCapacity += "${file.name}\n";
      }
    }
    if (errorMaxCapacity.isNotEmpty) {
      DialogUtils.showResultDialog(context, AppText.titleCapacityExceeded.text,
          "Tổng dung lượng các tệp không được vượt quá 50MB. Các tệp dưới đây sẽ không được chọn:\n$errorMaxCapacity");
    }
    EMIT();
  }

  removeFiles(PlatformFile file) {
    listFiles.remove(file);
    sizeFiles -= file.size;
    EMIT();
  }

  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Chỉ cho phép chọn ảnh
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        selectImages(files); // Gửi file qua Cubit
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    EMIT();
  }

  Future<void> pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video, // Chỉ cho phép chọn video
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        selectVideos(files); // Gửi file qua Cubit
      }
    } catch (e) {
      print("Error picking video: $e");
    }
    EMIT();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Cho phép chọn mọi loại file
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        selectFiles(files); // Gửi danh sách file qua Cubit
      }
    } catch (e) {
      print("Error picking file: $e");
    }
    EMIT();
  }

  Future<CommentModel> sendComment() async {
    List<String> linkImages = [];
    List<String> linkVideos = [];
    List<String> linkFiles = [];
    DialogUtils.showLoadingDialog(context);
    for (var item in listImages) {
      final link = await _commentService.uploadFile(item, type, position);
      if (link != null) {
        linkImages.add(link);
      }
    }
    for (var item in listVideos) {
      final link = await _commentService.uploadFile(item, type, position);
      if (link != null) {
        linkVideos.add(link);
      }
    }
    for (var item in listFiles) {
      final link = await _commentService.uploadFile(item, type, position);
      if (link != null) {
        linkFiles.add(link);
      }
    }
    final newCmt = CommentModel(
        id: FirebaseFirestore.instance.collection('whms_pls_comment').doc().id,
        position: position,
        type: type,
        parent: parent,
        content: content.text,
        date: Timestamp.now(),
        edited: false,
        owner: ConfigsCubit.fromContext(context).user.id,
        videos: linkVideos,
        images: linkImages,
        attachments: linkFiles,
        enable: true,
        createAt: Timestamp.now(),
        updateAt: Timestamp.now());
    await _commentService.addNewComment(newCmt);
    content.text = "";
    listImages.clear();
    listVideos.clear();
    listFiles.clear();
    sendCmt++;
    if(context.mounted) {
      Navigator.of(context).pop();
    }
    checkEmptyContent();
    EMIT();
    return newCmt;
  }

  checkEmptyContent() {
    if(content.text.isNotEmpty && isEmptyContent) {
      isEmptyContent = false;
      EMIT();
    }
    if(!isEmptyContent && (content.text.isEmpty || content.text == "[{\"insert\":\"\\n\"}]" || content.text == "[{\"insert\":\"\"}]")) {
      isEmptyContent = true;
      EMIT();
    }
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
