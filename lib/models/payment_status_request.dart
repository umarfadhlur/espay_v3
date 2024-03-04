// To parse this JSON data, do
//
//     final paymentStatusRequest = paymentStatusRequestFromJson(jsonString);

import 'dart:convert';

PaymentStatusRequest paymentStatusRequestFromJson(String str) => PaymentStatusRequest.fromJson(json.decode(str));

String paymentStatusRequestToJson(PaymentStatusRequest data) => json.encode(data.toJson());

class PaymentStatusRequest {
    String partnerServiceId;
    String customerNo;
    String virtualAccountNo;
    String inquiryRequestId;
    String paymentRequestId;

    PaymentStatusRequest({
        required this.partnerServiceId,
        required this.customerNo,
        required this.virtualAccountNo,
        required this.inquiryRequestId,
        required this.paymentRequestId,
    });

    factory PaymentStatusRequest.fromJson(Map<String, dynamic> json) => PaymentStatusRequest(
        partnerServiceId: json["partnerServiceId"],
        customerNo: json["customerNo"],
        virtualAccountNo: json["virtualAccountNo"],
        inquiryRequestId: json["inquiryRequestId"],
        paymentRequestId: json["paymentRequestId"],
    );

    Map<String, dynamic> toJson() => {
        "partnerServiceId": partnerServiceId,
        "customerNo": customerNo,
        "virtualAccountNo": virtualAccountNo,
        "inquiryRequestId": inquiryRequestId,
        "paymentRequestId": paymentRequestId,
    };
}
