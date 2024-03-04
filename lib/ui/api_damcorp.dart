import 'package:espay_v3/ui/list_order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DamcorpPage extends StatefulWidget {
  const DamcorpPage({Key? key}) : super(key: key);

  @override
  _DamcorpPageState createState() => _DamcorpPageState();
}

class _DamcorpPageState extends State<DamcorpPage> {
  Map<String, dynamic>? responseData;
  Map<String, dynamic>? responseDatabase;
  String errorMessage = "";
  final value = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damcorp Access'),
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
                        ? Text(jsonEncode(responseData))
                        : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeApiRequest() async {
    setState(() {
      isLoading = true;
      errorMessage = ""; // Clear any previous error message
    });
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

      responseData = jsonDecode(response.body);

      setState(() async {
        errorMessage = "";
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
