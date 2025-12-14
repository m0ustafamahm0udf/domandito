import 'dart:convert';

ErrorModel errorModelFromJson(String str) => ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
  final bool error;
  final String message;

  ErrorModel({
    required this.error,
    required this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        error: json["error"] ?? false,
        message: json["message"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
      };
}
