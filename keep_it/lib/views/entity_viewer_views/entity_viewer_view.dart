import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_grid_view.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_page_view.dart';

import '../page_manager.dart';
import 'top_bar.dart';

class EntitiesView extends StatelessWidget {
  const EntitiesView({
    required this.serverId,
    required this.id,
    super.key,
  });
  final String serverId;
  final int? id;

  @override
  Widget build(BuildContext context) {
    CLLoadingView loadBuilder() =>
        const CLLoadingView.custom(child: _LoadingView());

    return GetRegisteredServiceLocations(
      loadingBuilder: loadBuilder,
      errorBuilder: (e, st) => CLErrorView.custom(
        child: _ErrorView(e: e, st: st),
      ),
      builder: (registeredURLs, _) {
        if (id != null) {
          try {
            if (registeredURLs.activeConfig.displayName != serverId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                PageManager.of(context).home();
              });
              throw Exception(
                "This page doesn't exists. Refresh. or Wait for Auto redirect",
              );
            }
          } catch (e, st) {
            return CLErrorView.custom(
              child: _ErrorView(e: e, st: st),
            );
          }
        }
        return GetContent(
          id: id,
          loadingBuilder: loadBuilder,
          errorBuilder: (e, st) => CLErrorView.custom(
            child: _ErrorView(e: e, st: st),
          ),
          builder: (entity, children, siblings) {
            if (entity?.isCollection ?? true) {
              return KeepItGridView(
                serverId: registeredURLs.activeConfig.displayName,
                parent: entity,
                children: children,
              );
            } else {
              return KeepItPageView(
                serverId: registeredURLs.activeConfig.displayName,
                entity: entity!,
                siblings: siblings,
              );
            }
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      topMenu: const TopBar(
        serverId: null,
        entity: null,
        children: null,
      ),
      body: OnSwipe(
        onSwipe: () {
          if (PageManager.of(context).canPop()) {
            PageManager.of(context).pop();
          }
        },
        child: CLLoadingView.widget(debugMessage: null),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.e,
    required this.st,
  });
  final Object e;
  final StackTrace st;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      topMenu: const TopBar(
        serverId: null,
        entity: null,
        children: null,
      ),
      body: Center(
        child: GetStoreStatus(
          loadingBuilder: () => CLLoadingView.widget(debugMessage: null),
          errorBuilder: (activeConfigErr, activeConfigST) => CLErrorView.local(
            message: activeConfigErr.toString(),
          ),
          builder:
              ({
                required activeConfig,
                required isConnected,
                required store,
              }) {
                final storeError = !store.entityStore.isAlive
                    ? CLErrorView.local(
                        message:
                            '${activeConfig.displayName} is not accessible',
                      )
                    : CLErrorView.local(
                        message: e.toString(),
                      );

                return switch (activeConfig.isLocal) {
                  true => CLErrorView.local(
                    message: e.toString(),
                  ),
                  false =>
                    isConnected
                        ? storeError
                        : const CLErrorView.local(
                            message:
                                'Connection lost. Connect to your homenetwork to access this server',
                          ),
                };
              },
        ),
      ),
    );
  }
}
