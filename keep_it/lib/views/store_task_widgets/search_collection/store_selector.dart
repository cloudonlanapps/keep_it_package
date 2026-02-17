import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class StoreSelector extends StatelessWidget {
  const StoreSelector({
    required this.onClose,
    super.key,
  });
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GetTargetStore(
      builder: (targetStore, actions) {
        return GetAvailableStores(
          loadingBuilder: () => CLLoadingView.widget(
            debugMessage: null,
            message: 'Scanning Avaliable Servers ...',
          ),
          errorBuilder: (e, st) => CLErrorView.local(
            message: 'Failed to get server list',
            details: e.toString(),
            actions: [
              ShadButton.destructive(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ],
          ),
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
                      ...stores.map(
                        (e) => ShadOption(
                          value: e,
                          child: Text(e.entityStore.identity),
                        ),
                      ),
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
          },
        );
      },
    );
  }
}
