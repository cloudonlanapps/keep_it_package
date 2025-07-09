// ignore_for_file: avoid_print, print required for testing

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

extension TextExtOnCLServer on CLServer {
  Future<CLEntity> validCreate(
      {bool Function()? isCollection,
      String? Function()? label,
      String? Function()? description}) async {
    final reply = await upsert(
        isCollection: isCollection, label: label, description: description);
    final reference = await reply.when(
      validResponse: (result) async {
        return result;
      },
      errorResponse: (error, {st}) async {
        fail('$error');
      },
    );
    return reference;
  }

  Future<void> cleanupEntity(List<int> ids) async {
    for (final id in ids) {
      final prefix = 'id: $id, ';
      await (await toBin(id)).when(
        validResponse: (success) async {
          expect(success, true, reason: '$prefix toBin is not returning True');
        },
        errorResponse: (error, {st}) async {
          fail('$prefix toBin failed $error');
        },
      );
      await (await deletePermanent(id)).when(
        validResponse: (success) async {
          expect(success, true,
              reason: '$prefix deletePermanent is not returning True');
        },
        errorResponse: (error, {st}) async {
          fail('$prefix deletePermanent failed $error');
        },
      );
    }
    // Confirm if they are really deleted
    for (final id in ids) {
      final prefix = 'id: $id, ';
      final item = await (await getById(id)).when(validResponse: (data) async {
        return data;
      }, errorResponse: (e, {st}) async {
        expect(e['status_code'], 404, reason: 'got status code other than 404');
        return null;
      });
      expect(item, null, reason: '$prefix not deleted properly');
      print('$prefix test artifacts cleaned');
    }
  }

  Future<void> cleanupCollection(List<int> ids) {
    throw UnimplementedError();
  }
}
