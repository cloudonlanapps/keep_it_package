import 'package:face_it_desktop/models/bbox.dart';
import 'package:face_it_desktop/models/landmarks.dart';
import 'package:flutter/material.dart';

@immutable
class Face {
  const Face(this.bbox, this.landmarks);

  final BBox bbox;
  final FaceLandmarks? landmarks;
}
