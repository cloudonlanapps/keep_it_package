import 'on_date_time.dart';

extension UtilExtensionOnDateTimeNullable on DateTime? {
  String? toDisplayFormat({bool dataOnly = false}) {
    if (this != null) return this!.toDisplayFormat(dataOnly: dataOnly);
    return null;
  }
}
