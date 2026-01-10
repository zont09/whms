import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';

class ProductHandoverCubit extends Cubit<int> {
  ProductHandoverCubit(this.work, this.onUpdate, this.context) : super(0);

  final WorkingService _workingService = WorkingService.instance;
  final CacheUtils _cache = CacheUtils.instance;

  final WorkingUnitModel work;
  final Function(WorkingUnitModel, WorkingUnitModel) onUpdate;
  final BuildContext context;

  String handoverDescription = '';
  List<PlatformFile> listImages = [];
  List<PlatformFile> listVideos = [];
  List<PlatformFile> listAudios = [];
  List<PlatformFile> listDocs = [];
  List<PlatformFile> listOthers = [];

  Map<PlatformFile, String> mapFileUrl = {};

  int loading = 0;

  final double maxCapacity = 50 * 1024 * 1024;
  double sizeFiles = 0;

  int get sumLen =>
      listImages.length +
          listVideos.length +
          listAudios.length +
          listDocs.length +
          listOthers.length;

  void initData() async {
    // Load handover description
    handoverDescription = work.handoverDescription ?? '';

    // Load handover files
    if (work.handoverFiles.isNotEmpty) {
      loading++;
      EMIT();

      listImages.clear();
      listVideos.clear();
      listDocs.clear();
      listOthers.clear();
      listAudios.clear();

      for (String fileUrl in work.handoverFiles) {
        try {
          final file = await _cache.getFileGB(fileUrl);
          if (file != null) {
            mapFileUrl[file] = fileUrl;
            _categorizeFile(file);
            sizeFiles += file.size;
          }
        } catch (e) {
          print('Error loading handover file: $e');
        }
      }

      loading--;
      EMIT();
    }
  }

  void _categorizeFile(PlatformFile file) {
    if (FileUtils.isImage(file)) {
      listImages.add(file);
    } else if (FileUtils.isVideo(file)) {
      listVideos.add(file);
    } else if (FileUtils.isAudio(file)) {
      listAudios.add(file);
    } else if (FileUtils.isDocument(file)) {
      listDocs.add(file);
    } else {
      listOthers.add(file);
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files;
        await uploadFile(files);
      }
    } catch (e) {
      print("Error picking handover file: $e");
    }
    EMIT();
  }

  uploadFile(List<PlatformFile> files) async {
    loading++;
    EMIT();

    List<String> linkFiles = [...work.handoverFiles];
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
        mapFileUrl[file] = url;
        _categorizeFile(file);
      }
    }

    if (errorMaxCapacity.isNotEmpty && context.mounted) {
      await DialogUtils.showResultDialog(
          context,
          AppText.titleCapacityExceeded.text,
          "Tổng dung lượng các tệp không được vượt quá 50MB. Các tệp dưới đây sẽ không được chọn:\n$errorMaxCapacity");
    }

    WorkingUnitModel updatedWork = work.copyWith(handoverFiles: linkFiles);
    onUpdate(updatedWork, work);

    if (context.mounted) {
      ConfigsCubit.fromContext(context).updateWorkingUnit(updatedWork, work);
    }

    loading--;
    EMIT();
  }

  void removeFile(PlatformFile file, String type) {
    switch (type) {
      case "image":
        listImages.remove(file);
        break;
      case "video":
        listVideos.remove(file);
        break;
      case "audio":
        listAudios.remove(file);
        break;
      case "document":
        listDocs.remove(file);
        break;
      case "other":
        listOthers.remove(file);
        break;
    }

    final url = mapFileUrl[file];
    List<String> tmpHandoverFiles = work.handoverFiles;

    if (url != null) {
      tmpHandoverFiles.remove(url);
      sizeFiles -= file.size;
    }

    WorkingUnitModel updatedWork = work.copyWith(handoverFiles: tmpHandoverFiles);

    if (context.mounted) {
      ConfigsCubit.fromContext(context).updateWorkingUnit(updatedWork, work);
    }

    onUpdate(updatedWork, work);
    EMIT();
  }

  void updateHandoverDescription(String description) {
    handoverDescription = description;

    WorkingUnitModel updatedWork = work.copyWith(
      handoverDescription: description,
    );

    if (context.mounted) {
      ConfigsCubit.fromContext(context).updateWorkingUnit(updatedWork, work);
    }

    onUpdate(updatedWork, work);
    EMIT();
  }

  void EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}