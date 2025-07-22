import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';
import 'dart:typed_data';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:http/http.dart' as http;

class RestApi {
  RestApi(this._server, {this.connectViaMobile = true, this.client});
  final String _server;
  final bool connectViaMobile;
  final http.Client? client;

  static const timeout = 3600; // FIXME: For debug, reduce later

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /*  dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: REST API Service',
    ); */
  }

  Uri _generateURI(String endPoint) {
    return Uri.parse('$_server$endPoint');
  }

  http.Client get myClient => client ?? http.Client();

  Future<StoreReply<Map<String, dynamic>>> getURLStatus() async {
    try {
      log('ping server $_server');
      final response = await myClient
          .get(Uri.parse(_server))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final info = jsonDecode(response.body) as Map<String, dynamic>;
        if ((info['name'] as String) == 'CoLAN server') {
          return StoreResult(info);
        }
        log("Error: ${info['name']}");
        return StoreError.fromString(jsonEncode(response.body));
      } else {
        log('Error: ${response.statusCode} ${response.body}');
        return StoreError.fromString(response.body);
      }
    } catch (e, st) {
      log('Error: $e');
      return StoreError.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<dynamic>> call(
    String method,
    String endPoint, {
    String? auth,
    String json = '',
    String? fileName,
    Uint8List? imageData,
    String? langStr,
    Map<String, String>? extraHeaders,
    Map<String, dynamic>? form,
  }) async {
    print(endPoint);
    try {
      if (form != null && json.isNotEmpty) {
        throw Exception("can't use form and json together");
      }
      final headers = <String, String>{};
      if (method == 'get') {
        headers['Content-Type'] = 'application/json';
      } else if (form != null) {
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

      final uri = _generateURI(endPoint);

      http.Response? response;
      switch (method) {
        case 'post':
          if (fileName == null) {
            if (form != null) {
              response = await myClient.post(uri, headers: headers, body: form);
            } else {
              response = await myClient.post(uri, headers: headers, body: json);
            }
          } else {
            // If file is given, we need to use MultiPart

            final file = File(fileName);
            if (!file.existsSync()) {
              throw Exception('file does not exist: $fileName');
            }
            final request = http.MultipartRequest('POST', uri)
              ..headers.addAll(headers)
              ..files.add(await http.MultipartFile.fromPath(
                'media',
                file.path,
              ));
            if (form != null) {
              for (final item in form.entries) {
                request.fields[item.key] = item.value.toString();
              }
            }
            // json not supported ???
            response = await myClient
                .send(request)
                .timeout(const Duration(seconds: timeout))
                .then(http.Response.fromStream);
          }

        case 'put':
          if (fileName == null) {
            if (form != null) {
              response = await myClient.put(uri, headers: headers, body: form);
            } else {
              response = await myClient.put(uri, headers: headers, body: json);
            }
          } else {
            // If file is given, we need to use MultiPart

            final file = File(fileName);
            if (!file.existsSync()) {
              throw Exception('file does not exist: $fileName');
            }
            final request = http.MultipartRequest('PUT', uri)
              ..headers.addAll(headers)
              ..files.add(await http.MultipartFile.fromPath(
                'media',
                file.path,
              ));
            if (form != null) {
              for (final item in form.entries) {
                request.fields[item.key] = item.value.toString();
              }
            }
            // json not supported ???
            response = await myClient
                .send(request)
                .timeout(const Duration(seconds: timeout))
                .then(http.Response.fromStream);
          }

        case 'get':
          response = await myClient.get(uri, headers: headers);
        case 'delete':
          response = await myClient.delete(uri, headers: headers);
        case 'download':
          if (fileName == null) {
            throw Exception('target filename must be provided for download');
          }
          response = await http.get(uri, headers: headers);
          if (response.statusCode == 200) {
            final file = File(fileName);
            await file.writeAsBytes(response.bodyBytes);
            return StoreResult(null);
          } else {
            return StoreError.fromString(response.body);
          }
      }
      if (response != null) {
        if ([200, 201].contains(response.statusCode)) {
          return StoreResult(response.body);
        }

        return StoreError<dynamic>.fromString(response.body);
      }
      return StoreError({
        'error': 'Unknown http method $method expected get, post, put or delete'
      });
    } catch (e, st) {
      return StoreError.fromString(e.toString(), st: st);
    }
  }

  Future<StoreReply<String>> post(
    String endPoint, {
    String? auth,
    String json = '',
    Map<String, dynamic>? form,
    String? fileName,
  }) async {
    if (form != null) {
      return (await call('post', endPoint,
              auth: auth, form: form, fileName: fileName))
          .cast<String>();
    } else {
      return (await call('post', endPoint,
              auth: auth, json: json, fileName: fileName))
          .cast<String>();
    }
  }

  Future<StoreReply<String>> put(
    String endPoint, {
    String? auth,
    String json = '',
    Map<String, dynamic>? form,
    String? fileName,
  }) async {
    if (form != null) {
      return (await call('put', endPoint,
              auth: auth, form: form, fileName: fileName))
          .cast<String>();
    } else {
      return (await call('put', endPoint,
              auth: auth, json: json, fileName: fileName))
          .cast<String>();
    }
  }

  Future<StoreReply<String>> get(String endPoint, {String? auth}) async {
    return (await call('get', endPoint, auth: auth)).cast<String>();
  }

  Future<StoreReply<String>> delete(String endPoint, {String? auth}) async {
    return (await call('delete', endPoint, auth: auth)).cast<String>();
  }

  Future<StoreReply<String?>> download(
    String endPoint,
    String fileName, {
    String? auth,
    String bodyJSON = '',
  }) async =>
      (await call('download', endPoint, auth: auth, fileName: fileName))
          .cast<String?>();

  Future<StoreReply<Uint8List>> audio(
    String endPoint, {
    String? auth,
    String json = '',
  }) async {
    return (await call(
      'audio',
      endPoint,
      extraHeaders: {'Accept': 'Application/octet-stream'},
      json: json,
      auth: auth,
    ))
        .cast<Uint8List>();
  }
}
