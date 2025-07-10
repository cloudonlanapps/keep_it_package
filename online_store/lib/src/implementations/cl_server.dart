import 'dart:async';
import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import 'cl_server_status.dart';

import 'entity_endpoint.dart';
import 'rest_api.dart';
import 'store_reply.dart';

@immutable
class CLServer {
  const CLServer({
    required this.storeURL,
    this.label,
    this.id,
    this.status,
  });

  factory CLServer.fromMap(Map<String, dynamic> map) {
    return CLServer(
      storeURL: StoreURL.fromMap(map['url'] as Map<String, dynamic>),
      label: map['label'] != null ? map['label'] as String : null,
      id: map['id'] != null ? map['id'] as int : null,
      status: map['status'] != null
          ? ServerTimeStamps.fromMap(map['status'] as Map<String, dynamic>)
          : null,
    );
  }

  factory CLServer.fromJson(String source) =>
      CLServer.fromMap(json.decode(source) as Map<String, dynamic>);

  final StoreURL storeURL;
  final String? label;
  final int? id;
  final ServerTimeStamps? status;

  CLServer copyWith({
    StoreURL? storeURL,
    ValueGetter<String?>? label,
    ValueGetter<int?>? id,
    ValueGetter<ServerTimeStamps?>? status,
  }) {
    return CLServer(
      storeURL: storeURL ?? this.storeURL,
      label: label != null ? label.call() : this.label,
      id: id != null ? id.call() : this.id,
      status: status != null ? status.call() : this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': storeURL.toMap(),
      'label': label,
      'id': id,
      'status': status?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'CLServer(url: $storeURL, label: $label, id: $id, status: $status)';
  }

  @override
  bool operator ==(covariant CLServer other) {
    if (identical(this, other)) return true;

    return other.storeURL == storeURL &&
        other.label == label &&
        other.id == id &&
        other.status == status;
  }

  @override
  int get hashCode {
    return storeURL.hashCode ^ label.hashCode ^ id.hashCode ^ status.hashCode;
  }

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Registered Server',
    ); */
  }

  Future<CLServer> withId({http.Client? client}) async {
    try {
      final reply = await RestApi(baseURL, client: client).getURLStatus();
      return switch (reply) {
        (final StoreResult<Map<String, dynamic>> map) =>
          CLServer.fromMap(toMap()..addAll(map.result)),
        _ => copyWith(id: () => null)
      };
    } catch (e) {
      return copyWith(id: () => null);
    }
  }

  Future<CLServer> getServerLiveStatus({http.Client? client}) async =>
      withId(client: client);

  bool get hasID => id != null;

  String get identifier {
    const separator = '_';
    if (id == null) return 'Unknown';

    var hexString = id!.toRadixString(16).toUpperCase();
    hexString = hexString.padLeft(4, '0');
    final formattedHex = hexString.replaceAllMapped(
      RegExp('.{4}'),
      (match) => '${match.group(0)}$separator',
    );
    final identifierString = formattedHex.endsWith(separator)
        ? formattedHex.substring(0, formattedHex.length - 1)
        : formattedHex;
    return identifierString;
  }

  Uri getEndpointURI(String endPoint) {
    return Uri.parse('$baseURL$endPoint');
  }

  String get baseURL => '${storeURL.uri}';
}

extension EntityServer on CLServer {
  Future<StoreReply<List<CLEntity>>> getAll(
      {String queryString = '', http.Client? client}) async {
    final endPoint = EntityEndPoint.getAll();
    try {
      final reply = await RestApi(baseURL, client: client).get(endPoint);
      return reply.when(validResponse: (response) async {
        final map = jsonDecode(response);
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

  Future<StoreReply<CLEntity?>> get(
      {String queryString = '', http.Client? client}) async {
    final endPoint = EntityEndPoint.get();
    try {
      final reply =
          await RestApi(baseURL, client: client).get('$endPoint?$queryString');
      return reply.when(validResponse: (response) async {
        return StoreResult(CLEntity.fromJson(response));
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
      final reply = await RestApi(baseURL, client: client).get(endPoint);
      return reply.when(
          validResponse: (data) async {
            return StoreResult(CLEntity.fromJson(data));
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
        response = await RestApi(baseURL, client: client)
            .put(EntityEndPoint.update(id), fileName: fileName, form: form);
      } else {
        response = await RestApi(baseURL, client: client)
            .post(EntityEndPoint.create(), fileName: fileName, form: form);
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
      final response =
          await RestApi(baseURL, client: client).put(EntityEndPoint.toBin(id));
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
      final response =
          await RestApi(baseURL, client: client).put(EntityEndPoint.toBin(id));
      return response.when(
          validResponse: (data) async => StoreResult(CLEntity.fromJson(data)),
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
      final response = await RestApi(baseURL, client: client)
          .delete(EntityEndPoint.deletePermanent(id));
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
}
