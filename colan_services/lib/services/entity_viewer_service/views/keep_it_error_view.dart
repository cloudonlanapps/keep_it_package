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
              {required activeURL,
              required isConnected,
              required storeAsync}) {
            return activeURL.when(
                data: (activeURLValue) {
                  final storeError = storeAsync.when(
                      data: (store) {
                        if (!store.store.isAlive) {
                          return CLErrorView(
                            errorMessage:
                                '${activeURLValue.name} is not accesseble',
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
                  return switch (activeURLValue.scheme) {
                    'local' => CLErrorView(
                        errorMessage: e.toString(),
                      ),
                    (final String scheme)
                        when ['http', 'https'].contains(scheme) =>
                      isConnected
                          ? storeError
                          : const CLErrorView(
                              errorMessage:
                                  'Connection lost. Connect to your homenetwork to access this server',
                            ),
                    _ =>
                      throw Exception('Unsupported URL') // should never occur
                  };
                },
                error: (activeURLErr, activeURLST) {
                  return CLErrorView(
                    errorMessage: activeURLErr.toString(),
                  );
                },
                loading: () => CLLoader.widget(debugMessage: null));
          },
        ),
      ),
    );
  }
}
