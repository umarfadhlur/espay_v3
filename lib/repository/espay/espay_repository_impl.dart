import 'dart:convert';

import 'package:espay_v3/models/payment_status_response.dart';
import 'package:http/http.dart' as http;

import '../../models/wa_response.dart';
import '../../utils/generate_random_string.dart';
import '../../utils/rsa_key.dart';

import '../../models/qris_response.dart';

abstract class EspayRepository {
  Future<QrisResponse> getQris(int value);
  Future<PaymentStatusResponse> getPaymentStatus();
  Future<WaResponse> getInvoice();
}

class EspayRepositoryImpl implements EspayRepository {
  final String orderNumber = generateOrderNumber();
  @override
  Future<QrisResponse> getQris(int value) async {
    print(orderNumber);
    final timestamp = DateTime.now().toUtc().toIso8601String();
    String dateString = timestamp.substring(0, timestamp.indexOf('T'));
    print(dateString);
    try {
      Map<String, dynamic> requestBody = {
        "partnerReferenceNo": orderNumber,
        "merchantId": "SGWROYALABADISEJ",
        "amount": {"value": "$value.00", "currency": "IDR"},
        "additionalInfo": {"productCode": "QRIS"},
        "validityPeriod": "${dateString}T23:59:59+07:00"
      };
      print(jsonEncode(requestBody));
      final hexEncode = hexEncodeSHA256(jsonEncode(requestBody)).toLowerCase();
      final stringToSign =
          "POST:/api/v1.0/qr/qr-mpm-generate:$hexEncode:$timestamp"; // Adjust path if needed
      final signature = generateSignature(
          stringToSign, privateKey); // Assuming you have this function

      final headers = {
        'Content-Type': 'application/json',
        'X-TIMESTAMP': timestamp,
        'X-SIGNATURE': signature,
        'X-EXTERNAL-ID': orderNumber,
        'X-PARTNER-ID': 'SGWROYALABADISEJ',
        'CHANNEL-ID': 'ESPAY',
      };

      print(jsonEncode(headers));
      final pushDatabase = await http.post(
        Uri.parse(
            'https://espayapi.000webhostapp.com/api/postData.php'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print(jsonDecode(pushDatabase.body));

      final response = await http.post(
        Uri.parse(
            'https://sandbox-api.espay.id/api/v1.0/qr/qr-mpm-generate'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        final qrisData = QrisResponse.fromJson(data);

        String getTrxIdFromUrl(String url) {
          Uri uri = Uri.parse(url);
          String trxId = uri.queryParameters['trx_id'] ?? '';
          return trxId;
        }

        // Mendapatkan nilai trx_id dari qrUrl
        String qrUrl = qrisData.qrUrl;
        String trxId = getTrxIdFromUrl(qrUrl);

        print('Nilai trx_id dari qrUrl: $trxId');

        Map<String, dynamic> requestPutBody = {
          "partnerReferenceNo": orderNumber,
          "amountValue": value,
          "trxId": trxId,
        };

        final putDatabase = await http.post(
          Uri.parse(
              'https://espayapi.000webhostapp.com/api/putData.php'), // Adjust URL if needed
          headers: headers,
          body: jsonEncode(requestPutBody),
        );

        print(jsonDecode(putDatabase.body));

        return qrisData;
      }
    } catch (error) {
      throw Exception('Error');
    }
    throw Exception;
  }

  @override
  Future<PaymentStatusResponse> getPaymentStatus() async {
    print(orderNumber);
    final String randomNumericString = generateRandomNumericString();
    print('object $randomNumericString');
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      Map<String, dynamic> requestBody = {
        "partnerServiceId": " ESPAY",
        "customerNo": "SGWROYALABADISEJ",
        "virtualAccountNo": orderNumber,
        "inquiryRequestId": "abcdef-123456-abcdef",
        "paymentRequestId": "abcdef-123456-abcdef",
      };
      print(jsonEncode(requestBody));
      final hexEncode = hexEncodeSHA256(jsonEncode(requestBody)).toLowerCase();
      print(hexEncode);
      final stringToSign =
          "POST:/apimerchant/v1.0/transfer-va/status:$hexEncode:$timestamp"; // Adjust path if needed
      print(stringToSign);
      final signature = generateSignature(
          stringToSign, privateKey); // Assuming you have this function

      final headers = {
        'Content-Type': 'application/json',
        'X-TIMESTAMP': timestamp,
        'X-SIGNATURE': signature,
        'X-EXTERNAL-ID': randomNumericString, // Assuming you have this function
        'X-PARTNER-ID': 'SGWROYALABADISEJ',
        'CHANNEL-ID': 'ESPAY',
      };

      print(headers);

      final response = await http.post(
        Uri.parse(
            'https://sandbox-api.espay.id/apimerchant/v1.0/transfer-va/status'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        PaymentStatusResponse paymentStatus =
            PaymentStatusResponse.fromJson(data);
        return paymentStatus;
      }
    } catch (error) {
      throw Exception('Error');
    }
    throw Exception;
  }

  @override
  Future<WaResponse> getInvoice() async {
    try {
      Map<String, dynamic> requestBody = {
        "token":
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiIiwiYWRkcmVzcyI6IiIsInBpYyI6IiIsImlzX2RlbGV0ZSI6ZmFsc2UsImRhdGVfY3JlYXRlZCI6IjIwMjEtMDgtMzBUMDM6NDY6MjAuNzkwWiIsIl9pZCI6IjYxMmM1NDhjNmQxYzE0N2I5OTQwYjhhYiJ9.9ahFSM10YJqYed2ubF18TfQ4HWXi57h431lcM4U0s6I",
        "to": "+628112699912",
        "header": {
          "type": "document",
          "data":
              "https://www.ica.gov.sg/docs/default-source/ica/eservices/epr/explanatory_notes_and_document_list_for_foreign_students.pdf"
        },
        "param": ["Umar Fadhlurrachman", "Mampang Prapatan"]
      };
      final headers = {'Content-Type': 'application/json'};

      print(jsonEncode(requestBody));
      final response = await http.post(
        Uri.parse(
            'https://icwaba.damcorp.id/whatsapp/sendHsm/pos_invoice_001'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        WaResponse sendInvoice = WaResponse.fromJson(data);
        return sendInvoice;
      }
    } catch (error) {
      throw Exception(error);
    }
    throw Exception;
  }
}
