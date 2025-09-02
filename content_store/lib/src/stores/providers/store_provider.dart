import 'dart:async';

import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:online_store/online_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';
import 'server_provider.dart';

class StoreNotifier extends FamilyAsyncNotifier<CLStore, CLUrl> with CLLogger {
  @override
  String get logPrefix => 'StoreNotifier';
  @override
  FutureOr<CLStore> build(CLUrl arg) async {
    try {
      final storeURL = arg;
      final directories = await ref.watch(deviceDirectoriesProvider.future);
      final scheme = storeURL.scheme; // local or https
      final storePath = p.join(directories.stores.pathString, storeURL.name);
      final store = switch (scheme) {
        'local' => await createEntityStore(
            storeURL,
            storePath: storePath,
            generatePreview: FfmpegUtils.generatePreview,
          ),
        'http' => await createOnlineEntityStore(
            storeURL: storeURL,
            server: await ref.watch(serverProvider(storeURL).future),
            storePath: storePath,
          ),
        'https' => await createOnlineEntityStore(
            storeURL: storeURL,
            server: await ref.watch(serverProvider(storeURL).future),
            storePath: storePath,
          ),
        _ => throw Exception('Unexpected')
      };
      return CLStore(store: store, tempFilePath: directories.temp.pathString);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final storeProvider =
    AsyncNotifierProviderFamily<StoreNotifier, CLStore, CLUrl>(
        StoreNotifier.new);
