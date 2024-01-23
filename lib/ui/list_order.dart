import 'package:espay_v3/utils/rsa_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:espay_v3/utils/generate_random_string.dart';

class ListOrderPage extends StatefulWidget {
  const ListOrderPage({Key? key}) : super(key: key);

  @override
  _ListOrderPageState createState() => _ListOrderPageState();
}

class _ListOrderPageState extends State<ListOrderPage> {
  Map<String, dynamic>? responseData;
  String errorMessage = "";
  List<dynamic> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://espayapi.000webhostapp.com/api/getData.php'));

    if (response.statusCode == 200) {
      // Jika request berhasil, parse data dari response
      setState(() {
        Map<String, dynamic> dataMap = json.decode(response.body);
        dataList = dataMap['data'];
      });
    } else {
      // Jika request gagal, tampilkan pesan error
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Fetch Example'),
      ),
      body: dataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _makeApiRequest('${dataList[index]['partnerReferenceNo']}');
                  },
                  child: ListTile(
                    title: Text('${dataList[index]['partnerReferenceNo']}'),
                    subtitle: Text('Rp${dataList[index]['amountValue']},00' +
                        ' ${dataList[index]['trxId']}'),
                  ),
                );
              },
            ),
    );
  }

  void _makeApiRequest(String orderNo) async {
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
      responseData = jsonDecode(response.body);
      // Handle successful response (e.g., display data)
      setState(() {
        errorMessage = "";
        print(responseData);
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString(); // Display error message
        print(errorMessage);
      });
    }
  }
}
