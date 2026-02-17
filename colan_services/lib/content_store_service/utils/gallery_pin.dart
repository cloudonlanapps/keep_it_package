import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class AlbumManager {
  AlbumManager({
    required this.albumName,
  });
  String albumName;

  Future<bool> isPinBroken(String? pin) async {
    if (pin != null) {
      final asset = await AssetEntity.fromId(pin);
      return asset == null;
    }
    return false;
  }

  static Future<bool> checkRequest() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.addOnly,
      ),
    );
    return state.isAuth;
  }

  Future<AssetPathEntity?> retriveAlbum() async {
    AssetPathEntity? targetAlbum;
    final assetPathList = await PhotoManager.getAssetPathList();
    try {
      targetAlbum = assetPathList.firstWhere((path) => path.name == albumName);
    } catch (e) {
      try {
        targetAlbum = await PhotoManager.editor.darwin.createAlbum(albumName);
      } catch (e) {
        /** */
      }
    }
    return targetAlbum;
  }

  Future<String?> addMedia(
    String filePath, {
    required String title,
    required bool isImage,
    required bool isVideo,
    String? desc,
  }) async {
    final auth = await checkRequest();
    if (!auth) return null;

    final AssetEntity? assetEntity;
    if (isImage) {
      assetEntity = await PhotoManager.editor.saveImageWithPath(
        filePath,
        title: title,
        desc: desc,
      );
    } else if (isVideo) {
      assetEntity =
          await PhotoManager.editor.saveVideo(File(filePath), title: title);
    } else {
      assetEntity = null;
    }

    if (assetEntity == null) return null;

    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final album = await retriveAlbum();
        if (album != null) {
          await PhotoManager.editor
              .copyAssetToPath(asset: assetEntity, pathEntity: album);
        }
      } catch (e) {
        /** */
      }
    }
    return assetEntity.id;
  }

  Future<bool> removeMedia(String id) async {
    final auth = await checkRequest();
    if (!auth) return false;
    try {
      final asset = await AssetEntity.fromId(id);

      /// IF asset not found, it is already deleted.
      if (asset == null) return true;
      final res = await PhotoManager.editor.deleteWithIds([id]);
      return res.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMultipleMedia(List<String> ids) async {
    final auth = await checkRequest();
    if (!auth) return false;
    try {
      final res = await PhotoManager.editor.deleteWithIds(ids);
      return res.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
