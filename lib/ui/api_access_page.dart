import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:espay_v3/cubit/espay/espay_cubit.dart';
import 'package:espay_v3/ui/api_damcorp.dart';
import 'package:espay_v3/ui/list_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ApiAccessPage extends StatefulWidget {
  const ApiAccessPage({Key? key}) : super(key: key);

  @override
  _ApiAccessPageState createState() => _ApiAccessPageState();
}

class _ApiAccessPageState extends State<ApiAccessPage> {
  String formatCurrency(double amount) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatCurrency.format(amount);
  }

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
      body: BlocConsumer<EspayCubit, EspayState>(
        listener: (context, state) {
          if (state is QrisSuccess) {
            showDialog(
              context: context,
              builder: (context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: AlertDialog(
                  content: SizedBox(
                    width: 300.0, // Sesuaikan ukuran yang diinginkan
                    height: 300.0, // Sesuaikan ukuran yang diinginkan
                    child: QrImage(
                      data: state.espay.qrContent,
                      version: QrVersions.auto,
                      size: 300,
                    ),
                  ),
                ),
              ),
            );
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              final cubit = context.read<EspayCubit>();
              cubit.startApiCallTimer();
            });
          } else if (state is StatusSuccess) {
            if (state.espay.virtualAccountData.paymentFlagStatus != 'S') {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                final cubit = context.read<EspayCubit>();
                cubit.getPaymentStatus();
              });
            } else {
              bool isDialogActive(BuildContext context) {
                return Navigator.of(context, rootNavigator: true).canPop();
              }

              if (isDialogActive(context)) {
                Navigator.pop(context);
              } else {
                // Tidak ada dialog aktif
                print('Tidak ada dialog aktif');
              }
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                final cubit = context.read<EspayCubit>();
                cubit.paymentSuccess();
                cubit.stopApiCallTimer();
              });
            }
          }
        },
        builder: (context, state) {
          if (state is EspayInitial) {
          } else if (state is EspayLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QrisFailure) {
            return const Center(
              child: Text('Exception'),
            );
          } else if (state is PaymentSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 150,
                  ),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Transaction ID: ${state.espay.virtualAccountData.virtualAccountNo}',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount Paid'),
                            Text(
                              formatCurrency(
                                double.parse(state
                                    .espay.virtualAccountData.billAmount.value),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Paid By'),
                            Text(
                              state.espay.additionalInfo.productCode,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transaction Date'),
                            Text(
                              state.espay.virtualAccountData.trxDateTime
                                  .toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                final cubit = context.read<EspayCubit>();
                                cubit.sendInvoice();
                              });
                            },
                            child: const Text("Send"),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                final cubit = context.read<EspayCubit>();
                                cubit.backToHome();
                              });
                            },
                            child: const Text("Home"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: value,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (state is QrisSuccess) {
                      showDialog(
                        context: context,
                        builder: (context) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                          child: AlertDialog(
                            content: SizedBox(
                              width: 300.0, // Sesuaikan ukuran yang diinginkan
                              height: 300.0, // Sesuaikan ukuran yang diinginkan
                              child: QrImage(
                                data: state.espay.qrContent,
                                version: QrVersions.auto,
                                size: 300,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        final cubit = context.read<EspayCubit>();
                        cubit.getQris(int.parse(value.text));
                      });
                    }
                  },
                  child: const Text('Access API'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DamcorpPage()),
                    );
                  },
                  child: const Text('Damcorp'),
                ),
                Text(state.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
