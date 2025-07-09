// ignore_for_file: avoid_print test requires print

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:online_store/src/implementations/cl_server.dart';
import 'package:test/test.dart';

import 'test_modules.dart';
import 'text_ext_on_cl_server.dart';
import 'utils.dart';

/// Add Tests for
/// Creating a collection with file
/// Creating a collection with parentId

void main() async {
  late CLServer server;
  late TestArtifacts testArtifacts;

  setUpAll(() async {
    server = await TextExtOnCLServer.establishConnection();
    testArtifacts = TestArtifacts(
        tempDir: 'image_test_dir_${randomString(5)}', server: server);
  });
  tearDownAll(() async {
    await testArtifacts.dispose();
  });

  setUp(() async {});
  tearDown(() async {});
  group('Test Collection Interface', () {
    test('Describe here', () async {
      throw Exception('Implement here');
    });
  });
}
