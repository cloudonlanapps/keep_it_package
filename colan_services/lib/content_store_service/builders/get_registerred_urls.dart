import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/registerred_urls.dart';

@immutable
class RegisteredServiceLocationsActions {
  const RegisteredServiceLocationsActions({
    required this.setActiveConfig,
  });

  final void Function(ServiceLocationConfig) setActiveConfig;
}

/// Builder widget for accessing registered service locations
class GetRegisteredServiceLocations extends ConsumerWidget {
  const GetRegisteredServiceLocations({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(
    RegisteredServiceLocations locations,
    RegisteredServiceLocationsActions actions,
  )
  builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(registeredServiceLocationsProvider);
    final actions = RegisteredServiceLocationsActions(
      setActiveConfig: (config) =>
          ref.read(registeredServiceLocationsProvider.notifier).activeConfig =
              config,
    );

    return locationsAsync.when(
      data: (locations) => builder(locations, actions),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
