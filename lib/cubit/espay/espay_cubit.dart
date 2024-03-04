import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:espay_v3/models/payment_status_response.dart';
import 'package:espay_v3/models/qris_response.dart';
import 'package:espay_v3/repository/espay/espay_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'espay_state.dart';

class EspayCubit extends Cubit<EspayState> {
  final EspayRepository espayRepository;
  EspayCubit(this.espayRepository) : super(EspayInitial());

  late Timer apiCallTimer;

  Future<void> getQris(int value) async {
    try {
      emit(EspayLoadInProgress());
      final response = await espayRepository.getQris(value);
      emit(QrisSuccess(espay: response));
    } catch (e) {
      emit(QrisFailure(message: 'Failed. $e'));
    }
  }

  void startApiCallTimer() {
    apiCallTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      print('cek ${apiCallTimer.isActive}');
      getPaymentStatus();
    });
  }

  void stopApiCallTimer() {
    if (apiCallTimer.isActive) {
      apiCallTimer.cancel();
    }
  }

  void sendInvoice() async {
    final response = await espayRepository.getInvoice();
  }

  void backToHome() {
    emit(EspayInitial());
  }

  void paymentSuccess() async {
    final response = await espayRepository.getPaymentStatus();
    emit(PaymentSuccess(espay: response, message: 'Payment Success'));
    sendInvoice();
  }

  Future<void> getPaymentStatus() async {
    try {
      emit(EspayLoadInProgress());
      final response = await espayRepository.getPaymentStatus();
      emit(StatusSuccess(espay: response));
    } catch (e) {
      emit(StatusFailure(message: 'Failed. $e'));
    }
  }
}
