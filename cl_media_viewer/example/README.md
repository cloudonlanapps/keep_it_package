# Interactive Image Viewer Example

This example app demonstrates the `cl_media_viewer` package with interactive face overlays.

## Available Images

The example includes 16 images with face detection data:
- `2.jpg` through `12.jpg` - Various photos with multiple faces
- `13.png` through `17.png` - Portrait images (150x150)

## File Structure

Each image has a corresponding JSON file in `assets/faces/` with the same name + `.json`:
```
assets/
├── images/
│   ├── 2.jpg
│   ├── 3.jpg
│   └── ...
└── faces/
    ├── 2.jpg.json
    ├── 3.jpg.json
    └── ...
```

## JSON Format
```json
{
  "name": "Image description",
  "width": 1920,
  "height": 1080,
  "faces": [
    {
      "id": 1,
      "bbox": {
        "x1": 0.15,
        "y1": 0.2,
        "x2": 0.35,
        "y2": 0.6
      },
      "confidence": 0.95,
      "landmarks": {
        "leftEye": [0.21, 0.32],
        "rightEye": [0.29, 0.32],
        "noseTip": [0.25, 0.42],
        "mouthLeft": [0.20, 0.52],
        "mouthRight": [0.30, 0.52]
      },
      "knownPersonId": null
    }
  ]
}
```

**Note**: All coordinates are normalized (0.0 - 1.0) relative to image dimensions.

## Running

```bash
cd example
flutter pub get
flutter run
```

## Features Demonstrated

1. **Image List** - Browse available images
2. **Face Overlays** - Tap to select, see face numbers
3. **Zoom/Pan** - Pinch to zoom, drag to pan (faces track with image)
4. **Keyboard Shortcuts** - Press 1-9 to select faces
5. **Context Menu** - Right-click (or long-press on mobile) for options
6. **Face Details** - Long-press to view face information
7. **Landmarks** - Select a face to show facial landmarks
