import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'store_query.dart';

@immutable
abstract class EntityStore {
  const EntityStore({
    required this.config,
  });

  final ServiceLocationConfig config;

  bool get isAlive;
  Future<CLEntity?> get({String? md5, String? label});
  Future<CLEntity?> getByID(int id);
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]);
  Future<CLEntity?> upsert(
    CLEntity curr, {
    String? path,
  });

  Future<bool> delete(CLEntity item);

  Uri? mediaUri(CLEntity media);
  Uri? previewUri(CLEntity media);
  bool get isLocal => config.isLocal;
  String get identity => config.identity;
}
