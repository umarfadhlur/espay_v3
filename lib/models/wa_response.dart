// To parse this JSON data, do
//
//     final waResponse = waResponseFromJson(jsonString);

import 'dart:convert';

WaResponse waResponseFromJson(String str) =>
    WaResponse.fromJson(json.decode(str));

String waResponseToJson(WaResponse data) => json.encode(data.toJson());

class WaResponse {
  String responseCode;
  String version;
  List<Datum> data;
  String message;

  WaResponse({
    required this.responseCode,
    required this.version,
    required this.data,
    required this.message,
  });

  factory WaResponse.fromJson(Map<String, dynamic> json) => WaResponse(
        responseCode: json["responseCode"],
        version: json["version"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "version": version,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class Datum {
  String to;
  String msgId;
  String status;
  dynamic errorStatus;
  dynamic errorMsg;
  int trxid;

  Datum({
    required this.to,
    required this.msgId,
    required this.status,
    required this.errorStatus,
    required this.errorMsg,
    required this.trxid,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        to: json["to"],
        msgId: json["msgId"],
        status: json["status"],
        errorStatus: json["error_status"],
        errorMsg: json["error_msg"],
        trxid: json["trxid"],
      );

  Map<String, dynamic> toJson() => {
        "to": to,
        "msgId": msgId,
        "status": status,
        "error_status": errorStatus,
        "error_msg": errorMsg,
        "trxid": trxid,
      };
}
