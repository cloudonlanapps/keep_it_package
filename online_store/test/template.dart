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
    test('Describe here', () async {
      throw Exception('Implement here');
    });
  });
}
