class ErrorModel {
  final int status;
  final String errorMessage;

  ErrorModel({required this.status, required this.errorMessage});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      status: json['status'] ?? json['code'] ?? json['statusCode'] ?? 0,
      errorMessage: json['Message'] ??
          json['message'] ??
          json['errorMessage'] ??
          json['error'] ??
          'An error occurred',
    );
  }
}
