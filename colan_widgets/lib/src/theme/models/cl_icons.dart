import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/cl_scale_type.dart';

extension IconOnIconData on IconData {
  Widget iconFormatted({
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
    bool? applyTextScaling,
  }) {
    return Icon(
      this,
      size: size ?? 25,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      shadows: shadows,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

class CameraIcons {}

class MediaEditorIcons {}

class MediaViewerIcons {}

class PageNavigateIcons {}

class NodeNavigateIcons {}

@immutable
class SyncIcons {
  final IconData disconnectIconData = MdiIcons.lanDisconnect;
  final IconData connectIconData = MdiIcons.lanDisconnect;
  final IconData syncIconData = MdiIcons.syncCircle;
  final IconData attachIconData = MdiIcons.plusCircle;
  final IconData detachIconData = MdiIcons.minusCircle;
  final IconData syncOptionsIconData = Symbols.format_list_bulleted_add;

  final Widget inSync = Center(
    child: Symbols.cloud_done_sharp.iconFormatted(
      size: CLScaleType.veryLarge.iconSize,
      weight: 700,
      grade: 100,
      color: const Color.fromARGB(
        0xFF,
        0x00,
        0xFF,
        0xEC,
      ),
    ),
  );
}

@immutable
class CLIcons {
  final SyncIcons syncIcons = SyncIcons();
  final IconData placeHolder = Icons.device_unknown_outlined;
  final IconData filter = Symbols.filter_list_sharp;
  final IconData camera = LucideIcons.camera;
  final IconData microphone = MdiIcons.microphone;
  final IconData location = MdiIcons.mapMarker;
  final IconData imageCapture = MdiIcons.camera;
  final IconData videoRecordingStart = MdiIcons.video;
  final IconData videoRecordingPause = MdiIcons.pause;
  final IconData videoRecordingResume = MdiIcons.circle;
  final IconData videoRecordingStop = Icons.stop;
  final IconData flashModeOff = Icons.flash_off;
  final IconData flashModeAuto = Icons.flash_auto;
  final IconData flashModeAlways = Icons.flash_on;
  final IconData flashModeTorch = Icons.highlight;
  final IconData recordingAudioOn = MdiIcons.volumeHigh;
  final IconData recordingAudioOff = MdiIcons.volumeMute;
  final IconData switchCamera = Icons.cameraswitch;
  final IconData exitCamera = MdiIcons.arrowLeft;
  final IconData invokeCamera = MdiIcons.camera;
  final IconData popMenuAnchor = MdiIcons.dotsVertical;
  final IconData popMenuSelectedItem = MdiIcons.checkCircle;
  final IconData pagePop = MdiIcons.arrowLeft;
  final IconData navigateHome = MdiIcons.home;
  final IconData serversList = MdiIcons.accessPointNetwork;
  final IconData noNetwork = MdiIcons.accessPointNetworkOff;
  final IconData connectToServer = MdiIcons.accessPointNetwork;
  final IconData disconnectToServer = MdiIcons.accessPointNetworkOff;
  final IconData searchForServers = MdiIcons.rotate3DVariant;
  final IconData openNotes = MdiIcons.notebookEdit;
  final IconData closeNotes = MdiIcons.notebookCheck;
  final IconData closeFullscreen = MdiIcons.close;
  final IconData imageCrop = LucideIcons.crop;
  final IconData imageEdit = LucideIcons.pencil;
  final IconData imageMove = LucideIcons.folderInput;
  final IconData imageMoveAll = LucideIcons.folderInput;
  final IconData imageShare = LucideIcons.share2;
  final IconData imageShareAll = LucideIcons.share2;

  final IconData pin = LucideIcons.pin;
  final IconData unPin = LucideIcons.pinOff;
  final IconData pinned = LucideIcons.pin;
  final IconData notPinned = LucideIcons.pinOff;
  final IconData brokenPin = LucideIcons.pinOff;
  final IconData editCollectionLabel = MdiIcons.pencil;
  final IconData next = MdiIcons.arrowRight;
  final IconData deleteNote = MdiIcons.delete;
  final IconData undoNote = MdiIcons.undoVariant;
  final IconData save = MdiIcons.contentSave;
  final IconData discardChangeNote = MdiIcons.close;
  final IconData hideKeyboard = MdiIcons.keyboardClose;
  final IconData navigatePinPage = MdiIcons.pin;
  final IconData navigateSettings = MdiIcons.cog;
  final IconData gotoPage = MdiIcons.arrowRight;
  final IconData recycleBin = MdiIcons.delete;
  final IconData doneEditMedia = MdiIcons.check;
  final IconData imageEditRotateRight = MdiIcons.rotateRight;
  final IconData imageEditRotateLeft = MdiIcons.rotateLeft;
  final IconData imageEditFlipHirizontal = MdiIcons.flipHorizontal;
  final IconData imageEditFlipVertical = MdiIcons.flipVertical;
  final IconData imageDelete = Icons.delete_rounded;
  final IconData audioMuted = MdiIcons.volumeOff;
  final IconData audioUnmuted = MdiIcons.volumeHigh;
  final IconData itemSelected = LucideIcons.squareCheckBig;
  final IconData itemSelected2 = LucideIcons.check;
  final IconData itemNotSelected = Icons.square_outlined;
  final IconData itemPartiallySelected = Icons.indeterminate_check_box_outlined;

  final IconData error = Icons.warning;
  final IconData insertItem = Icons.add;
  final IconData deleteItem = Icons.delete;
  final IconData down = Icons.arrow_circle_down;
  final IconData up = Icons.arrow_circle_up;
  final IconData brokenImage = Icons.broken_image_outlined;
  final IconData playerPause = Icons.pause;
  final IconData playerPlay = Icons.play_arrow;
  final IconData playerStop = Icons.stop;
  final IconData mediaOrientation = Icons.image;

  final IconData extraMenu = LucideIcons.menu;
  final IconData cameraSettings = Icons.settings;
  final IconData collectionsSelect = Symbols.list_alt;
  final IconData searchRequest = Symbols.search;
  final IconData searchOpened = Symbols.search_check_2;
  final IconData selected = LucideIcons.squareCheck;
  final IconData deselected = LucideIcons.square;
  final IconData settings = LucideIcons.settings2;
  final IconData darkMode = LucideIcons.moon;
  final IconData lightMode = LucideIcons.sun;
  final IconData textClear = LucideIcons.x;
}

CLIcons clIcons = CLIcons();
