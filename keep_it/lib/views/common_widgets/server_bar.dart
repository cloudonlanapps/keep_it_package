import 'dart:async';

import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../page_manager.dart';

class ServerBar extends StatefulWidget {
  const ServerBar({super.key});
  @override
  State<ServerBar> createState() => ServerBarState();
}

class ServerBarState extends State<ServerBar> {
  bool showText = false;
  Timer? _timer;
  Timer? _inactivityTimer;
  double _popoverOpacity = 1;
  final popoverController = ShadPopoverController();

  void _onPopoverChanged() {
    if (popoverController.isOpen) {
      _stopTimer();
      _resetInactivityTimer();
      setState(() {
        showText = true;
        _popoverOpacity = 1.0;
      });
    } else {
      _stopInactivityTimer();
      if (showText) {
        _setHideTimer();
      }
    }
  }

  void _closeManual() {
    _timer?.cancel();
    _stopInactivityTimer();
    popoverController.hide();
    setState(() => showText = false);
  }

  void _resetInactivityTimer() {
    _stopInactivityTimer();
    setState(() => _popoverOpacity = 1.0);
    _inactivityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _popoverOpacity = 0.0);
        Timer(const Duration(milliseconds: 500), () {
          if (mounted && _popoverOpacity == 0.0) {
            _closeManual();
          }
        });
      }
    });
  }

  void _stopInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void _setHideTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showText = false);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    popoverController.addListener(_onPopoverChanged);
  }

  @override
  void dispose() {
    popoverController
      ..removeListener(_onPopoverChanged)
      ..dispose();
    _timer?.cancel();
    _stopInactivityTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadPopover(
      controller: popoverController,
      anchor: const ShadAnchor(
        childAlignment: Alignment.bottomLeft,
        overlayAlignment: Alignment.topLeft,
        offset: Offset(16, -16),
      ),
      popover: (context) => GetActiveStore(
        errorBuilder: (e, st) => CLErrorView.hidden(debugMessage: e.toString()),
        loadingBuilder: () =>
            const CLLoadingView.hidden(debugMessage: 'ServerBar'),
        builder: (activeServer) {
          final config = activeServer.entityStore.config;
          return AnimatedOpacity(
            opacity: _popoverOpacity,
            duration: const Duration(milliseconds: 500),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _resetInactivityTimer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Active Server Info & Auth
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: (config is RemoteServiceLocationConfig)
                            ? GetAuthStatus(
                                config: config,
                                loadingBuilder: () => CLLoadingView.custom(
                                  child: ListTile(
                                    title: Text(
                                      activeServer.label,
                                      style: theme.textTheme.large,
                                    ),
                                    subtitle: const Text('Checking auth...'),
                                  ),
                                ),
                                errorBuilder: (e, st, actions) =>
                                    CLErrorView.custom(
                                      child: ListTile(
                                        title: Text(
                                          activeServer.label,
                                          style: theme.textTheme.large,
                                        ),
                                        subtitle: const Text('Auth Error'),
                                      ),
                                    ),
                                builder: (authStatus, actions) => ListTile(
                                  title: Text(
                                    activeServer.label,
                                    style: theme.textTheme.large,
                                  ),
                                  subtitle: Text(
                                    authStatus.isAuthenticated
                                        ? (authStatus.username ?? 'User')
                                        : 'Not Authenticated',
                                  ),
                                  trailing: authStatus.isAuthenticated
                                      ? ShadButton.secondary(
                                          size: ShadButtonSize.sm,
                                          onPressed: () {
                                            _resetInactivityTimer();
                                            unawaited(actions.logout());
                                          },
                                          child: const Text('Logout'),
                                        )
                                      : ShadButton.outline(
                                          size: ShadButtonSize.sm,
                                          onPressed: () {
                                            _resetInactivityTimer();
                                            unawaited(
                                              PageManager.of(
                                                context,
                                              ).openAuthenticator(),
                                            );
                                          },
                                          child: const Text('Login'),
                                        ),
                                ),
                              )
                            : ListTile(
                                title: Text(
                                  activeServer.label,
                                  style: theme.textTheme.large,
                                ),
                                subtitle: Text(config.displayName),
                              ),
                      ),
                      const Divider(),

                      // Server Switching Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          'Switch Server',
                          style: theme.textTheme.muted.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: GetRegisteredServiceLocations(
                          errorBuilder: (e, st) => CLErrorView.local(
                            message: 'Error loading servers',
                            details: e.toString(),
                          ),
                          loadingBuilder: () => const CLLoadingView.local(
                            debugMessage: 'Loading servers...',
                          ),
                          builder: (locations, actions) {
                            final available = locations.availableConfigs;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: available.length,
                              itemBuilder: (context, index) {
                                final loc = available[index];
                                final isActive = locations.isActiveConfig(loc);
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isActive
                                        ? LucideIcons.circleCheck
                                        : LucideIcons.circle,
                                    size: 16,
                                    color: isActive ? Colors.green : null,
                                  ),
                                  title: Text(loc.label ?? loc.displayName),
                                  selected: isActive,
                                  onTap: isActive
                                      ? null
                                      : () {
                                          _resetInactivityTimer();
                                          actions.setActiveConfig(loc);
                                        },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: _closeManual,
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      child: GetActiveStore(
        errorBuilder: (e, st) => CLErrorView.hidden(debugMessage: e.toString()),
        loadingBuilder: () =>
            const CLLoadingView.hidden(debugMessage: 'ServerBar'),
        builder: (activeServer) {
          return ShadBadge(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            onPressed: popoverController.toggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                ShadAvatar(
                  (activeServer.entityStore.isLocal)
                      ? 'assets/icon/not_on_server.png'
                      : 'assets/icon/cloud_on_lan_128px_color.png',
                  size: const Size.fromRadius(
                    (kMinInteractiveDimension / 2) - 6,
                  ),
                ),
                if (showText)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(activeServer.label),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
