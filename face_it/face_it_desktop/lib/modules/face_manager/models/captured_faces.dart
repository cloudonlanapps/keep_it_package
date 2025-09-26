// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum ActivityStatus {
  premature,
  pending,
  processingNow,
  success,
  error,
  ignore,
}

@immutable
class FacesInImage {
  final String source;
  final String? sessionIdentity;
  final List<String>? faceIds;
  final String? error;
  final bool isProcessing;
  const FacesInImage({
    required this.source,
    this.isProcessing = false,
    this.sessionIdentity,
    this.faceIds,
    this.error,
  });

  FacesInImage copyWith({
    String? source,
    ValueGetter<String?>? sessionIdentity,
    ValueGetter<List<String>?>? faceIds,
    ValueGetter<String?>? error,
    bool? isProcessing,
  }) {
    return FacesInImage(
      source: source ?? this.source,
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
    return 'FacesInImage(source: $source, sessionIdentity: $sessionIdentity, faceIds: $faceIds, error: $error, isProcessing: $isProcessing)';
  }

  @override
  bool operator ==(covariant FacesInImage other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.source == source &&
        other.sessionIdentity == sessionIdentity &&
        listEquals(other.faceIds, faceIds) &&
        other.error == error &&
        other.isProcessing == isProcessing;
  }

  @override
  int get hashCode {
    return source.hashCode ^
        sessionIdentity.hashCode ^
        faceIds.hashCode ^
        error.hashCode ^
        isProcessing.hashCode;
  }

  ActivityStatus get status {
    return switch (this) {
      (_) when faceIds != null => ActivityStatus.success,
      (_) when error != null => ActivityStatus.error,
      (_) when isProcessing => ActivityStatus.processingNow,
      (_) when sessionIdentity != null => ActivityStatus.pending,
      _ => ActivityStatus.premature,
    };
  }

  FacesInImage setSessionId(String? sessionIdentity) {
    // When the session is changed, we set only when faces are not available
    if (faceIds != null || sessionIdentity == this.sessionIdentity) {
      return this;
    }

    // setting a session will clear error state and isProcessing state
    return copyWith(
      sessionIdentity: () => sessionIdentity,
      error: () => null,
      isProcessing: false,
    );
  }

  FacesInImage setError(String error) {
    // Setting an error will clear isProcessing and faceIds
    return copyWith(
      error: () => error,
      isProcessing: false,
      faceIds: () => null,
    );
  }

  FacesInImage setIsProcessing() {
    return copyWith(error: () => null, isProcessing: true, faceIds: () => null);
  }

  FacesInImage setFaces(List<String> faceIds) {
    return copyWith(
      faceIds: () => faceIds,
      error: () => null,
      isProcessing: false,
    );
  }

  FacesInImage reset() {
    if (isProcessing) {
      return this;
    }
    return copyWith(
      faceIds: () => null,
      error: () => null,
      isProcessing: false,
    );
  }
}
