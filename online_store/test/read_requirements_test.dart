import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

import 'test_modules.dart';
import 'text_ext_on_cl_server.dart';
import 'utils.dart';

void main() async {
  late CLServer server;
  late TestContext testContext;

  setUpAll(() async {
    server = await TextExtOnCLServer.establishConnection();
    testContext = TestContext(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);
  });
  tearDownAll(() async {
    await testContext.dispose();
  });

  setUp(() async {});
  tearDown(() async {});
  group('Test Collection Interface', () {
    test(
        'R1 test getAll, and confirm all the items recently created present in it',
        () async {
      final itemsBefore = await (await server.getAll()).when(
          validResponse: (items) async => items,
          errorResponse: (e, {st}) async {
            fail('getAll Failed');
          });
      print('There are ${itemsBefore.length} items before this test');
      itemsBefore.forEach(print);

      final collectionLabel = randomString(8);
      final collection = await server.validCreate(testContext,
          isCollection: () => true, label: () => collectionLabel);

      final testMediaList = <CLEntity>[];

      for (var i = 0; i < 10; i++) {
        final fileName = testContext.createImage();
        final entity = await server.validCreate(
          testContext,
          fileName: fileName,
          parentId: () => collection.id!,
        );
        testMediaList.add(entity);
      }
      final items = await (await server.getAll()).when(
          validResponse: (items) async => items,
          errorResponse: (e, {st}) async {
            fail('getAll Failed');
          });
      print('There are ${items.length} items after this test');
      itemsBefore.forEach(print);
      for (final item in items) {
        print('checking item ${item.id}');
        expect(item.id, isNotNull); // assertion
        final expected =
            testMediaList.where((e) => e.id == item.id).firstOrNull;
        if (expected != null) {
          expect(item, expected, reason: "item retrived didn't match original");
        }
      }
    });
  });
}
