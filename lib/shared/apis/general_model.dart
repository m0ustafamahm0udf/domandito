import 'dart:convert';

GeneralModel generalModelFromJson(String str) =>
    GeneralModel.fromJson(json.decode(str));

String generalModelToJson(GeneralModel data) => json.encode(data.toJson());

class GeneralModel {
  GeneralModel({
    required this.status,
    required this.code,
    required this.msg,
  });

  final bool status;
  final int code;
  final String msg;

  factory GeneralModel.fromJson(Map<String, dynamic> json) => GeneralModel(
        status: json["status"],
        code: json["code"],
        msg: json["msg"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "msg": msg,
      };
}
