import 'dart:async';
import 'dart:convert';
import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;

import 'entity_endpoint.dart';

extension EntityServer on CLServer {
  Future<StoreReply<List<CLEntity>>> getAll(
      {String queryString = '', http.Client? client}) async {
    final endPoint = EntityEndPoint.getAll();
    try {
      final query = queryString.isEmpty ? '' : '?$queryString';
      final reply = await get('$endPoint$query');
      return reply.when(validResponse: (response) async {
        final map = jsonDecode(response as String);
        final items = (((map as Map<String, dynamic>)['items']) ?? <CLEntity>[])
            as List<dynamic>;
        final mediaMapList =
            items.cast<Map<String, dynamic>>().map(CLEntity.fromMap).toList();
        return StoreResult(mediaMapList);
      }, errorResponse: (e, {st}) async {
        return StoreError(e, st: st);
      });
    } catch (e, st) {
      return StoreError<List<CLEntity>>.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<CLEntity?>> getEntiy(
      {String? md5, String? label, http.Client? client}) async {
    final endPoint = EntityEndPoint.get();
    final queryString = [
      if (md5 != null) 'md5=$md5',
      if (label != null) 'label=$label'
    ].join('&');
    try {
      final reply = await get('$endPoint?$queryString');
      return reply.when(validResponse: (response) async {
        return StoreResult(CLEntity.fromJson(response as String));
      }, errorResponse: (e, {st}) async {
        return StoreError(e, st: st);
      });
    } catch (e, st) {
      return StoreError<CLEntity?>.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<CLEntity?>> getById(int id, {http.Client? client}) async {
    final endPoint = EntityEndPoint.getById(id);
    try {
      final reply = await get(endPoint);
      return reply.when(
          validResponse: (response) async {
            return StoreResult(CLEntity.fromJson(response as String));
          },
          errorResponse: (e, {st}) async => StoreError(e, st: st));
    } catch (e) {
      return StoreError({'error': e.toString()});
    }
  }

  Future<StoreReply<CLEntity>> upsert(
      {int? id,
      String? fileName,
      bool Function()? isCollection,
      String? Function()? label,
      String? Function()? description,
      int? Function()? parentId,
      http.Client? client}) async {
    try {
      final form = {
        if (isCollection != null) 'isCollection': isCollection() ? '1' : '0',
        if (label != null) 'label': label(),
        if (description != null) 'description': description(),
        if (parentId != null) 'parentId': parentId().toString()
      };
      final StoreReply<String> response;
      if (id != null) {
        response = (await put(EntityEndPoint.update(id),
                filesFields: fileName == null
                    ? null
                    : {
                        'media': [fileName]
                      },
                formFields: form))
            .cast();
      } else {
        response = (await post(EntityEndPoint.create(),
                filesFields: fileName == null
                    ? null
                    : {
                        'media': [fileName]
                      },
                formFields: form))
            .cast();
      }

      return response.when(
          validResponse: (data) async => StoreResult(CLEntity.fromJson(data)),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'update failed \n $e'});
    }
  }

  Future<StoreReply<bool>> toBin(int id, {http.Client? client}) async {
    try {
      final response = await put(EntityEndPoint.toBin(id));
      return response.when(
          validResponse: (data) async => StoreResult(true),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'soft delete failed \n$e'});
    }
  }

  Future<StoreReply<CLEntity>> restore(int id, {http.Client? client}) async {
    try {
      final response = await put(EntityEndPoint.restore(id));
      return response.when(
          validResponse: (response) async =>
              StoreResult(CLEntity.fromJson(response as String)),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'restore failed  \n$e'});
    }
  }

  Future<StoreReply<bool>> deletePermanent(int id,
      {http.Client? client}) async {
    try {
      final response = await delete(EntityEndPoint.deletePermanent(id));
      return response.when(
          validResponse: (data) async => StoreResult(true),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'delete failed \n$e'});
    }
  }

  // BLOB paths
  Uri mediaFilePath(int id, {http.Client? client}) {
    return getEndpointURI(EntityEndPoint.downloadMedia(id));
  }

  Uri previewFilePath(int id, {http.Client? client}) {
    return getEndpointURI(EntityEndPoint.downloadPreview(id));
  }

  Uri streamM3U8FilePath(int id, {http.Client? client}) {
    return getEndpointURI(EntityEndPoint.streamM3U8(id));
  }

  Uri streamSegmentFilePath(int id, String seg, {http.Client? client}) {
    return getEndpointURI(EntityEndPoint.streamSegment(id, seg));
  }

  Future<StoreReply<Map<String, dynamic>>> filterLoopBack(
      {String queryString = '', http.Client? client}) async {
    final endPoint = EntityEndPoint.filterloopback();
    try {
      final query = queryString.isEmpty ? '' : '?$queryString';
      final reply = await get('$endPoint$query');
      return reply.when(validResponse: (response) async {
        final map = jsonDecode(response as String);
        return StoreResult(map as Map<String, dynamic>);
      }, errorResponse: (e, {st}) async {
        return StoreError(e, st: st);
      });
    } catch (e, st) {
      return StoreError<Map<String, dynamic>>.fromString(e.toString(), st: st);
    }
  }
}
