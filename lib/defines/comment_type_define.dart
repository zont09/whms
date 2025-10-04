enum CommentTypeDefine { issue, workingUnit, other}

extension CommentTypeExtension on CommentTypeDefine {
  int get value {
    switch (this) {
      case CommentTypeDefine.issue:
        return 0;
      case CommentTypeDefine.workingUnit:
        return 1;
      case CommentTypeDefine.other:
        return -1;
    }
  }

  String get title {
    switch (this) {
      case CommentTypeDefine.issue:
        return "issue";
      case CommentTypeDefine.workingUnit:
        return "working_unit";
      case CommentTypeDefine.other:
        return "other";
    }
  }

  static CommentTypeDefine getCommentTypeFromValue(int value) {
    switch (value) {
      case 0:
        return CommentTypeDefine.issue;
      case 1:
        return CommentTypeDefine.workingUnit;
      default:
        return CommentTypeDefine.other;
    }
  }
}
