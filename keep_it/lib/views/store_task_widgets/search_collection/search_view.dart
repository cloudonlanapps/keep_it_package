import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../../content_store_views/dialogs/collection_metadata_editor.dart';
import '../pick_collection/wizard_error.dart';
import 'create_new_collection.dart';
import 'suggested_collection.dart';

class SearchView extends StatefulWidget {
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
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
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
    final searchText = widget.controller.text;
    return GetReload(
      builder: (onReload) {
        return GetTargetStore(
          builder: (targetStore, actions) {
            return GetEntities(
              store: targetStore,
              isCollection: true,
              //isHidden: null,
              isDeleted: null,
              loadingBuilder: () => CLLoadingView.widget(debugMessage: null),
              errorBuilder: (e, st) => WizardError.show(
                context,
                e: e,
                st: st,
                onClose: widget.onClose,
              ),
              builder: (entries, {onLoadMore}) {
                final List<StoreEntity> items;
                if (searchText.isEmpty) {
                  items = entries.entities.cast<StoreEntity>();
                } else {
                  items = entries.entities
                      .cast<StoreEntity>()
                      .where((item) => item.label!.startsWith(searchText))
                      .toList();
                }
                return SingleChildScrollView(
                  child: CLGrid(
                    columns: 3,
                    itemCount: items.length + 1,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return CreateNewCollection(
                          suggestedName: searchText,
                          onCreate: () async {
                            final collection =
                                await CollectionMetadataEditor.openSheet(
                                  context,
                                  collection: null,
                                  store: targetStore,
                                  suggestedLabel: searchText,
                                  description: null,
                                );
                            if (collection != null) {
                              final saved = await collection.dbSave();
                              if (saved != null) {
                                onReload();
                                widget.onSelect(saved);
                              }
                            }
                          },
                        );
                      }
                      return SuggestedCollection(
                        item: items[index],
                        onSelect: widget.onSelect,
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
