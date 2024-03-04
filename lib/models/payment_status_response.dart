// To parse this JSON data, do
//
//     final paymentStatusResponse = paymentStatusResponseFromJson(jsonString);

import 'dart:convert';

PaymentStatusResponse paymentStatusResponseFromJson(String str) => PaymentStatusResponse.fromJson(json.decode(str));

String paymentStatusResponseToJson(PaymentStatusResponse data) => json.encode(data.toJson());

class PaymentStatusResponse {
    String responseCode;
    String responseMessage;
    VirtualAccountData virtualAccountData;
    AdditionalInfo additionalInfo;

    PaymentStatusResponse({
        required this.responseCode,
        required this.responseMessage,
        required this.virtualAccountData,
        required this.additionalInfo,
    });

    factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) => PaymentStatusResponse(
        responseCode: json["responseCode"],
        responseMessage: json["responseMessage"],
        virtualAccountData: VirtualAccountData.fromJson(json["virtualAccountData"]),
        additionalInfo: AdditionalInfo.fromJson(json["additionalInfo"]),
    );

    Map<String, dynamic> toJson() => {
        "responseCode": responseCode,
        "responseMessage": responseMessage,
        "virtualAccountData": virtualAccountData.toJson(),
        "additionalInfo": additionalInfo.toJson(),
    };
}

class AdditionalInfo {
    String trxId;
    DateTime expiredDatetime;
    String memberCode;
    String debitFrom;
    String debitFromName;
    String debitFromBank;
    String creditTo;
    String creditToName;
    String creditToBank;
    String productCode;
    String productValue;
    dynamic rrn;
    dynamic approvalCode;
    String token;
    dynamic userId;

    AdditionalInfo({
        required this.trxId,
        required this.expiredDatetime,
        required this.memberCode,
        required this.debitFrom,
        required this.debitFromName,
        required this.debitFromBank,
        required this.creditTo,
        required this.creditToName,
        required this.creditToBank,
        required this.productCode,
        required this.productValue,
        required this.rrn,
        required this.approvalCode,
        required this.token,
        required this.userId,
    });

    factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
        trxId: json["trxId"],
        expiredDatetime: DateTime.parse(json["expiredDatetime"]),
        memberCode: json["memberCode"],
        debitFrom: json["debitFrom"],
        debitFromName: json["DebitFromName"],
        debitFromBank: json["DebitFromBank"],
        creditTo: json["creditTo"],
        creditToName: json["creditToName"],
        creditToBank: json["creditToBank"],
        productCode: json["productCode"],
        productValue: json["productValue"],
        rrn: json["rrn"],
        approvalCode: json["approvalCode"],
        token: json["token"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "trxId": trxId,
        "expiredDatetime": expiredDatetime.toIso8601String(),
        "memberCode": memberCode,
        "debitFrom": debitFrom,
        "DebitFromName": debitFromName,
        "DebitFromBank": debitFromBank,
        "creditTo": creditTo,
        "creditToName": creditToName,
        "creditToBank": creditToBank,
        "productCode": productCode,
        "productValue": productValue,
        "rrn": rrn,
        "approvalCode": approvalCode,
        "token": token,
        "userId": userId,
    };
}

class VirtualAccountData {
    String partnerServiceId;
    String customerNo;
    String paymentFlagStatus;
    PaymentFlagReason paymentFlagReason;
    String virtualAccountNo;
    String inquiryRequestId;
    Amount paidAmount;
    Amount totalAmount;
    DateTime trxDateTime;
    DateTime transactionDate;
    Amount billAmount;
    List<BillDetail> billDetails;

    VirtualAccountData({
        required this.partnerServiceId,
        required this.customerNo,
        required this.paymentFlagStatus,
        required this.paymentFlagReason,
        required this.virtualAccountNo,
        required this.inquiryRequestId,
        required this.paidAmount,
        required this.totalAmount,
        required this.trxDateTime,
        required this.transactionDate,
        required this.billAmount,
        required this.billDetails,
    });

    factory VirtualAccountData.fromJson(Map<String, dynamic> json) => VirtualAccountData(
        partnerServiceId: json["partnerServiceId"],
        customerNo: json["customerNo"],
        paymentFlagStatus: json["paymentFlagStatus"],
        paymentFlagReason: PaymentFlagReason.fromJson(json["paymentFlagReason"]),
        virtualAccountNo: json["virtualAccountNo"],
        inquiryRequestId: json["inquiryRequestId"],
        paidAmount: Amount.fromJson(json["paidAmount"]),
        totalAmount: Amount.fromJson(json["totalAmount"]),
        trxDateTime: DateTime.parse(json["trxDateTime"]),
        transactionDate: DateTime.parse(json["transactionDate"]),
        billAmount: Amount.fromJson(json["billAmount"]),
        billDetails: List<BillDetail>.from(json["billDetails"].map((x) => BillDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "partnerServiceId": partnerServiceId,
        "customerNo": customerNo,
        "paymentFlagStatus": paymentFlagStatus,
        "paymentFlagReason": paymentFlagReason.toJson(),
        "virtualAccountNo": virtualAccountNo,
        "inquiryRequestId": inquiryRequestId,
        "paidAmount": paidAmount.toJson(),
        "totalAmount": totalAmount.toJson(),
        "trxDateTime": trxDateTime.toIso8601String(),
        "transactionDate": transactionDate.toIso8601String(),
        "billAmount": billAmount.toJson(),
        "billDetails": List<dynamic>.from(billDetails.map((x) => x.toJson())),
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

class BillDetail {
    PaymentFlagReason billDescription;

    BillDetail({
        required this.billDescription,
    });

    factory BillDetail.fromJson(Map<String, dynamic> json) => BillDetail(
        billDescription: PaymentFlagReason.fromJson(json["billDescription"]),
    );

    Map<String, dynamic> toJson() => {
        "billDescription": billDescription.toJson(),
    };
}

class PaymentFlagReason {
    String english;
    String indonesia;

    PaymentFlagReason({
        required this.english,
        required this.indonesia,
    });

    factory PaymentFlagReason.fromJson(Map<String, dynamic> json) => PaymentFlagReason(
        english: json["english"],
        indonesia: json["indonesia"],
    );

    Map<String, dynamic> toJson() => {
        "english": english,
        "indonesia": indonesia,
    };
}
