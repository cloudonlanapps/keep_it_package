import 'package:content_store/src/stores/models/registered_service_locations.dart';
import 'package:content_store/src/stores/providers/registerred_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builder widget for accessing registered service locations
class GetRegisteredServiceLocations extends ConsumerWidget {
  const GetRegisteredServiceLocations({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(RegisteredServiceLocations locations) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(registeredServiceLocationsProvider);

    return locationsAsync.when(
      data: builder,
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
