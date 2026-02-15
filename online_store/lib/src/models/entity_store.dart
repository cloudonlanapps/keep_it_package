import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart' as sdk;
import 'package:cl_servers/cl_servers.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import 'entity_mapper.dart';
import 'query_filter_adapter.dart';

@immutable
class OnlineEntityStore extends EntityStore {
  const OnlineEntityStore({
    required super.identity,
    required RemoteServiceLocationConfig super.locationConfig,
    required this.server,
  });

  final CLServer server;

  @override
  bool get isAlive => server.connected;

  /// Helper to get StoreManager with proper error messages.
  sdk.StoreManager _requireStoreManager() {
    final storeManager = server.storeManager;
    if (storeManager != null) return storeManager;

    // Provide helpful error message
    if (!server.connected) {
      throw Exception('Server not connected');
    } else if (!server.isAuthenticated) {
      throw Exception('Not authenticated - please login');
    } else {
      throw Exception('StoreManager not available');
    }
  }

  @override
  Future<CLEntity?> get({String? md5, String? label}) async {
    final storeManager = _requireStoreManager();

    try {
      // Use new lookupEntity endpoint (added in Phase 1)
      final result = await storeManager.lookupEntity(
        md5: md5,
        label: label,
      );

      if (!result.isSuccess || result.data == null) return null;

      return EntityMapper.fromSdkEntity(result.data!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CLEntity?> getByID(int id) async {
    final storeManager = _requireStoreManager();

    try {
      final result = await storeManager.readEntity(id);
      if (!result.isSuccess || result.data == null) return null;

      return EntityMapper.fromSdkEntity(result.data!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    // Handle isHidden filter (client-side only, server doesn't support)
    if (query?.map['isHidden'] == 1) return [];

    final storeManager = _requireStoreManager();

    try {
      // Adapt query to SDK parameters
      final adapted = QueryFilterAdapter.adaptQuery(query);

      // Special case: direct ID lookup
      if (adapted.idFilter != null) {
        final entity = await getByID(adapted.idFilter!);
        return entity != null ? [entity] : [];
      }

      // Special case: exact label match with no other filters
      if (adapted.labelFilter != null && adapted.otherFilters.isEmpty) {
        final entity = await get(label: adapted.labelFilter);
        return entity != null ? [entity] : [];
      }

      // Fetch entities - all filters are server-side now!
      final result = await storeManager.listEntities(
        page: adapted.page ?? 1,
        pageSize: adapted.pageSize ?? 20,
        md5: adapted.md5,
        mimeType: adapted.mimeType,
        type: adapted.type,
        width: adapted.width,
        height: adapted.height,
        fileSizeMin: adapted.fileSizeMin,
        fileSizeMax: adapted.fileSizeMax,
        dateFrom: adapted.dateFrom,
        dateTo: adapted.dateTo,
        excludeDeleted: adapted.excludeDeleted ?? true,
        parentId: adapted.parentId, // ✅ Phase 1 complete
        isCollection: adapted.isCollection, // ✅ Phase 1 complete
      );

      if (!result.isSuccess || result.data == null) return [];

      var entities = EntityMapper.fromSdkEntities(result.data!.items);

      // Apply client-side filters ONLY for client-side fields (pin)
      if (adapted.pinFilter != null) {
        entities = entities.where((e) {
          return adapted.pinFilter == NotNullValue
              ? e.pin != null
              : e.pin == null;
        }).toList();
      }

      return entities;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CLEntity?> upsert(CLEntity curr, {String? path}) async {
    final storeManager = _requireStoreManager();

    try {
      final result = curr.id != null
          ? await storeManager.updateEntity(
              curr.id!,
              label: curr.label ?? '',
              description: curr.description,
              isCollection: curr.isCollection,
              parentId: curr.parentId,
              imagePath: path,
            )
          : await storeManager.createEntity(
              isCollection: curr.isCollection,
              label: curr.label,
              description: curr.description,
              parentId: curr.parentId,
              imagePath: path,
            );

      if (!result.isSuccess) {
        throw Exception(result.error ?? 'Upsert failed');
      }

      return EntityMapper.fromSdkEntity(result.data!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(CLEntity item) async {
    if (item.id == null) return false;

    final storeManager = _requireStoreManager();

    try {
      final result = await storeManager.deleteEntity(item.id!);
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  @override
  Uri? mediaUri(CLEntity item) {
    if (item.id == null) return null;
    final config = locationConfig as RemoteServiceLocationConfig;
    return Uri.parse('${config.storeUrl}/entities/${item.id}/media');
  }

  @override
  Uri? previewUri(CLEntity item) {
    if (item.id == null) return null;
    final config = locationConfig as RemoteServiceLocationConfig;
    return Uri.parse('${config.storeUrl}/entities/${item.id}/preview');
  }

  static Future<EntityStore> createStore({
    required RemoteServiceLocationConfig locationConfig,
    required CLServer server,
  }) async {
    return OnlineEntityStore(
      identity: locationConfig.storeUrl,
      locationConfig: locationConfig,
      server: server,
    );
  }
}

Future<EntityStore> createOnlineEntityStore({
  required RemoteServiceLocationConfig config,
  required CLServer server,
  required String storePath,
}) async {
  return OnlineEntityStore.createStore(
    server: server,
    locationConfig: config,
  );
}
