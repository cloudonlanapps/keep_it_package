import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum ActivityStatus { premature, ready, pending, processingNow, success, error }

@immutable
class ImageFaceMapper {
  const ImageFaceMapper({
    required this.image,
    this.isProcessing = 0,
    this.sessionIdentity,
    this.faceIds,
    this.error,
  });
  final String image;
  final String? sessionIdentity;
  final List<String>? faceIds;
  final String? error;
  final int isProcessing;

  ImageFaceMapper copyWith({
    String? source,
    ValueGetter<String?>? sessionIdentity,
    ValueGetter<List<String>?>? faceIds,
    ValueGetter<String?>? error,
    int? isProcessing,
  }) {
    return ImageFaceMapper(
      image: source ?? image,
      sessionIdentity: sessionIdentity != null
          ? sessionIdentity.call()
          : this.sessionIdentity,
      faceIds: faceIds != null ? faceIds.call() : this.faceIds,
      error: error != null ? error.call() : this.error,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  String toString() {
    return 'FacesInImage(source: $image, sessionIdentity: $sessionIdentity, faceIds: $faceIds, error: $error, isProcessing: $isProcessing)';
  }

  @override
  bool operator ==(covariant ImageFaceMapper other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.image == image &&
        other.sessionIdentity == sessionIdentity &&
        listEquals(other.faceIds, faceIds) &&
        other.error == error &&
        other.isProcessing == isProcessing;
  }

  @override
  int get hashCode {
    return image.hashCode ^
        sessionIdentity.hashCode ^
        faceIds.hashCode ^
        error.hashCode ^
        isProcessing.hashCode;
  }

  ActivityStatus get status {
    return switch (this) {
      (_) when faceIds != null => ActivityStatus.success,
      (_) when error != null => ActivityStatus.error,
      (_) when (sessionIdentity != null) && isProcessing == 2 =>
        ActivityStatus.processingNow,
      (_) when (sessionIdentity != null) && isProcessing == 1 =>
        ActivityStatus.pending,
      (_) when sessionIdentity != null => ActivityStatus.ready,
      _ => ActivityStatus.premature,
    };
  }

  ImageFaceMapper setSessionId(String? sessionIdentity) {
    // When the session is changed, we set only when faces are not available
    if (faceIds != null || sessionIdentity == this.sessionIdentity) {
      return this;
    }

    // setting a session will clear error state and isProcessing state
    return copyWith(
      sessionIdentity: () => sessionIdentity,
      error: () => null,
      isProcessing: 0,
    );
  }

  ImageFaceMapper setError(String error) {
    // Setting an error will clear isProcessing and faceIds
    return copyWith(error: () => error, isProcessing: 0, faceIds: () => null);
  }

  ImageFaceMapper setIsPushed() {
    return copyWith(error: () => null, isProcessing: 1, faceIds: () => null);
  }

  ImageFaceMapper setIsProcessing() {
    return copyWith(error: () => null, isProcessing: 2, faceIds: () => null);
  }

  ImageFaceMapper setFaces(List<String> faceIds) {
    return copyWith(faceIds: () => faceIds, error: () => null, isProcessing: 0);
  }

  ImageFaceMapper reset() {
    if (isProcessing == 2) {
      return this;
    }
    return copyWith(faceIds: () => null, error: () => null, isProcessing: 0);
  }
}
