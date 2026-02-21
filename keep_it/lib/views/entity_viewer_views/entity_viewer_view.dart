import 'dart:async';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_grid_view.dart';
import 'package:keep_it/views/entity_viewer_views/keep_it_page_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../common_widgets/keep_it_error_view.dart';
import '../common_widgets/keep_it_loading_view.dart';
import '../common_widgets/server_bar.dart';
import '../page_manager.dart';

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

  void _whenStoreError(
    BuildContext context,
    Object err,
    RegisteredServiceLocations locations,
    RegisteredServiceLocationsActions actions,
  ) {
    final storeURL = locations.activeConfig;
    final error = err.toString();
    if (error.contains('Server not connected') &&
        storeURL is RemoteServiceLocationConfig) {
      final messenger = ShadToaster.of(context);
      messenger.show(
        ShadToast.destructive(
          title: const Text('Connection Error'),
          description: Text(
            'Could not connect to ${storeURL.label}. Check your network.',
          ),
          action: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () {
                  actions.invalidateStore(storeURL);
                  unawaited(messenger.hide());
                },
                child: const Text('Retry'),
              ),
              if (locations.availableConfigs.isNotEmpty)
                ShadButton.secondary(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    actions.setActiveConfig(locations.availableConfigs[0]);
                    unawaited(messenger.hide());
                  },
                  child: const Text('Switch to Default'),
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    KeepItLoadingView loadBuilder() => KeepItLoadingView(
      serverId: widget.serverId,
      includeBottomBar: widget.id == null,
    );

    KeepItErrorView errorBuilder(Object e, StackTrace st) {
      return KeepItErrorView(
        error: e,
        serverId: widget.serverId,
        includeBottomBar: widget.id == null,
        actions: [
          ShadButton.outline(
            onPressed: () => PageManager.of(context).home(),
            child: const Text('Go Home'),
          ),
        ],
      );
    }

    return GetRegisteredServiceLocations(
      loadingBuilder: loadBuilder,
      errorBuilder: errorBuilder,
      builder: (registeredURLs, actions) {
        final activeConfig = registeredURLs.activeConfig;

        if (widget.id != null) {
          if (activeConfig.displayName != widget.serverId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PageManager.of(context).home();
            });
            return errorBuilder(
              Exception(
                "This page doesn't exists. Refresh. or Wait for Auto redirect",
              ),
              StackTrace.current,
            );
          }
        }

        KeepItErrorView contentErrorBuilder(Object e, StackTrace st) {
          return KeepItErrorView(
            error: e,
            serverId: widget.serverId,
            includeBottomBar: widget.id == null,
            actions: [
              ShadButton.outline(
                onPressed: () => actions.invalidateStore(activeConfig),
                child: const Text('Retry'),
              ),
              ShadButton.outline(
                onPressed: () => PageManager.of(context).home(),
                child: const Text('Go Home'),
              ),
            ],
          );
        }

        return OnStoreError(
          storeURL: activeConfig,
          onError: (context, error) =>
              _whenStoreError(context, error, registeredURLs, actions),
          child: GetContent(
            id: widget.id,
            errorBuilder: contentErrorBuilder,
            loadingBuilder: loadBuilder,
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
                      serverId: activeConfig.displayName,
                      parent: entity,
                      children: children,
                      onLoadMore: onLoadMoreChildren,
                      serverBarKey: _serverBarKey,
                    );
                  } else {
                    return KeepItPageView(
                      serverId: activeConfig.displayName,
                      entity: entity!,
                      siblings: siblings,
                      onLoadMore: onLoadMoreSiblings,
                      config: activeConfig is RemoteServiceLocationConfig
                          ? activeConfig
                          : null,
                    );
                  }
                },
          ),
        );
      },
    );
  }
}
