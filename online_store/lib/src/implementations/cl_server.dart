import 'dart:async';
import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import 'cl_server_status.dart';

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

  Future<StoreReply<String>> getEndpoint(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi(baseURL, client: client).get(endPoint);

  Future<StoreReply<String>> post(
    String endPoint, {
    required Map<String, dynamic>? form,
    required String? fileName,
    http.Client? client,
    String? json,
  }) async =>
      RestApi(baseURL, client: client)
          .post(endPoint, json: json ?? '', form: form, fileName: fileName);

  Future<StoreReply<String>> put(
    String endPoint, {
    http.Client? client,
    String? json,
    Map<String, dynamic>? form,
    String? fileName,
  }) async =>
      RestApi(baseURL, client: client)
          .put(endPoint, json: json ?? '', form: form, fileName: fileName);

  Future<StoreReply<String>> delete(
    String endPoint, {
    http.Client? client,
  }) async =>
      RestApi(baseURL, client: client).delete(endPoint);

  Future<StoreReply<String?>> download(
    String endPoint,
    String targetFilePath, {
    http.Client? client,
  }) async {
    return RestApi(baseURL, client: client).download(endPoint, targetFilePath);
  }

  /* Future<List<Map<String, dynamic>>> downloadMediaInfo({
    http.Client? client,
    List<String>? types,
  }) async {
    try {
      return [
        for (final mediaType in types ?? ['image', 'video'])
          ...switch (
              await getEndpoint('/media?type=$mediaType', client: client)) {
            (final ServerResponse<String> reply) => [
                ...(jsonDecode(reply.result) as List<dynamic>),
              ].map((e) => e as Map<String, dynamic>).toList(),
            _ => []
          }
      ];
    } catch (e) {
      log('error when downloading $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> downloadCollectionInfo({
    http.Client? client,
  }) async {
    try {
      return switch (await getEndpoint('/collection', client: client)) {
        (final ServerResponse<String> reply) => [
            ...(jsonDecode(reply.result) as List<dynamic>),
          ].map((e) => e as Map<String, dynamic>).toList(),
        _ => []
      };
    } catch (e) {
      log('error when downloading $e');
      return [];
    }
  } */

  String get baseURL => '${storeURL.uri}';

  // Entity APIs

  Future<StoreReply<Map<String, dynamic>?>> getEntity(String endPoint) async {
    try {
      final reply = await getEndpoint(endPoint);
      return reply.when(
          validResponse: (data) async {
            final map = jsonDecode(data) as Map<String, dynamic>;
            return StoreResult(map);
          },
          errorResponse: (e, {st}) async => StoreError(e, st: st));
    } catch (e) {
      return StoreError({'error': e.toString()});
    }
  }

  Future<StoreReply<List<Map<String, dynamic>>>> getEntities(
      String endPoint) async {
    try {
      final reply = await getEndpoint(endPoint);
      return reply.when(validResponse: (response) async {
        final map = jsonDecode(response);
        final items = ((map as Map<String, dynamic>)['items']) as List<dynamic>;

        final mediaMapList =
            items.map((e) => e as Map<String, dynamic>).toList();
        return StoreResult(mediaMapList);
      }, errorResponse: (e, {st}) async {
        return StoreError(e, st: st);
      });
    } catch (e, st) {
      return StoreError<List<Map<String, dynamic>>>.fromString(e.toString(),
          st: st);
    }
  }

  Future<StoreReply<Map<String, dynamic>>> createEntity(
      {required bool isCollection,
      String? fileName,
      String? label,
      String? description,
      int? parentId}) async {
    try {
      final form = {
        'isCollection': isCollection ? '1' : '0',
        if (label != null) 'label': label,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId.toString()
      };
      final response = await post('/entity', fileName: fileName, form: form);
      return response.when(
          validResponse: (data) async =>
              StoreResult(jsonDecode(data) as Map<String, dynamic>),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError(const {'error': 'exception when creating a media'});
    }
  }

  Future<StoreReply<Map<String, dynamic>>> updateEntity(int id,
      {required bool isCollection,
      String? fileName,
      String? label,
      String? description,
      int? parentId}) async {
    try {
      final form = {
        'isCollection': isCollection ? '1' : '0',
        if (label != null) 'label': label,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId.toString()
      };
      final response = await put('/entity/$id', fileName: fileName, form: form);
      return response.when(
          validResponse: (data) async =>
              StoreResult(jsonDecode(data) as Map<String, dynamic>),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'update failed \n $e'});
    }
  }

  Future<StoreReply<Map<String, dynamic>>> softDeleteEntity(int id) async {
    try {
      final form = {'isDeleted': '1'};
      final response = await put('/entity/$id', form: form);
      return response.when(
          validResponse: (data) async =>
              StoreResult(jsonDecode(data) as Map<String, dynamic>),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'soft delete failed \n$e'});
    }
  }

  Future<StoreReply<Map<String, dynamic>>> restoreEntity(int id) async {
    try {
      final form = {'isDeleted': '0'};
      final response = await put('/entity/$id', form: form);
      return response.when(
          validResponse: (data) async =>
              StoreResult(jsonDecode(data) as Map<String, dynamic>),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError({'error': 'soft delete failed \n$e'});
    }
  }

  Future<StoreReply<Map<String, dynamic>>> deleteEntity(int id) async {
    try {
      final response = await delete('/entity/$id');

      return response.when(
          validResponse: (data) async =>
              StoreResult(jsonDecode(data) as Map<String, dynamic>),
          errorResponse: (e, {st}) async {
            return StoreError(e, st: st);
          });
    } catch (e) {
      return StoreError(const {'error': 'exception when creating a media'});
    }
  }
}
