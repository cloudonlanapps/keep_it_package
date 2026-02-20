import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_grid_view.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_page_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../auth_views/logged_out_view.dart';
import '../common_widgets/server_bar.dart';
import '../page_manager.dart';
import 'bottom_bar_grid_view.dart';
import 'top_bar.dart';

class EntitiesView extends StatefulWidget {
  const EntitiesView({
    required this.serverId,
    required this.id,
    super.key,
  });
  final String serverId;
  final int? id;

  @override
  State<EntitiesView> createState() => _EntitiesViewState();
}

class _EntitiesViewState extends State<EntitiesView> {
  final _serverBarKey = GlobalKey<ServerBarState>();

  @override
  Widget build(BuildContext context) {
    CLLoadingView loadBuilder() => CLLoadingView.page(
      topBar: TopBar(
        entity: null,
        children: null,
      ),
      bottomMenu: BottomBarGridView(
        serverId: widget.serverId,
        entity: null,
        serverBarKey: _serverBarKey,
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

                CLErrorView errorPage() => CLErrorView.page(
                  message: message,
                  topBar: TopBar(
                    entity: null,
                    children: null,
                  ),
                  bottomMenu: BottomBarGridView(
                    serverId: activeConfig.displayName,
                    entity: null,
                    serverBarKey: _serverBarKey,
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

                if (activeConfig is RemoteServiceLocationConfig) {
                  // For remote stores, we prefer showing the login widget if the user is unauthenticated,
                  // as most errors in this phase are likely due to lack of credentials.
                  return CLErrorView.custom(
                    child: GetAuthStatus(
                      config: activeConfig,
                      builder: (authStatus, actions) {
                        if (!authStatus.isAuthenticated) {
                          // State-based switch: show login directly instead of the error page.
                          return CLScaffold(
                            topMenu: TopBar(
                              entity: null,
                              children: null,
                            ),
                            bottomMenu: BottomBarGridView(
                              serverId: activeConfig.displayName,
                              entity: null,
                              serverBarKey: _serverBarKey,
                            ),
                            body: LoggedOutView(
                              config: activeConfig,
                              onLogin: actions.login,
                            ),
                          );
                        }
                        // If authenticated, we show the original error message (e.g. server error, 404).
                        return errorPage();
                      },
                      loadingBuilder: () =>
                          CLLoadingView.widget(debugMessage: 'Checking auth'),
                      // If GetAuthStatus itself fails (e.g. server unreachable), fallback to the original error page.
                      errorBuilder: (e, st, actions) => errorPage(),
                    ),
                  );
                }

                return errorPage();
              },
        ),
      );
    }

    return GetRegisteredServiceLocations(
      loadingBuilder: loadBuilder,
      errorBuilder: errorBuilder,
      builder: (registeredURLs, _) {
        if (widget.id != null) {
          try {
            if (registeredURLs.activeConfig.displayName != widget.serverId) {
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
          id: widget.id,
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
                    serverBarKey: _serverBarKey,
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
