import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

import 'framework/framework.dart';
import 'implementations/test_filters.dart';

void main() {
  late CLServer server;
  late TestContext testContext;
  setUpAll(() async {
    print('${'''
  ******************************************************************************
  
  This module delete all the entitites in the server repo and creates a
  deterministic repo to test the filter functionality. 
  This test is designed for TEST SERVERS ONLY.
  * DON'T ACCEPT THIS ON LIVE SERVER
  * DON'T RUN ANY TEST IN PARALLEL WITH THIS TEST.
  ******************************************************************************
'''.trim()} ');

    server = await TestExtOnCLServer.establishConnection();
    testContext = TestContext(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);

    await server.reset();
    await TestFilters.setupRepo(testContext);
  });
  tearDownAll(() async {
    await testContext.dispose();
    await server.reset();
  });
  setUp(() async {});
  tearDown(() async {});

  group('filterTest', () {});
}
