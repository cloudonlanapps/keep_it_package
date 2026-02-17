import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../common_widgets/cl_error_view.dart';
import 'top_bar.dart';

class KeepItErrorView extends StatelessWidget {
  const KeepItErrorView({
    required this.e,
    required this.st,
    super.key,
    this.onRecover,
  });
  final Object e;
  final StackTrace st;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      topMenu: const TopBar(
        serverId: null,
        entity: null,
        children: null,
      ),
      banners: const [],
      bottomMenu: null,
      body: Center(
        child: GetStoreStatus(
          loadingBuilder: () => CLLoader.widget(debugMessage: null),
          errorBuilder: (activeConfigErr, activeConfigST) => CLErrorView(
            errorMessage: activeConfigErr.toString(),
          ),
          builder:
              ({
                required activeConfig,
                required isConnected,
                required store,
              }) {
                final storeError = !store.entityStore.isAlive
                    ? CLErrorView(
                        errorMessage:
                            '${activeConfig.displayName} is not accessible',
                      )
                    : CLErrorView(
                        errorMessage: e.toString(),
                      );

                return switch (activeConfig.isLocal) {
                  true => CLErrorView(
                    errorMessage: e.toString(),
                  ),
                  false =>
                    isConnected
                        ? storeError
                        : const CLErrorView(
                            errorMessage:
                                'Connection lost. Connect to your homenetwork to access this server',
                          ),
                };
              },
        ),
      ),
    );
  }
}
