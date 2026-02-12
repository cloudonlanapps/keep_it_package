import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

class KeepItApp implements AppDescriptor {
  @override
  String get title => 'Keep It';

  @override
  CLAppInitializer get appInitializer => (ref) async {
        return true;
      };

  @override
  List<CLRouteDescriptor> get screens => [
        CLRouteDescriptor(
          name: '',
          builder: (context, parameters) {
            final String serverId;
            if (parameters.keys.contains('serverId')) {
              serverId = parameters['serverId']!;
            } else {
              serverId = 'default';
            }

            return EntityViewerService(
              serverId: serverId,
              id: null,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'media',
          builder: (context, parameters) {
            final int? mediaId;

            if (parameters.keys.contains('id')) {
              mediaId = int.parse(parameters['id']!);
            } else {
              mediaId = null;
            }
            final String serverId;
            if (parameters.keys.contains('serverId')) {
              serverId = parameters['serverId']!;
            } else {
              throw Exception('serverId must be present');
            }

            return EntityViewerService(
              serverId: serverId,
              id: mediaId,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'settings',
          builder: (context, parameters) {
            return const SettingsService();
          },
        ),
        CLRouteDescriptor(
          name: 'camera',
          builder: (context, parameters) {
            final int? parentId;
            if (parameters.keys.contains('parentId')) {
              parentId = int.parse(parameters['parentId']!);
            } else {
              parentId = null;
            }
            final String serverId;
            if (parameters.keys.contains('serverId')) {
              serverId = parameters['serverId']!;
            } else {
              throw Exception('serverId must be present');
            }
            return CameraService(
              serverId: serverId,
              parentId: parentId,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'edit',
          builder: (context, parameters) {
            final int? mediaId;
            final bool canDuplicateMedia;
            if (parameters.keys.contains('id')) {
              mediaId = int.parse(parameters['id']!);
            } else {
              mediaId = null;
            }
            if (parameters.keys.contains('canDuplicateMedia')) {
              canDuplicateMedia = parameters['canDuplicateMedia']! == '1';
            } else {
              canDuplicateMedia = false;
            }
            final String serverId;
            if (parameters.keys.contains('serverId')) {
              serverId = parameters['serverId']!;
            } else {
              throw Exception('serverId must be present');
            }

            return MediaEditService(
              serverId: serverId,
              mediaId: mediaId,
              canDuplicateMedia: canDuplicateMedia,
            );
          },
        ),
        CLRouteDescriptor(
          name: 'wizard',
          builder: (context, parameters) {
            final String type;
            if (parameters.keys.contains('type')) {
              type = parameters['type']!;
            } else {
              throw Exception('serverId must be present');
            }

            return MediaWizardService(type: type);
          },
        ),
        CLRouteDescriptor(
          name: 'auth',
          builder: (context, parameters) {
            return const AuthService();
          },
        ),
      ];

  @override
  CLTransitionBuilder get transitionBuilder => (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const scheme = 'fade';
        switch (scheme) {
          case 'slide':
            return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(animation),
              child: child,
            );
          case 'scale':
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          case 'size':
            return Align(
              child: SizeTransition(
                sizeFactor: animation,
                child: child,
              ),
            );
          case 'rotation':
            return RotationTransition(
              turns: animation,
              child: child,
            );
          case 'fade':
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      };

  @override
  CLRedirector get redirector => (String location) async {
        const redirectTo = '';

        if (redirectTo.isNotEmpty) {
          if (location != redirectTo) return redirectTo;
        }

        return null;
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowFrame(const Rect.fromLTWH(0, 0, 900, 900 * 16 / 9));

    setWindowMaxSize(const Size(900, 900 * 16 / 9));
    setWindowMinSize(const Size(450, 450 * 16 / 9));
  }

  runApp(AppStartService(appDescriptor: KeepItApp()));
}
