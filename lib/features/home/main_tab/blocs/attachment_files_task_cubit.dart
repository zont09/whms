import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';

class AttachmentFilesTaskCubit extends Cubit<int> {
  AttachmentFilesTaskCubit(WorkingUnitModel w,
      Function(WorkingUnitModel, WorkingUnitModel) f, BuildContext ctx)
      : super(0) {
    work = w;
    context = ctx;
    onUpdate = f;
  }

  final WorkingService _workingService = WorkingService.instance;
  late Function(WorkingUnitModel, WorkingUnitModel) onUpdate;

  final CacheUtils _cache = CacheUtils.instance;

  late WorkingUnitModel work;
  late BuildContext context;
  List<PlatformFile> listImages = [];
  List<PlatformFile> listVideos = [];
  List<PlatformFile> listDocs = [];
  List<PlatformFile> listOthers = [];
  List<PlatformFile> listAudios = [];

  Map<PlatformFile, String> mapFileUrl = {};

  int loading = 0;
  int sumLen = 0;

  final double maxCapacity = 50 * 1024 * 1024;
  double sizeFiles = 0;

  initData() async {
    loading++;
    listImages.clear();
    listVideos.clear();
    listDocs.clear();
    listOthers.clear();
    for (var item in work.attachments) {
      final file = await _cache.getFileGB(item);
      if (file != null) {
        mapFileUrl[file] = item;
        if (FileUtils.isImage(file)) {
          listImages.add(file);
        } else if (FileUtils.isVideo(file)) {
          listVideos.add(file);
        } else if (FileUtils.isDocument(file)) {
          listDocs.add(file);
        } else if (FileUtils.isAudio(file)) {
          listAudios.add(file);
        } else {
          listOthers.add(file);
        }
        sizeFiles += file.size;
      }
    }
    sumLen = listImages.length +
        listVideos.length +
        listDocs.length +
        listOthers.length;
    loading--;
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

        await uploadFile(files);
      }
    } catch (e) {
      print("Error picking file: $e");
    }
    EMIT();
  }

  uploadFile(
    List<PlatformFile> files,
  ) async {
    loading++;
    EMIT();
    List<String> linkFiles = [...work.attachments];
    String errorMaxCapacity = "";
    for (var file in files) {
      if (file.size + sizeFiles > maxCapacity) {
        errorMaxCapacity += "${file.name}\n";
        continue;
      }
      sizeFiles += file.size;
      final url = await _workingService.uploadFile(file, work.id);
      if (url != null) {
        linkFiles.add(url);
        _cache.setFileGB(url, file);
        if (FileUtils.isImage(file)) {
          listImages.add(file);
        } else if (FileUtils.isVideo(file)) {
          listVideos.add(file);
        } else if (FileUtils.isDocument(file)) {
          listDocs.add(file);
        } else if (FileUtils.isAudio(file)) {
          listAudios.add(file);
        } else {
          listOthers.add(file);
        }
      }
    }
    if (errorMaxCapacity.isNotEmpty && context.mounted) {
      await DialogUtils.showResultDialog(
          context,
          AppText.titleCapacityExceeded.text,
          "Tổng dung lượng các tệp không được vượt quá 50MB. Các tệp dưới đây sẽ không được chọn:\n$errorMaxCapacity");
    }
    sumLen = listImages.length +
        listVideos.length +
        listDocs.length +
        listOthers.length;
    onUpdate(work.copyWith(attachments: linkFiles), work);
    if (context.mounted) {
      ConfigsCubit.fromContext(context)
          .updateWorkingUnit(work.copyWith(attachments: linkFiles), work);
      // _workingService.updateWorkingUnitField(
      //     work.copyWith(attachments: linkFiles),
      //     work,
      //     ConfigsCubit.fromContext(context).user.id);
    }
    loading--;
    work = work.copyWith(attachments: linkFiles);
    EMIT();
  }

  removeFile(PlatformFile file, String type) {
    if (type == "image") {
      listImages.remove(file);
    } else if (type == "video") {
      listVideos.remove(file);
    } else if (type == "audio") {
      listAudios.remove(file);
    }
    if (type == "document") {
      listDocs.remove(file);
    } else {
      listOthers.remove(file);
    }
    final url = mapFileUrl[file];
    List<String> tmpAttach = work.attachments;
    if (url != null) {
      tmpAttach.remove(url);
      sumLen--;
    }
    ConfigsCubit.fromContext(context)
        .updateWorkingUnit(work.copyWith(attachments: tmpAttach),
      work,);
    // _workingService.updateWorkingUnitField(
    //     work.copyWith(attachments: tmpAttach),
    //     work,
    //     ConfigsCubit.fromContext(context).user.id);
    onUpdate(work.copyWith(attachments: tmpAttach), work);
    work = work.copyWith(attachments: tmpAttach);
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
