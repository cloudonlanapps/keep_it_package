import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/registered_persons.dart';

class FacesBrowser extends ConsumerWidget {
  const FacesBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(registeredPersonsProvider);
    final persons = personsAsync.whenOrNull(data: (data) => data);
    return Center(
      child: Text(
        'Nothing to show persons= ${persons?.persons.length}',
        style: ShadTheme.of(context).textTheme.muted,
      ),
    );
  }
}
