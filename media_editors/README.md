# media_editors

A comprehensive Flutter package for on-device image and video editing. It provides high-level widgets for cropping, rotating, and flipping images, as well as trimming videos with integrated audio management.

> **For Developers:** See [INTERNALS.md](INTERNALS.md) for package structure, development workflow, and internal architecture.

## Features

- 🖼️ **Advanced Image Editing**: Integrated zooming, cropping, rotation, and flipping using `extended_image`.
- ✂️ **Video Trimming**: Frame-accurate video trimming with timeline visualization.
- 🔊 **Audio Management**: Built-in support for muting/unmuting video audio during the edit process.
- 💾 **Smart Finalization**: Unified save flow handling "Save" vs "Save Copy" (Save as New) scenarios.
- 🎨 **Design System Alignment**: Built using `shadcn_ui` and `colan_widgets` for a consistent look and feel.

## Quick Start

### Prerequisites

- Flutter SDK ^3.9.2
- Core dependencies (see `pubspec.yaml`):
  - `colan_widgets` (Local package)
  - `extended_image`
  - `video_trimmer`
  - `shadcn_ui`

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  media_editors:
    path: apps/ui_flutter/media_editors
```

Then run:
```bash
flutter pub get
```

## Usage

### Image Editor

To integrate the image editor, use the `ImageEditor` widget. It requires source URI and callbacks for saving.

```dart
ImageEditor(
  uri: imageUri,
  canDuplicateMedia: true,
  onSave: (path, {required overwrite}) async {
    // Handle the saved file path
  },
  onCreateNewFile: () async {
    // Return a path for the new file if creating a copy
    return '/path/to/new_file.jpg';
  },
  onCancel: () async {
    // Handle cancellation
  },
)
```

### Video Trimmer

For video editing, use the `VideoTrimmerView` widget.

```dart
VideoTrimmerView(
  videoFile,
  canDuplicateMedia: true,
  isMuted: isMuted,
  audioMuter: MyAudioMuterWidget(), // Custom widget to toggle audio
  onSave: (outputPath, {required overwrite}) async {
    // Handle the trimmed video path
  },
  onReset: () {
    // Handle resetting the trimmer state
  },
  onCancel: () async {
    // Handle cancellation
  },
)
```

## Documentation

- **[Example Application](./example)** - A reference implementation showing the "Safe Save" flow (auto-reloading on save, sharing on copy).
- **[INTERNALS.md](./INTERNALS.md)** - Developer documentation, architecture, and recommendations.
- **[colan_widgets](../colan_widgets/README.md)** - Design system and shared widget documentation.

## License

MIT License - see [LICENSE](./LICENSE) file for details.
