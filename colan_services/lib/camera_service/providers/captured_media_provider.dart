import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show CLLogger;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CapturedMediaNotifier extends StateNotifier<ViewerEntities>
    with CLLogger {
  CapturedMediaNotifier() : super(const ViewerEntities([]));

  void add(StoreEntity media) {
    log('adding media with id ${media.id}');
    state = ViewerEntities([...state.entities, media]);
  }

  void clear() {
    // Called after handing over the files to some other module.
    // We can ignore as deleting those files is the new owners responsibility
    log('clear the list');
    state = const ViewerEntities([]);
  }

  @override
  String get logPrefix => 'CapturedMediaNotifier';
}

final capturedMediaProvider =
    StateNotifierProvider<CapturedMediaNotifier, ViewerEntities>((ref) {
      return CapturedMediaNotifier();
    });
