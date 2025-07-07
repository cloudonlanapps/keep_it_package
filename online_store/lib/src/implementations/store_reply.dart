import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StoreReply<T> {
  StoreReply<M> cast<M>();

  T? getResult() =>
      switch (this) { (final StoreResult<T> t) => t.result, _ => null };

  Future<M> when<M>(
      {required Future<M> Function(T response) validResponse,
      required Future<M> Function(Map<String, dynamic> error, {StackTrace? st})
          errorResponse}) {
    return switch (this) {
      (final StoreResult<T> response) => validResponse(response.result),
      (final StoreError<T> error) =>
        errorResponse(error.errorResponse, st: error.st),
      StoreReply<T>() => errorResponse(
          {'error': "This can't occur as ServerReply is a abstract  class"}),
    };
  }

  @override
  String toString();
}

@immutable
class StoreResult<T> extends StoreReply<T> {
  StoreResult(this.result);
  final T result;

  @override
  StoreReply<M> cast<M>() {
    return StoreResult<M>(result as M);
  }

  @override
  String toString() => 'StoreResult(result: $result)';

  @override
  bool operator ==(covariant StoreResult<T> other) {
    if (identical(this, other)) return true;

    return other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

@immutable
class StoreError<T> extends StoreReply<T> {
  StoreError(this.errorResponse, {this.st});

  factory StoreError.fromString(String errorString, {StackTrace? st}) {
    Map<String, dynamic> map;
    try {
      map = jsonDecode(errorString) as Map<String, dynamic>;
    } catch (e) {
      map = {'error': errorString};
    }
    return StoreError(map, st: st);
  }
  final Map<String, dynamic> errorResponse;
  final StackTrace? st;

  @override
  StoreReply<M> cast<M>() {
    return StoreError<M>(errorResponse, st: st);
  }

  @override
  String toString() => 'StoreError(errorResponse: $errorResponse, st: $st)';

  @override
  bool operator ==(covariant StoreError<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return mapEquals(other.errorResponse, errorResponse) && other.st == st;
  }

  @override
  int get hashCode => errorResponse.hashCode ^ st.hashCode;

  StoreError<T> appendFields(Map<String, dynamic> fields) {
    final map = {...errorResponse, ...fields};
    return copyWith(errorResponse: map);
  }

  StoreError<T> copyWith({
    Map<String, dynamic>? errorResponse,
    ValueGetter<StackTrace?>? st,
  }) {
    return StoreError<T>(
      errorResponse ?? this.errorResponse,
      st: st != null ? st.call() : this.st,
    );
  }
}
