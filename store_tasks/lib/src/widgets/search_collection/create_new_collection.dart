import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../providers/target_store_provider.dart';

class CreateNewCollection extends ConsumerWidget {
  const CreateNewCollection({
    required this.suggestedName,
    required this.onSelect,
    super.key,
  });

  final String suggestedName;
  final void Function(StoreEntity) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetStore = ref.watch(targetStoreProvider);
    return GestureDetector(
      onTap: () async {
        final collection = await CollectionMetadataEditor.openSheet(
            context, ref,
            collection: null,
            store: targetStore,
            suggestedLabel: suggestedName,
            description: null);
        if (collection != null) {
          final saved = await collection.dbSave();
          if (saved != null) {
            ref.read(reloadProvider.notifier).reload();
            onSelect(saved);
          }
        }
      },
      child: FolderItem(
        name: null,
        child: SizedBox.expand(
          child: FractionallySizedBox(
            widthFactor: 0.7,
            heightFactor: 0.7,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Icon(
                LucideIcons.plus,
                color: const Color(0xFFE6B65C).withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
