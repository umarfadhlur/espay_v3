// To parse this JSON data, do
//
//     final qrisResponse = qrisResponseFromJson(jsonString);

import 'dart:convert';

QrisResponse qrisResponseFromJson(String str) =>
    QrisResponse.fromJson(json.decode(str));

String qrisResponseToJson(QrisResponse data) => json.encode(data.toJson());

class QrisResponse {
  String responseCode;
  String responseMessage;
  String qrUrl;
  String qrContent;
  AdditionalInfo additionalInfo;

  QrisResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.qrUrl,
    required this.qrContent,
    required this.additionalInfo,
  });

  factory QrisResponse.fromJson(Map<String, dynamic> json) => QrisResponse(
        responseCode: json["responseCode"],
        responseMessage: json["responseMessage"],
        qrUrl: json["qrUrl"],
        qrContent: json["qrContent"],
        additionalInfo: AdditionalInfo.fromJson(json["additionalInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "responseMessage": responseMessage,
        "qrUrl": qrUrl,
        "qrContent": qrContent,
        "additionalInfo": additionalInfo.toJson(),
      };
}

class AdditionalInfo {
  String referenceNo;
  String partnerReferenceNo;
  String merchantName;
  String amount;

  AdditionalInfo({
    required this.referenceNo,
    required this.partnerReferenceNo,
    required this.merchantName,
    required this.amount,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
        referenceNo: json["referenceNo"],
        partnerReferenceNo: json["partnerReferenceNo"],
        merchantName: json["merchantName"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "referenceNo": referenceNo,
        "partnerReferenceNo": partnerReferenceNo,
        "merchantName": merchantName,
        "amount": amount,
      };
}
