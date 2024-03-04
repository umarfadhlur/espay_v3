import 'dart:typed_data';

import 'package:espay_v3/ui/list_order.dart';
import 'package:espay_v3/utils/rsa_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:espay_v3/utils/generate_random_string.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ApiAccessPage extends StatefulWidget {
  @override
  _ApiAccessPageState createState() => _ApiAccessPageState();
}

class _ApiAccessPageState extends State<ApiAccessPage> {
  Map<String, dynamic> responseData = {};
  Map<String, dynamic> responsePut = {};
  Map<String, dynamic>? responseDatabase;
  bool isLoading = false;
  String errorMessage = "";
  final value = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Access Page'),
        actions: [
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListOrderPage()),
              );
            },
            child: Text("List Order"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
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
              onPressed: _makeApiRequest,
              child: Text('Access API'),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : responseData.isNotEmpty
                    ? responseData['qrContent'] != null
                        ? Center(
                            child: QrImage(
                              data: responseData['qrContent'],
                              version: QrVersions.auto,
                              size: 300,
                            ),
                          )
                        : Text(jsonEncode(responseData))
                    : const SizedBox(),
            // Text(errorMessage),
          ],
        ),
      ),
    );
  }

  void _makeApiRequest() async {
    final String randomNumericString = generateRandomNumericString();
    setState(() {
      errorMessage = ""; // Clear any previous error message
      isLoading = true;
    });
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      Map<String, dynamic> requestBody = {
        "partnerReferenceNo": randomNumericString,
        "merchantId": "SGWROYALABADISEJ",
        "amount": {"value": value.text, "currency": "IDR"},
        "additionalInfo": {"productCode": "QRIS"}
      };
      print(jsonEncode(requestBody));
      final hexEncode = hexEncodeSHA256(jsonEncode(requestBody)).toLowerCase();
      print(hexEncode);
      final stringToSign =
          "POST:/api/v1.0/qr/qr-mpm-generate:$hexEncode:$timestamp"; // Adjust path if needed
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

      String getTrxIdFromUrl(String url) {
        Uri uri = Uri.parse(url);
        String trxId = uri.queryParameters['trx_id'] ?? '';
        return trxId;
      }

      // Mendapatkan nilai trx_id dari qrUrl
      String qrUrl = responseData['qrUrl'];
      String trxId = getTrxIdFromUrl(qrUrl);

      print('Nilai trx_id dari qrUrl: $trxId');

      // Handle successful response (e.g., display data)
      setState(() async {
        errorMessage = "";
        Map<String, dynamic> requestPutBody = {
          "partnerReferenceNo": randomNumericString,
          "amountValue": value.text,
          "trxId": trxId,
        };
        print(responseDatabase);
        print('pembatas');
        print(responseData);

        final putDatabase = await http.post(
          Uri.parse(
              'https://espayapi.000webhostapp.com/api/putData.php'), // Adjust URL if needed
          headers: headers,
          body: jsonEncode(requestPutBody),
        );
        print('pembatas');
        print(jsonDecode(putDatabase.body));
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString(); // Display error message
        print(errorMessage);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
