import 'package:intl/intl.dart';

extension UtilExtensionOnDateTime on DateTime {
  String toDisplayFormat({bool dataOnly = false}) {
    if (dataOnly) {
      return DateFormat('dd MMMM yyyy').format(this);
    } else {
      return DateFormat('dd MMMM yyyy HH:mm:ss').format(this);
    }
  }
}

extension TimeStampExtension on DateTime {
  int get utcTimeStamp => (isUtc ? this : toUtc()).millisecondsSinceEpoch;
}

extension DateTimeExtensionOnInt on int {
  DateTime get localDateTime => utcDateTime.toLocal();

  DateTime get utcDateTime =>
      DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);
}
