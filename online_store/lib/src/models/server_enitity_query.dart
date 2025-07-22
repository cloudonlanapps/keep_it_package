import 'package:online_store/src/implementations/server_query.dart';

class ServerCLEntityQuery extends ServerQuery {
  @override
  String getQueryString({Map<String, dynamic>? map}) {
    if (map == null) return '';
    final queryList = <String>[];
    for (final query in map.entries) {
      final key = query.key;
      final value = query.value;

      switch (value) {
        case null:
        case []:
        case (final List<dynamic> _) when value.isEmpty:
          break;
        case (final List<dynamic> _) when value.isNotEmpty:
          queryList.add(value.map((e) => '$key=$e').join('&'));

        default:
          queryList.add('$key=$value');
      }
    }
    final result = queryList.join('&');
    if (map.isNotEmpty && result.isEmpty) {
      // If this happens, all the entried will be returned.
      // Should we allow?
    }
    return result;
  }

  @override
  List<String> getValidQueryFields() => _validQueryKeys.toList();

  static const _validQueryKeys = <String>{
    'isCollection',
    'isDeleted',
    'label',
    'md5',
    'MIMEType',
    'extension',
    'label_starts_with',
    'id',
    'parentId',
    'ImageHeight',
    'ImageWidth',
    'Duration',
    'FileSizeMin',
    'FileSizeMax',
    'addedDate_from',
    'updatedDate_from',
    'CreateDate',
    'CreateDate_from',
    'addedDate_till',
    'updatedDate_till',
    'CreateDate_till',
    'Duration_min',
    'Duration_max',
    'CreateDate_day',
    'CreateDate_month',
    'CreateDate_year'
  };
}
