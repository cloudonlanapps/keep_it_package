import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/server_query.dart';

class ServerCLEntityQuery extends ServerQuery {
  @override
  String getQueryString({Map<String, dynamic>? map}) {
    final keyValuePair = <String, String>{};
    if (map != null) {
      for (final query in map.entries) {
        final key = query.key;
        final value = query.value;
        if (_validQueryKeys.contains(key)) {
          switch (value) {
            case null:
              keyValuePair[key] = '__null__';

            case (final NotNullValue _):
              keyValuePair[key] = '__notnull__';

            case (final List<dynamic> _) when value.isNotEmpty:
              keyValuePair[key] = value.join(',');

            default:
              keyValuePair[key] = value.toString();
          }
        }
      }
    }

    final query =
        keyValuePair.entries.map((e) => '${e.key}=${e.value}').join('&');

    return query;
  }

  @override
  List<String> getValidQueryFields() => _validQueryKeys.toList();

  static const _validQueryKeys = <String>{
    'id',
    'isCollection',
    'label',
    'parentId',
    'addedDate',
    'updatedDate',
    'isDeleted',
    'CreateDate',
    'FileSize',
    'ImageHeight',
    'ImageWidth',
    'Duration',
    'MIMEType',
    'md5',
    'type',
    'extension',
  };
}
