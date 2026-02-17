import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../pick_collection/pick_wizard.dart';
import '../pick_collection/wizard_error.dart';
import 'search_bar.dart';
import 'search_view.dart';

class CollectionSearchView extends StatefulWidget {
  const CollectionSearchView({required this.collection, super.key});

  final StoreEntity? collection;

  @override
  State<StatefulWidget> createState() => _CollectionSearchViewState();
}

class _CollectionSearchViewState extends State<CollectionSearchView> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    controller = TextEditingController(text: widget.collection?.label ?? '');
    focusNode = FocusNode()..requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void onClose() {
    Navigator.of(context).pop();
  }

  void onSelect(StoreEntity entity) => Navigator.of(context).pop(entity);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetActiveStore(
        loadingBuilder: () => CLLoadingView.widget(debugMessage: null),
        errorBuilder: (e, st) {
          return CLErrorView.custom(
            child: WizardError(
              error: e.toString(),
              onClose: onClose,
            ),
          );
        },
        builder: (activeStore) {
          return WithTargetStoreOverride(
            store: widget.collection?.store ?? activeStore,
            builder: () => Column(
              spacing: 8,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ShadButton.ghost(
                    onPressed: onClose,
                    child: clIcons.closeFullscreen.iconFormatted(),
                  ),
                ),
                PickWizard(
                  child: EntitySearchBar(
                    controller: controller,
                    focusNode: focusNode,
                    onClose: onClose,
                  ),
                ),
                Expanded(
                  child: ShadCard(
                    padding: const EdgeInsets.all(8),
                    child: SearchView(
                      controller: controller,
                      onClose: onClose,
                      onSelect: onSelect,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
