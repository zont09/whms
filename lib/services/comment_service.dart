import 'package:file_picker/file_picker.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/repositories/comment_repository.dart';

class CommentService {
  CommentService._privateConstructor();

  static CommentService instance = CommentService._privateConstructor();

  final CommentRepository _commentRepository = CommentRepository.instance;

  // Future<List<CommentModel>> getAllComments() async {
  //   final response = await _commentRepository.getAllComments();
  //   if(response.status == ResponseStatus.ok && response.results != null) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<CommentModel?> getCommentById(String id) async {
    final response = await _commentRepository.getCommentById(id);
    if(response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<List<CommentModel>> getCommentByType(String type) async {
    final response = await _commentRepository.getCommentByType(type);
    if(response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<List<CommentModel>> getCommentByPosition(String position) async {
    final response = await _commentRepository.getCommentByPosition(position);
    if(response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<List<CommentModel>> getCommentByParent(String parent) async {
    final response = await _commentRepository.getCommentByParent(parent);
    if(response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return [];
  }

  Future<void> addNewComment(CommentModel model) async {
    await _commentRepository.addNewComment(model);
  }

  Future<void> updateComment(CommentModel model) async {
    await _commentRepository.updateComment(model);
  }

  Future<String?> uploadFile(PlatformFile file, String type, String idComment) async {
    String? url = await _commentRepository.uploadFile(file, type, idComment);
    return url;
  }
}
