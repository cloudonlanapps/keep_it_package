import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

typedef ValueGetter<T> = T Function();

@immutable
abstract class ServerReply<T> {
  ServerReply<M> cast<M>();

  T? getResult() => switch (this) {
    (final ServerResult<T> t) => t.result,
    _ => null,
  };

  Future<M> when<M>({
    required Future<M> Function(T response) validResponse,
    required Future<M> Function(Map<String, dynamic> error, {StackTrace? st})
    errorResponse,
  }) {
    return switch (this) {
      (final ServerResult<T> response) => validResponse(response.result),
      (final ServerError<T> error) => errorResponse(
        error.errorResponse,
        st: error.st,
      ),
      ServerReply<T>() => errorResponse({
        'error': "This can't occur as ServerReply is a abstract  class",
      }),
    };
  }

  @override
  String toString();
}

@immutable
class ServerResult<T> extends ServerReply<T> {
  ServerResult(this.result);
  final T result;

  @override
  ServerReply<M> cast<M>() {
    return ServerResult<M>(result as M);
  }

  @override
  String toString() => 'ServerResult(result: $result)';

  @override
  bool operator ==(covariant ServerResult<T> other) {
    if (identical(this, other)) return true;

    return other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

@immutable
class ServerError<T> extends ServerReply<T> {
  ServerError(this.errorResponse, {this.st});

  factory ServerError.fromString(String errorString, {StackTrace? st}) {
    Map<String, dynamic> map;
    try {
      map = jsonDecode(errorString) as Map<String, dynamic>;
    } on FormatException {
      map = {'error': errorString, 'type': 'MissingPageError'};
    }
    return ServerError(map, st: st);
  }
  final Map<String, dynamic> errorResponse;
  final StackTrace? st;

  @override
  ServerReply<M> cast<M>() {
    return ServerError<M>(errorResponse, st: st);
  }

  @override
  String toString() => 'ServerError(errorResponse: $errorResponse, st: $st)';

  @override
  bool operator ==(covariant ServerError<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return mapEquals(other.errorResponse, errorResponse) && other.st == st;
  }

  @override
  int get hashCode => errorResponse.hashCode ^ st.hashCode;

  ServerError<T> appendFields(Map<String, dynamic> fields) {
    final map = {...errorResponse, ...fields};
    return copyWith(errorResponse: map);
  }

  ServerError<T> copyWith({
    Map<String, dynamic>? errorResponse,
    ValueGetter<StackTrace?>? st,
  }) {
    return ServerError<T>(
      errorResponse ?? this.errorResponse,
      st: st != null ? st.call() : this.st,
    );
  }
}
