import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../implementations/cl_server.dart';
import '../implementations/server_query.dart';
import 'entity_server.dart';
import 'server_enitity_query.dart';

@immutable
class OnlineEntityStore extends EntityStore {
  const OnlineEntityStore(
      {required super.identity, required super.storeURL, required this.server});

  final CLServer server;

  @override
  bool get isAlive => server.hasID;

  @override
  Future<CLEntity?> get({String? md5, String? label}) async {
    final reply = await server.get(md5: md5, label: label);
    return reply.when(
      validResponse: (result) async {
        return result;
      },
      errorResponse: (error, {st}) async {
        return null;
      },
    );
  }

  @override
  Future<CLEntity?> getByID(int id) async {
    final reply = await server.getById(id);
    return reply.when(
      validResponse: (result) async {
        return result;
      },
      errorResponse: (error, {st}) async {
        return null;
      },
    );
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    if (query != null &&
        query.map.keys.contains('isHidden') &&
        query.map['isHidden'] == 1) {
      // Servers don't support isHidden
      return [];
    }
    final serverQuery = ServerCLEntityQuery().getQueryString(map: query?.map);
    final reply = await server.getAll(queryString: serverQuery);
    return reply.when(
        validResponse: (result) async => result,
        errorResponse: (e, {st}) async => <CLEntity>[]);
  }

  @override
  Future<bool> delete(CLEntity item) async {
    if (item.id == null) return false;
    final reply = await server.deletePermanent(item.id!);
    return reply.when(
      validResponse: (response) async => response,
      errorResponse: (error, {st}) async {
        return false;
      },
    );
  }

  @override
  Uri? mediaUri(CLEntity item) {
    if (item.id == null) return null;
    return server.mediaFilePath(item.id!);
  }

  @override
  Uri? previewUri(CLEntity item) {
    if (item.id == null) return null;
    return server.previewFilePath(item.id!);
  }

  Future<StoreReply<CLEntity?>> upsert0(CLEntity curr, {String? path}) async {
    try {
      final reply = await server.upsert(
          id: curr.id,
          fileName: path,
          isCollection: () => curr.isCollection,
          label: () => curr.label,
          description: () => curr.description,
          parentId: () => curr.parentId);
      return reply.when(
          validResponse: (result) async => StoreResult(result),
          errorResponse: (e, {st}) async => StoreError(e, st: st));
    } catch (e, st) {
      return StoreError({'error': e.toString()}, st: st);
    }
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) async {
    final response = await upsert0(curr, path: path);

    return response.when(
        validResponse: (result) async => result,
        errorResponse: (e, {st}) => throw Exception(e));
  }

  static Future<EntityStore> createStore(
      {required StoreURL storeURL, required CLServer server}) async {
    return OnlineEntityStore(
        identity: server.baseURL, storeURL: storeURL, server: server);
  }
}

Future<EntityStore> createOnlineEntityStore({
  required StoreURL storeURL,
  required CLServer server,
  required String storePath,
}) async {
  return OnlineEntityStore.createStore(server: server, storeURL: storeURL);
}
