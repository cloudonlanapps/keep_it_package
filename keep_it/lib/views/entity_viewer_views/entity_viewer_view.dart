import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_grid_view.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_page_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    CLLoadingView loadBuilder() => CLLoadingView.page(
      topBar: TopBar(
        serverId: null,
        entity: null,
        children: null,
      ),
      onSwipe: () {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      },
    );

    CLErrorView errorBuilder(Object e, StackTrace st) {
      return CLErrorView.custom(
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
                    ? '${activeConfig.displayName} is not accessible'
                    : e.toString();

                final message = switch (activeConfig.isLocal) {
                  true => e.toString(),
                  false =>
                    isConnected
                        ? storeError
                        : 'Connection lost. Connect to your homenetwork to access this server',
                };

                return CLErrorView.page(
                  message: message,
                  topBar: TopBar(
                    serverId: activeConfig.displayName,
                    entity: null,
                    children: null,
                  ),
                  actions: [
                    ShadButton.outline(
                      onPressed: () => PageManager.of(context).home(),
                      child: const Text('Go Home'),
                    ),
                  ],
                  onSwipe: () {
                    if (PageManager.of(context).canPop()) {
                      PageManager.of(context).pop();
                    }
                  },
                );
              },
        ),
      );
    }

    return GetRegisteredServiceLocations(
      loadingBuilder: loadBuilder,
      errorBuilder: errorBuilder,
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
            return errorBuilder(e, st);
          }
        }
        return GetContent(
          id: id,
          loadingBuilder: loadBuilder,
          errorBuilder: errorBuilder,
          builder:
              (
                entity,
                children,
                siblings, {
                onLoadMoreChildren,
                onLoadMoreSiblings,
              }) {
                if (entity?.isCollection ?? true) {
                  return KeepItGridView(
                    serverId: registeredURLs.activeConfig.displayName,
                    parent: entity,
                    children: children,
                    onLoadMore: onLoadMoreChildren,
                  );
                } else {
                  return KeepItPageView(
                    serverId: registeredURLs.activeConfig.displayName,
                    entity: entity!,
                    siblings: siblings,
                    onLoadMore: onLoadMoreSiblings,
                  );
                }
              },
        );
      },
    );
  }
}
