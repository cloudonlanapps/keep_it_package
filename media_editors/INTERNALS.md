# media_editors - Internal Documentation

This document contains development-related information for contributors working on the `media_editors` package.

## Package Structure

```
media_editors/
├── lib/
│   ├── src/
│   │   ├── image/             # Image editing components
│   │   │   ├── models/        # Image processing & aspect ratio models
│   │   │   ├── views/         # UI views for image editing
│   │   │   └── image_editor.dart
│   │   ├── video/             # Video editing components
│   │   │   ├── widgets/       # Trimming & playback controls
│   │   │   └── video_edit_service.dart
│   │   ├── editor_finalizer.dart # Shared save/discard logic
│   │   └── media_editor.dart  # Top-level dispatcher
│   └── media_editors.dart     # Public API exports
├── pubspec.yaml               # Flutter package configuration
├── README.md                  # User documentation
└── INTERNALS.md               # This file
```

**Key Design Decisions:**
- **Third-Party Integration**: Uses `extended_image` for robust image zooming/cropping and `video_trimmer` for frame-accurate video slicing.
- **Design System**: Built on top of `shadcn_ui` for modern, accessible UI components and `colan_widgets` for project-specific styling.
- **Shared Finalization**: Uses `EditorFinalizer` to unify the saving flow (Save vs Save Copy) across different media types.
- **Non-destructive Previewing**: Edits are stored using local state variables (e.g., `rotateAngle`, `startValue`) and only applied to the file system upon final "Save".

## Development

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Quality

```bash
# Format code
flutter format .

# Analyze code (Linting)
flutter analyze
```

### Development Workflow

1. **Modify Code**: Make changes in `lib/src/`.
2. **Verify Layout**: Ensure UI changes respond correctly to different screen sizes and media orientations.
3. **Run Tests**: Ensure no regressions in image processing or state management.
4. **Finalize API**: If adding new editor types, export them in `lib/media_editors.dart`.

## Architecture

### Image Editor Flow
The Image Editor uses a `Stack` to overlay manipulation controls (rotate, flip) directly on the image preview. It utilizes `ExtendedImageEditor` for high-performance canvas operations.

### Video Trimmer Flow
The Video Editor manages a `video_player` controller via the `Trimmer` class. It separates the timeline (trimmer) from playback controls to ensure the user has precise control over the selection.

### Shared Logic (`EditorFinalizer`)
`EditorFinalizer` is a wrapper widget that detects if any edit actions have been performed. It provides a consistent "Done" or "Close" button that triggers a `PopupMenuButton` for saving options.

## Future Enhancements (Recommendations)

### UI/UX Refinement
- **Unified Action Bar**: Standardize the bottom control bar across video and image editors.
- **Icon Visibility**: Improve contrast for buttons overlaid on media (using semi-transparent backgrounds).
- **Standardized Iconography**: Align icon sizes (reduce from 80px to 24-32px) to match the broader design system.

### Technical Improvements
- **Fixed State Restoration**: Refactor `restoreState` in `image_editor.dart` to apply rotations instantly rather than via an animated loop.
- **Syntax Cleanup**: Address invalid Dart syntax in `crop_control.dart` (conditional `saveWidget` rendering).
- **Theming**: Replace hardcoded colors (like `Colors.red` for progress indicators) with `ShadTheme` variables.

## Contributing

When contributing to this package:
1. Maintain consistency with the `shadcn_ui` design language.
2. Ensure `EditorFinalizer` is used for all media-saving interactions.
3. Update `lib/media_editors.dart` when adding new functionalities.
