// ignore_for_file: avoid_print, print required for testing

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:online_store/src/implementations/rest_api.dart';
import 'package:online_store/src/models/entity_endpoint.dart';
import 'package:online_store/src/models/entity_server.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'test_context.dart';

extension TestExtOnCLServer on CLServer {
  static Future<CLServer> establishConnection() async {
    // const serverAddr = 'http://192.168.0.225:5000'; RaspPi
    const serverAddr = 'http://127.0.0.1:5001'; //Mac
    try {
      final url = CLUrl(Uri.parse(serverAddr), identity: null, label: null);

      final server = await CLServer(storeURL: url).withId();
      if (!server.connected) {
        fail('Connection Failed, could not get the server Id');
      }
      return server;
    } catch (e) {
      fail('Failed: $e');
    }
  }

  Future<CLEntity> validCreate(
    TestContext context, {
    int? id,
    String? fileName,
    bool Function()? isCollection,
    String? Function()? label,
    String? Function()? description,
    int? Function()? parentId,
  }) async {
    final reply = await upsert(
        id: id,
        fileName: fileName,
        isCollection: isCollection,
        label: label,
        description: description,
        parentId: parentId);
    final reference = await reply.when(
      validResponse: (result) async {
        if (result.id != null) {
          context.entities.add(result.id!);
        }
        return result;
      },
      errorResponse: (error, {st}) async {
        fail('$error');
      },
    );
    return reference;
  }

  Future<Map<String, dynamic>> invalidCreate(
    TestContext context, {
    int? id,
    String? fileName,
    bool Function()? isCollection,
    String? Function()? label,
    String? Function()? description,
    int? Function()? parentId,
  }) async {
    final reply = await upsert(
        id: id,
        fileName: fileName,
        isCollection: isCollection,
        label: label,
        description: description,
        parentId: parentId);
    final reference = await reply.when<Map<String, dynamic>>(
      validResponse: (result) async {
        if (result.id != null) {
          context.entities.add(result.id!);
        }
        fail('Expected not to succeed');
      },
      errorResponse: (error, {st}) async {
        return error;
      },
    );
    return reference;
  }

  void warn(String msg) {
    print(msg);
  }

  void warnIfFailed(String msg, {required bool condition}) {
    if (!condition) {
      print(msg);
    }
  }

  Future<void> cleanupEntity(Set<int> ids) async {
    for (final id in ids) {
      final prefix = 'id: $id, ';
      await (await toBin(id)).when(
        validResponse: (success) async {
          warnIfFailed('$prefix toBin is not returning True',
              condition: success);
        },
        errorResponse: (error, {st}) async {
          warn('$prefix toBin failed $error');
        },
      );
      await (await deletePermanent(id)).when(
        validResponse: (success) async {
          warnIfFailed('$prefix deletePermanent is not returning True',
              condition: success);
        },
        errorResponse: (error, {st}) async {
          print('$prefix deletePermanent failed $error');
        },
      );
    }
    // Confirm if they are really deleted
    for (final id in ids) {
      final prefix = 'id: $id, ';
      final item = await (await getById(id)).when(validResponse: (data) async {
        return data;
      }, errorResponse: (e, {st}) async {
        warnIfFailed(
          'must get MissingMediaError error',
          condition: e['type'] == 'MissingMediaError',
        );
      });
      warnIfFailed('$prefix not deleted properly', condition: item == null);
      //print('$prefix test artifacts cleaned');
    }
  }

  Future<void> cleanupCollection(List<int> ids) {
    throw UnimplementedError();
  }

  Future<void> reset() async {
    await (await RestApi(
      baseURL,
    ).delete(EntityEndPoint.reset()))
        .when<String>(
      validResponse: (resp) async {
        return resp;
      },
      errorResponse: (error, {st}) async {
        fail('reset failed in tearDownAll');
      },
    );
  }
}
