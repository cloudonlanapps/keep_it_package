import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_factory/form_factory.dart';

import 'package:store/store.dart';

class EditCollectionDescription extends StatelessWidget {
  const EditCollectionDescription({
    required this.collection,
    required this.onDone,
    super.key,
  });
  final StoreEntity collection;
  final void Function(StoreEntity collection) onDone;

  @override
  Widget build(BuildContext context) {
    return CLWizardFormField(
      actionMenu: (context, onTap) => CLMenuItem(
        icon: clIcons.save,
        title: 'Save',
        onTap: onTap,
      ),
      descriptor: CLFormTextFieldDescriptor(
        title: 'Description',
        label: 'About "${collection.label}"',
        initialValue: collection.label!,
        hint: 'What is the best thing,'
            ' you can say about "${collection.label}"?',
        onValidate: (val) => null,
        maxLines: 4,
      ),
      onSubmit: (result) async {
        final description = (result as CLFormTextFieldResult).value;

        final updated =
            await collection.updateWith(description: () => description);
        if (updated == null) {
          throw Exception('update Failed');
        }
        onDone(updated);
      },
    );
  }
}
