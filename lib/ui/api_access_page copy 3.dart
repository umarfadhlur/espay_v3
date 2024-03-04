import 'dart:async';
import 'dart:ui';

import 'package:espay_v3/ui/api_damcorp.dart';
import 'package:espay_v3/ui/list_order.dart';
import 'package:espay_v3/utils/rsa_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:espay_v3/utils/generate_random_string.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ApiAccessPage extends StatefulWidget {
  const ApiAccessPage({Key? key}) : super(key: key);

  @override
  _ApiAccessPageState createState() => _ApiAccessPageState();
}

class _ApiAccessPageState extends State<ApiAccessPage> {
  Map<String, dynamic> responseData = {};
  Map<String, dynamic> responsePayment = {};
  Map<String, dynamic>? responseDatabase;
  String errorMessage = "";
  String myOrderNumber = "";
  final value = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Access Page'),
        actions: [
          TextButton(
            child: const Text(
              "List Order",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListOrderPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: value,
            ),
            ElevatedButton(
              onPressed: () {
                if (responseData.isNotEmpty) {
                  // Jika ada isinya, tampilkan AlertDialog
                  showQRCodeDialog(context);
                } else {
                  requestQRCodeData();
                }
                // _makeApiRequest();
              },
              child: const Text('Access API'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DamcorpPage()),
                );
              },
              child: const Text('Damcorp'),
            ),
            // Text(jsonEncode(responseData)),
          ],
        ),
      ),
    );
  }

  void _makeApiRequest() async {
    final String orderNumber = generateOrderNumber();
    setState(() {
      isLoading = true;
      errorMessage = ""; // Clear any previous error message
      myOrderNumber = orderNumber; // Clear any previous error message
    });
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      String dateString = timestamp.substring(0, timestamp.indexOf('T'));
      print(dateString);
      Map<String, dynamic> requestBody = {
        "partnerReferenceNo": myOrderNumber,
        "merchantId": "SGWROYALABADISEJ",
        "amount": {"value": "${value.text}.00", "currency": "IDR"},
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

      final response = await http.post(
        Uri.parse(
            'https://sandbox-api.espay.id/api/v1.0/qr/qr-mpm-generate'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );

      responseDatabase = jsonDecode(pushDatabase.body);
      responseData = jsonDecode(response.body);

      print('new' + jsonDecode(response.body));

      String getTrxIdFromUrl(String url) {
        Uri uri = Uri.parse(url);
        String trxId = uri.queryParameters['trx_id'] ?? '';
        return trxId;
      }

      // Mendapatkan nilai trx_id dari qrUrl
      String qrUrl = responseData['qrUrl'];
      String trxId = getTrxIdFromUrl(qrUrl);

      // Handle successful response (e.g., display data)
      setState(() async {
        errorMessage = "";
        Map<String, dynamic> requestPutBody = {
          "partnerReferenceNo": orderNumber,
          "amountValue": value.text,
          "trxId": trxId,
        };

        final putDatabase = await http.post(
          Uri.parse(
              'https://espayapi.000webhostapp.com/api/putData.php'), // Adjust URL if needed
          headers: headers,
          body: jsonEncode(requestPutBody),
        );
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showQRCodeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        bool dialogLoading;
        responseData.isNotEmpty ? dialogLoading = false : dialogLoading = true;
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted) {
                setState(() {
                  dialogLoading = false;
                });
                print(myOrderNumber);
                _checkPaymentStatus(myOrderNumber);
              }
            });
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: AlertDialog(
                content: SizedBox(
                  width: 330,
                  height: 330,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: dialogLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : responseData.isNotEmpty
                                  ? Center(
                                      child: QrImage(
                                        data: responseData['qrContent'],
                                        version: QrVersions.auto,
                                        size: 300,
                                      ),
                                    )
                                  : const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      // Ensure that the widget is still mounted before updating the state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void requestQRCodeData() {
    setState(() {
      _makeApiRequest();
    });
    showQRCodeDialog(context);
  }

  void _checkPaymentStatus(String orderNo) async {
    final String randomNumericString = generateRandomNumericString();
    setState(() {
      errorMessage = ""; // Clear any previous error message
    });
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      Map<String, dynamic> requestBody = {
        "partnerServiceId": " ESPAY",
        "customerNo": "SGWROYALABADISEJ",
        "virtualAccountNo": orderNo,
        "inquiryRequestId": "abcdef-123456-abcdef",
        "paymentRequestId": "abcdef-123456-abcdef",
      };
      final hexEncode = hexEncodeSHA256(jsonEncode(requestBody)).toLowerCase();
      final stringToSign =
          "POST:/apimerchant/v1.0/transfer-va/status:$hexEncode:$timestamp"; // Adjust path if needed
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

      final response = await http.post(
        Uri.parse(
            'https://sandbox-api.espay.id/apimerchant/v1.0/transfer-va/status'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );
      responsePayment = jsonDecode(response.body);
      print(responseData);
      // Handle successful response (e.g., display data)
      setState(() {
        errorMessage = "";
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString(); // Display error message
        print(errorMessage);
      });
    }
  }
}
