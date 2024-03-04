// To parse this JSON data, do
//
//     final waRequest = waRequestFromJson(jsonString);

import 'dart:convert';

WaRequest waRequestFromJson(String str) => WaRequest.fromJson(json.decode(str));

String waRequestToJson(WaRequest data) => json.encode(data.toJson());

class WaRequest {
  String token;
  String to;
  Header header;
  List<String> param;

  WaRequest({
    required this.token,
    required this.to,
    required this.header,
    required this.param,
  });

  factory WaRequest.fromJson(Map<String, dynamic> json) => WaRequest(
        token: json["token"],
        to: json["to"],
        header: Header.fromJson(json["header"]),
        param: List<String>.from(json["param"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "to": to,
        "header": header.toJson(),
        "param": List<dynamic>.from(param.map((x) => x)),
      };
}

class Header {
  String type;
  String data;

  Header({
    required this.type,
    required this.data,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        type: json["type"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data,
      };
}
