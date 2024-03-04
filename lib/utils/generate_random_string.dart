String generateOrderNumber() {
  DateTime currentDate = DateTime.now();
  String dateString = currentDate.toIso8601String().substring(0, 10);
  int timestamp = currentDate.millisecondsSinceEpoch;
  String result = 'POS$timestamp';

  return result;
}

String generateRandomNumericString() {
  DateTime currentDate = DateTime.now();
  String dateString = currentDate.toIso8601String().substring(0, 10);
  int timestamp = currentDate.millisecondsSinceEpoch;
  String result = '$dateString-$timestamp';

  return result;
}
