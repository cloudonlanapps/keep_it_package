import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

@immutable
class ServerQuery {
  const ServerQuery(this.query);
  factory ServerQuery.fromStoreQuery(
    Set<String> validKeys, [
    Map<String, dynamic>? map,
  ]) {
    final keyValuePair = <String, String>{};
    if (map != null) {
      for (final query in map.entries) {
        final key = query.key;
        final value = query.value;
        if (validKeys.contains(key)) {
          switch (value) {
            case null:
              if (key == 'parentId') {
                keyValuePair[key] = '0';
              }
            case (final List<dynamic> _) when value.isNotEmpty:
              keyValuePair[key] = value.join(',');

            case (final NotNullValue _):
              keyValuePair[key] = 'Unset';
            default:
              keyValuePair[key] = value.toString();
          }
        }
      }
    }

    final query =
        keyValuePair.entries.map((e) => '${e.key}=${e.value}').join('&');

    return ServerQuery(query);
  }
  final String query;
}
