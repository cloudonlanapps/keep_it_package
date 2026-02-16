import 'package:flutter/material.dart';

import 'package:store/store.dart';
import '../../../store_tasks_service/store_tasks_service.dart';

import '../../camera_service/camera_service.dart';
import '../../camera_service/models/default_theme.dart';

abstract class NavigatorAPI {
  void home(BuildContext context);
  void pop<T extends Object?>(BuildContext context, [T? result]);
  bool canPop(BuildContext context);
  void closeDialog<T extends Object?>(BuildContext context, [T? result]);
  Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName,
  );
}

class NavigatorAPIImpl extends Navigator implements NavigatorAPI {
  const NavigatorAPIImpl({super.key});

  @override
  void home(BuildContext context) {
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  @override
  void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  @override
  void closeDialog<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  @override
  Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName,
  ) async {
    return Navigator.pushNamed(context, routeName);
  }
}

class PageManager {
  const PageManager(
    this.context, {
    this.navigator = const NavigatorAPIImpl(),
  });
  factory PageManager.of(BuildContext context) {
    return PageManager(context);
  }
  final NavigatorAPI navigator;
  final BuildContext context;

  void home() {
    navigator.home(context);
  }

  void pop<T extends Object?>([T? result]) {
    if (context.mounted && navigator.canPop(context)) {
      navigator.pop(context, result);
    }
  }

  bool canPop() {
    return navigator.canPop(context);
  }

  void closeDialog<T extends Object?>([T? result]) {
    navigator.pop(context, result);
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName,
  ) async {
    return navigator.pushNamed(context, routeName);
  }

  Future<bool?> openCamera({
    required String serverId,
    int? parentId,
  }) async {
    await CLCameraService0.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          final queryMap = [
            'serverId=$serverId',
            if (parentId != null) 'parentId=$parentId',
          ];
          final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';
          await navigator.pushNamed(context, '/camera$query');
        }
      },
      themeData: DefaultCLCameraIcons(),
    );
    return null;
  }

  Future<StoreEntity?> openEditor(
    StoreEntity media, {
    required String serverId,
    bool canDuplicateMedia = true,
  }) async {
    if (media.pin != null) {
      return media;
    } else {
      final queryMap = [
        'serverId=$serverId',
        'id=${media.id}',
        'canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
      ];
      final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';

      final edittedMedia = await navigator.pushNamed(context, '/edit$query');
      if (edittedMedia is StoreEntity?) {
        return edittedMedia ?? media;
      } else {
        throw Exception(UnsupportedError);
      }
    }
  }

  Future<void> openEntity(
    StoreEntity? entity, {
    required String serverId,
  }) async {
    final queryMap = [
      'serverId=$serverId',
      if (entity != null) 'id=${entity.id}',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';
    await navigator.pushNamed(context, '/media$query');
  }

  Future<void> openWizard(ContentOrigin type) async {
    final queryMap = [
      'type=${type.name}',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';
    await navigator.pushNamed(context, '/wizard$query');
  }

  Future<void> openSettings() async {
    await navigator.pushNamed(context, '/settings');
  }
  Future<void> openAuthenticator() async {
    await navigator.pushNamed(context, '/auth');
  }
}
