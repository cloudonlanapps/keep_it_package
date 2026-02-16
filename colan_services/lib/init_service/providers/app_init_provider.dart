import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_descriptor.dart';

final FutureProviderFamily<void, AppDescriptor> appInitProvider =
    FutureProvider.family<void, AppDescriptor>((ref, appDescriptor) async {
  final result = await appDescriptor.appInitializer(ref);
  if (!result) {
    throw Exception('appInitializer return null');
  }

  return;
});
