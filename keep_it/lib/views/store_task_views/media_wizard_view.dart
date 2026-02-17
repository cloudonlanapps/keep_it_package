import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

import '../page_manager.dart';
import '../store_task_widgets/store_task_wizard.dart';

class MediaWizardView extends StatelessWidget {
  const MediaWizardView({
    required this.type,
    super.key,
  });
  final String type;

  @override
  Widget build(BuildContext context) {
    return GetReload(
      builder: (reload) {
        return StoreTaskWizard(
          type: type,
          onDone: ({required isCompleted}) {
            reload();
            PageManager.of(context).pop(isCompleted);
          },
        );
      },
    );
  }
}
