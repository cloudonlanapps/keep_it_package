import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/universal_config.dart';
import 'persist_json.dart';

class UniversalConfigNotifier extends AsyncNotifier<UniversalConfiguration> {
  UniversalConfigNotifier();

  final String storeKey = 'UniversalConfiguration';

  @override
  Future<UniversalConfiguration> build() async {
    final store = await ref.watch(internalJSONStoreprovider.future);
    final json = await store.load(
      storeKey,
      const UniversalConfiguration().toJson(),
    );
    final config = UniversalConfiguration.fromJson(json);
    if (config.lastKnownVolume <= 0) {
      return config.copyWith(lastKnownVolume: 1.0);
    }
    return config;
  }

  set isManuallyPaused(bool value) =>
      state = AsyncValue.data(state.value!.copyWith(isManuallyPaused: value));

  Future<void> onChange({bool? isAudioMuted, double? lastKnownVolume}) async {
    final store = await ref.read(internalJSONStoreprovider.future);
    final volume = lastKnownVolume != null && lastKnownVolume <= 0
        ? 1.0
        : lastKnownVolume;

    state = AsyncValue.data(
      state.value!.copyWith(
        isAudioMuted: isAudioMuted,
        lastKnownVolume: volume,
      ),
    );
    await store.save(storeKey, state.value!.toJson());
  }
}

final universalConfigProvider =
    AsyncNotifierProvider<UniversalConfigNotifier, UniversalConfiguration>(
      UniversalConfigNotifier.new,
    );
