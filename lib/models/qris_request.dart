// To parse this JSON data, do
//
//     final qrisRequest = qrisRequestFromJson(jsonString);

import 'dart:convert';

QrisRequest qrisRequestFromJson(String str) =>
    QrisRequest.fromJson(json.decode(str));

String qrisRequestToJson(QrisRequest data) => json.encode(data.toJson());

class QrisRequest {
  String partnerReferenceNo;
  String merchantId;
  Amount amount;
  AdditionalInfo additionalInfo;
  DateTime validityPeriod;

  QrisRequest({
    required this.partnerReferenceNo,
    required this.merchantId,
    required this.amount,
    required this.additionalInfo,
    required this.validityPeriod,
  });

  factory QrisRequest.fromJson(Map<String, dynamic> json) => QrisRequest(
        partnerReferenceNo: json["partnerReferenceNo"],
        merchantId: json["merchantId"],
        amount: Amount.fromJson(json["amount"]),
        additionalInfo: AdditionalInfo.fromJson(json["additionalInfo"]),
        validityPeriod: DateTime.parse(json["validityPeriod"]),
      );

  Map<String, dynamic> toJson() => {
        "partnerReferenceNo": partnerReferenceNo,
        "merchantId": merchantId,
        "amount": amount.toJson(),
        "additionalInfo": additionalInfo.toJson(),
        "validityPeriod": validityPeriod.toIso8601String(),
      };
}

class AdditionalInfo {
  String productCode;

  AdditionalInfo({
    required this.productCode,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
        productCode: json["productCode"],
      );

  Map<String, dynamic> toJson() => {
        "productCode": productCode,
      };
}

class Amount {
  String value;
  String currency;

  Amount({
    required this.value,
    required this.currency,
  });

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
        value: json["value"],
        currency: json["currency"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "currency": currency,
      };
}
