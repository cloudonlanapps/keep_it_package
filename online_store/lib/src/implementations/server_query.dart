import 'package:meta/meta.dart';

@immutable
abstract class ServerQuery {
  String getQueryString();
  List<String> getValidQueryFields();
}
