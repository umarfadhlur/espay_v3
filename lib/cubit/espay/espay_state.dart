part of 'espay_cubit.dart';

abstract class EspayState extends Equatable {
  const EspayState();

  @override
  List<Object> get props => [];
}

class EspayInitial extends EspayState {}

class EspayLoadInProgress extends EspayState {}

class QrisSuccess extends EspayState {
  final QrisResponse espay;

  const QrisSuccess({required this.espay});

  @override
  List<Object> get props => [QrisSuccess];
}

class QrisFailure extends EspayState {
  final String message;

  const QrisFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class StatusSuccess extends EspayState {
  final PaymentStatusResponse espay;

  const StatusSuccess({required this.espay});

  @override
  List<Object> get props => [StatusSuccess];
}

class StatusFailure extends EspayState {
  final String message;

  const StatusFailure({required this.message});

  @override
  List<Object> get props => [message];
}


class PaymentSuccess extends EspayState {
  final String message;

  const PaymentSuccess({required this.message});

  @override
  List<Object> get props => [message];
}