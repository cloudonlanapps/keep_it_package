import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../store_reply.dart';
import 'cl_server.dart';

/// Type unaware RESET APIs
extension RESTAPi on CLServer {
  static Map<String, String> _getHeader({
    required String method,
    required bool hasForm,
    required bool hasJSON,
    required bool hasFiles,
    String? auth,
    Map<String, String>? extraHeaders,
  }) {
    if (hasForm && hasJSON) {
      throw Exception("can't use formFields and json together");
    }
    if (hasFiles && hasJSON) {
      throw Exception("can't use fileFields and json together");
    }
    final headers = <String, String>{};
    if (method == 'get') {
      headers['Content-Type'] = 'application/json';
    } else if (hasForm) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else {
      headers['Content-Type'] = 'application/json';
    }

    if (auth != null) {
      headers['Authorization'] = 'Bearer $auth';
    }
    if (extraHeaders != null) {
      for (final hdrEntry in extraHeaders.entries) {
        headers[hdrEntry.key] = hdrEntry.value;
      }
    }
    return headers;
  }

  static Future<List<http.MultipartFile>> _mapFilesToMultipartFile(
    Map<String, List<String>> files,
  ) async {
    // If file is given, we need to use MultiPart
    final List<http.MultipartFile> multipartFiles = [];
    for (final entry in files.entries) {
      final field = entry.key;
      final fileList = entry.value;
      for (final fileName in fileList) {
        final file = File(fileName);
        if (!file.existsSync()) {
          throw Exception('file does not exist: $files');
        }
        multipartFiles.add(await http.MultipartFile.fromPath(field, fileName));
      }
    }
    return multipartFiles;
  }

  Future<StoreReply<dynamic>> post(
    String endPoint, {
    http.Client? client,
    String? auth,
    int? timeoutInSec,
    Map<String, String>? extraHeaders,
    String? json,
    Map<String, List<String>>? filesFields,
    Map<String, dynamic>? formFields,
  }) async {
    try {
      final uri = Uri.parse('$baseURL$endPoint');
      final httpClient = client ?? CLServer.defaultHttpClient;
      final headers = _getHeader(
        method: 'post',
        hasFiles: filesFields != null && filesFields.isNotEmpty,
        hasJSON: json != null && json.isNotEmpty,
        hasForm: formFields != null && formFields.isNotEmpty,
        auth: auth,
        extraHeaders: extraHeaders,
      );
      http.Response response;
      if (filesFields == null) {
        response = await httpClient.post(
          uri,
          headers: headers,
          body: (formFields != null) ? formFields : json,
        );
      } else {
        final uploadableFiles = await _mapFilesToMultipartFile(filesFields);

        final request = http.MultipartRequest('POST', uri)
          ..headers.addAll(headers)
          ..files.addAll(uploadableFiles);
        if (formFields != null) {
          for (final item in formFields.entries) {
            request.fields[item.key] = item.value.toString();
          }
        }

        response = await httpClient
            .send(request)
            .timeout(
              Duration(seconds: timeoutInSec ?? CLServer.defaultTimeoutInSec),
            )
            .then(http.Response.fromStream);
      }
      if ([200, 201].contains(response.statusCode)) {
        return StoreResult(response.body);
      }

      return StoreError<dynamic>.fromString(response.body);
    } catch (e, st) {
      return StoreError.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<dynamic>> get(
    String endPoint, {
    http.Client? client,
    String? auth,
    int? timeoutInSec,
    Map<String, String>? extraHeaders,
    String? outputFileName,
  }) async {
    try {
      final uri = Uri.parse('$baseURL$endPoint');
      final httpClient = client ?? CLServer.defaultHttpClient;
      final headers = _getHeader(
        method: 'get',
        hasFiles: false,
        hasJSON: false,
        hasForm: false,
        auth: auth,
        extraHeaders: extraHeaders,
      );
      if (outputFileName != null && !headers.containsKey('Accept')) {
        headers['Accept'] = 'application/octet-stream';
      }
      http.Response? response;
      response = await httpClient.get(uri, headers: headers);
      if ([200, 201].contains(response.statusCode)) {
        if (outputFileName != null) {
          final file = File(outputFileName);
          await file.writeAsBytes(response.bodyBytes);
          return StoreResult(outputFileName);
        } else {
          return StoreResult(response.body);
        }
      }

      return StoreError<dynamic>.fromString(response.body);
    } catch (e, st) {
      return StoreError.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<dynamic>> put(
    String endPoint, {
    http.Client? client,
    String? auth,
    int? timeoutInSec,
    Map<String, String>? extraHeaders,
    String? json,
    Map<String, List<String>>? filesFields,
    Map<String, dynamic>? formFields,
  }) async {
    try {
      final uri = Uri.parse('$baseURL$endPoint');
      final httpClient = client ?? CLServer.defaultHttpClient;
      final headers = _getHeader(
        method: 'put',
        hasFiles: filesFields != null && filesFields.isNotEmpty,
        hasJSON: json != null && json.isNotEmpty,
        hasForm: formFields != null && formFields.isNotEmpty,
        auth: auth,
        extraHeaders: extraHeaders,
      );
      http.Response response;
      if (filesFields == null) {
        response = await httpClient.put(
          uri,
          headers: headers,
          body: (formFields != null) ? formFields : json,
        );
      } else {
        final uploadableFiles = await _mapFilesToMultipartFile(filesFields);

        final request = http.MultipartRequest('PUT', uri)
          ..headers.addAll(headers)
          ..files.addAll(uploadableFiles);
        if (formFields != null) {
          for (final item in formFields.entries) {
            request.fields[item.key] = item.value.toString();
          }
        }

        response = await httpClient
            .send(request)
            .timeout(
              Duration(seconds: timeoutInSec ?? CLServer.defaultTimeoutInSec),
            )
            .then(http.Response.fromStream);
      }
      if ([200, 201].contains(response.statusCode)) {
        return StoreResult(response.body);
      }

      return StoreError<dynamic>.fromString(response.body);
    } catch (e, st) {
      return StoreError.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<dynamic>> delete(
    String endPoint, {
    http.Client? client,
    String? auth,
    int? timeoutInSec,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseURL$endPoint');
      final httpClient = client ?? CLServer.defaultHttpClient;
      final headers = _getHeader(
        method: 'delete',
        hasFiles: false,
        hasJSON: false,
        hasForm: false,
        auth: auth,
        extraHeaders: extraHeaders,
      );
      http.Response response;

      response = await httpClient.delete(uri, headers: headers);
      if ([200, 201].contains(response.statusCode)) {
        return StoreResult(response.body);
      }

      return StoreError<dynamic>.fromString(response.body);
    } catch (e, st) {
      return StoreError.fromString(e.toString(), st: st);
    }
  }
}
