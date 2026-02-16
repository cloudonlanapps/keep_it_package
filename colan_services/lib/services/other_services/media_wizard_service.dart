import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../views/store_task_widgets/store_task_wizard.dart';
import '../basic_page_service/widgets/page_manager.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    super.key,
  });
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreTaskWizard(
      type: type,
      onDone: ({required isCompleted}) {
        ref.read(reloadProvider.notifier).reload();
        PageManager.of(context).pop(isCompleted);
      },
    );
  }
}
