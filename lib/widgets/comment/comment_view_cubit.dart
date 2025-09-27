import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/services/comment_service.dart';
import 'package:whms/untils/cache_utils.dart';

class CommentViewCubit extends Cubit<int> {
  CommentViewCubit() : super(0);

  CommentModel? comment;
  List<PlatformFile> images = [];
  List<PlatformFile> videos = [];
  List<PlatformFile> files = [];

  bool isEdit = false;
  String commentEdited = "";

  initData(CommentModel cmt) async {
    comment = cmt;
    images.clear();
    final CacheUtils cache = CacheUtils.instance;
    for (var e in cmt.images) {
      final file = await cache.getFileGB(e);
      if (file != null) {
        images.add(file);
      }
    }
    EMIT();
    videos.clear();
    for (var e in cmt.videos) {
      final file = await cache.getFileGB(e);
      if (file != null) {
        videos.add(file);
      }
    }
    EMIT();
    files.clear();
    for (var e in cmt.attachments) {
      final file = await cache.getFileGB(e);
      if (file != null) {
        files.add(file);
      }
    }
    EMIT();
  }

  changeEdit(bool v) {
    if(v) {
      commentEdited = comment!.content;
      isEdit = v;
    }
    EMIT();
  }

  edit() {
    comment = comment!.copyWith(content: commentEdited, updateAt: Timestamp.now());
    CommentService.instance.updateComment(comment!);
    isEdit = false;
    EMIT();
  }

  cancelEdit() {
    isEdit = false;
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}
