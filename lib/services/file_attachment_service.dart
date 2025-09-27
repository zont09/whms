import 'package:file_picker/file_picker.dart';
import 'package:whms/models/file_attachment_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/repositories/file_attachment_respository.dart';

class FileAttachmentService {
  FileAttachmentService._privateConstructor();

  static FileAttachmentService instance = FileAttachmentService._privateConstructor();

  final FileAttachmentRepository _fileAttachmentRepository = FileAttachmentRepository.instance;

  Future<FileAttachmentModel?> getFileAttachmentById(String id) async {
    final response = await _fileAttachmentRepository.getFileAttachmentById(id);
    if(response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<void> addFileAttachmentNote(FileAttachmentModel model) async {
    await _fileAttachmentRepository.addNewFileAttachmentById(model);
  }

  Future<void> updateFileAttachment(FileAttachmentModel model) async {
    await _fileAttachmentRepository.updateFileAttachment(model);
  }

  Future<String?> uploadFile(PlatformFile file, String id, String title) async {
    final url = await _fileAttachmentRepository.uploadFile(id, title, file);
    return url;
  }
}
