import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../store_tasks_service/builders/get_target_store.dart';

class StoreSelector extends StatelessWidget {
  const StoreSelector({
    required this.onClose,
    super.key,
  });
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GetTargetStore(builder: (targetStore, actions) {
      return GetAvailableStores(
          loadingBuilder: () => CLLoader.widget(
                debugMessage: null,
                message: 'Scanning Avaliable Servers ...',
              ),
          errorBuilder: (e, st) {
            return Center(
              child: ShadBadge.destructive(
                onPressed: onClose,
                child: const Text('Failed to get server list'),
              ),
            );
          },
          builder: (stores) {
            if (!stores.contains(targetStore)) {
              return Center(
                child: ShadBadge.destructive(
                  onPressed: onClose,
                  child: const Text('Target Store Not found in list !!'),
                ),
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                const Text('Store: '),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 180),
                  child: ShadSelect<CLStore>(
                    placeholder: const Text('Select A Server'),
                    padding: EdgeInsets.zero,
                    initialValue: targetStore,
                    options: [
                      ...stores.map((e) => ShadOption(
                          value: e, child: Text(e.entityStore.identity))),
                    ],
                    selectedOptionBuilder: (context, value) {
                      return Text(value.entityStore.identity);
                    },
                    onChanged: (store) {
                      if (store != null) {
                        actions.setTargetStore(store);
                      }
                    },
                  ),
                ),
              ],
            );
          });
    });
  }
}
