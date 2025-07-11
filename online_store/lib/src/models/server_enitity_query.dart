import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/server_query.dart';

class ServerCLEntityQuery extends ServerQuery {
  @override
  String getQueryString({Map<String, dynamic>? map}) {
    final queryList = <String>[];
    if (map != null) {
      for (final query in map.entries) {
        final key = query.key;
        final value = query.value;
        if (_validQueryKeys.contains(key)) {
          switch (value) {
            case null:
              queryList.add('$key=__null__');

            case (final NotNullValue _):
              queryList.add('$key=__notnull__');

            case (final List<dynamic> _) when value.isNotEmpty:
              queryList.add(value.map((e) => '$key=$e').join('&'));

            default:
              queryList.add('$key=$value');
          }
        }
      }
    }

    return queryList.join('&');
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
