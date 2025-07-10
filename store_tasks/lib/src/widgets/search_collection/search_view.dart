import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/providers/target_store_provider.dart';
import 'package:store_tasks/src/widgets/search_collection/create_new_collection.dart';
import 'package:store_tasks/src/widgets/search_collection/suggested_collection.dart';

import '../pick_collection/wizard_error.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({
    required this.onClose,
    required this.onSelect,
    required this.controller,
    super.key,
  });

  final VoidCallback onClose;
  final void Function(StoreEntity) onSelect;
  final TextEditingController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  @override
  void initState() {
    widget.controller.addListener(refresh);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final targetStore = ref.watch(targetStoreProvider);
    final searchText = widget.controller.text;
    return GetEntities(
        store: targetStore,
        isCollection: true,
        //isHidden: null,
        isDeleted: null,
        loadingBuilder: () => CLLoader.widget(debugMessage: null),
        errorBuilder: (e, st) =>
            WizardError.show(context, e: e, st: st, onClose: widget.onClose),
        builder: (entries) {
          final List<StoreEntity> items;
          if (searchText.isEmpty) {
            items = entries.entities.cast<StoreEntity>();
          } else {
            items = entries.entities
                .cast<StoreEntity>()
                .where((item) => item.label!.startsWith(searchText))
                .toList();
          }
          return CLGrid(
            columns: 3,
            itemCount: items.length + 1,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return CreateNewCollection(
                    onSelect: widget.onSelect, suggestedName: searchText);
              }
              return SuggestedCollection(
                item: items[index],
                onSelect: widget.onSelect,
              );
            },
          );
        });
  }
}
