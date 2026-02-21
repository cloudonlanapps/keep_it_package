import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store_provider.dart';

/// A widget that listens for errors from a specific [storeURL] and invokes [onError].
///
/// This allows UI components to react to store errors (e.g., connection lost)
/// without the service layer being dependent on UI-specific logic like toasts.
class OnStoreError extends ConsumerWidget {
  const OnStoreError({
    required this.storeURL,
    required this.onError,
    required this.child,
    super.key,
  });

  final ServiceLocationConfig storeURL;
  final void Function(BuildContext context, Object error) onError;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(storeProvider(storeURL), (prev, next) {
      if (next is AsyncError) {
        final error = next.error;
        if (error != null) {
          onError(context, error);
        }
      }
    });

    return child;
  }
}
