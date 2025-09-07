enum ResponseStatus {
  ok,
  error,
  timeout,
  disconnect,
}

class ErrorModel {
  final String? text;
  final int? errorCode;

  ErrorModel({this.text, this.errorCode});
}

class ResponseModel<T> {
  final ResponseStatus status;
  final T? results;
  final ErrorModel? error;

  ResponseModel({this.status = ResponseStatus.ok, this.results, this.error});
}
