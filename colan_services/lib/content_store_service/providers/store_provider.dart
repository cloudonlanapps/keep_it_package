import 'dart:async';

import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';

class StoreNotifier extends FamilyAsyncNotifier<CLStore, ServiceLocationConfig>
    with CLLogger {
  @override
  String get logPrefix => 'StoreNotifier';

  @override
  FutureOr<CLStore> build(ServiceLocationConfig arg) async {
    try {
      final config = arg;
      final directories = await ref.watch(deviceDirectoriesProvider.future);
      final storePath = p.join(
        directories.stores.pathString,
        config.displayName,
      );

      final EntityStore entityStore;

      if (config is LocalServiceLocationConfig) {
        entityStore = await createEntityStore(
          config,
          storePath: storePath,
          generatePreview: FfmpegUtils.generatePreview,
        );
      } else if (config is RemoteServiceLocationConfig) {
        entityStore = await createOnlineEntityStore(
          config: config,
          server: await ref.watch(serverProvider(config).future),
          storePath: storePath,
        );
      } else {
        throw Exception('Unknown service location config type');
      }

      return CLStore(
        entityStore: entityStore,
        tempFilePath: directories.temp.pathString,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final storeProvider =
    AsyncNotifierProviderFamily<StoreNotifier, CLStore, ServiceLocationConfig>(
      StoreNotifier.new,
    );
