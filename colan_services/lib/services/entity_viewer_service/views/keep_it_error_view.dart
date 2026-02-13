import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/cl_error_view.dart';
import 'top_bar.dart';

class KeepItErrorView extends ConsumerWidget {
  const KeepItErrorView(
      {required this.e, required this.st, super.key, this.onRecover});
  final Object e;
  final StackTrace st;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLScaffold(
      topMenu: TopBar(
          serverId: null, entityAsync: AsyncError(e, st), children: null),
      banners: const [],
      bottomMenu: null,
      body: Center(
        child: GetStoreStatus(
          builder: (
              {required activeConfig,
              required isConnected,
              required storeAsync}) {
            return activeConfig.when(
                data: (activeConfigValue) {
                  final storeError = storeAsync.when(
                      data: (store) {
                        if (!store.entityStore.isAlive) {
                          return CLErrorView(
                            errorMessage:
                                '${activeConfigValue.displayName} is not accesseble',
                          );
                        } else {
                          return CLErrorView(
                            errorMessage: e.toString(),
                          );
                        }
                      },
                      error: (storeError, storeSt) {
                        return const CLErrorView(
                          errorMessage: 'Store is not accessible',
                        );
                      },
                      loading: () => CLLoader.widget(debugMessage: null));
                  return switch (activeConfigValue.isLocal) {
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
                error: (activeConfigErr, activeConfigST) {
                  return CLErrorView(
                    errorMessage: activeConfigErr.toString(),
                  );
                },
                loading: () => CLLoader.widget(debugMessage: null));
          },
        ),
      ),
    );
  }
}
