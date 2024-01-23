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
  Map<String, dynamic>? responseData;
  Map<String, dynamic>? responseDatabase;
  String errorMessage = "";
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
              onPressed: _makeApiRequest,
              child: const Text('Access API'),
            ),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : responseData != null
                        ? QrImage(
                            data: responseData!['qrContent'],
                            version: QrVersions.auto,
                            size: 200,
                          )
                        : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeApiRequest() async {
    final String randomNumericString = generateRandomNumericString();
    setState(() {
      isLoading = true;
      errorMessage = ""; // Clear any previous error message
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
      final stringToSign =
          "POST:/api/v1.0/qr/qr-mpm-generate:$hexEncode:$timestamp"; // Adjust path if needed
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
      String qrUrl = responseData!['qrUrl'];
      String trxId = getTrxIdFromUrl(qrUrl);

      // Handle successful response (e.g., display data)
      setState(() async {
        errorMessage = "";
        Map<String, dynamic> requestPutBody = {
          "partnerReferenceNo": randomNumericString,
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
}
