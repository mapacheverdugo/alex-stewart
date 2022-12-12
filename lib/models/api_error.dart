class ApiError {
  dynamic? statusCode;
  String? error;
  String? message;

  ApiError({this.statusCode, this.error, this.message});

  factory ApiError.fromJson(dynamic json) {
    return ApiError(
      statusCode: json["statusCode"],
      error: json["error"],
      message: json["message"],
    );
  }
}
