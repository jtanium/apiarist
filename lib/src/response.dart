import 'package:riverpod/riverpod.dart';

import 'api_data.dart';
import 'api_error.dart';
import 'api_failure.dart';
import 'api_loading.dart';
import 'error_response.dart';
import 'failure_response.dart';

/// This class simply avoids bugs related to ApiResponse<void>, since ApiResponse#when has to return a non-nullable value
class NoContent {}

abstract class Response<T> {
  const Response.internal();

  const factory Response.data(T value) = ApiData<T>;

  const factory Response.loading() = ApiLoading<T>;

  const factory Response.error(ApiError error) = ErrorResponse<T>;

  const factory Response.failure(ApiFailure failure) = FailureResponse<T>;

  bool get isLoading;

  bool get hasValue;

  T? get value;

  ApiError? get error;

  bool get hasError => error != null;

  ApiFailure? get failure;

  bool get hasFailure => failure != null;

  @override
  String toString() {
    return "$runtimeType isLoading=$isLoading value=$value error=$error failure=${failure?.error}";
  }

  R when<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(ApiError) error,
    required R Function(ApiFailure) failure,
    R Function(ApiError)? badRequest,
    R Function(ApiError)? unauthorized,
    R Function(ApiError)? paymentRequired,
    R Function(ApiError)? forbidden,
    R Function(ApiError)? notfound,
    R Function(ApiError)? methodNotAllowed,
    R Function(ApiError)? notAcceptable,
    R Function(ApiError)? proxyAuthenticationRequired,
    R Function(ApiError)? requestTimeOut,
    R Function(ApiError)? conflict,
    R Function(ApiError)? gone,
    R Function(ApiError)? lengthRequired,
    R Function(ApiError)? preconditionFailed,
    R Function(ApiError)? payloadTooLarge,
    R Function(ApiError)? uriTooLong,
    R Function(ApiError)? unsupportedMediaType,
    R Function(ApiError)? rangeNotSatisfiable,
    R Function(ApiError)? expectationFailed,
    R Function(ApiError)? imATeapot,
    R Function(ApiError)? misdirectedRequest,
    R Function(ApiError)? unprocessableContent,
    R Function(ApiError)? locked,
    R Function(ApiError)? failedDependency,
    R Function(ApiError)? tooEarly,
    R Function(ApiError)? upgradeRequired,
    R Function(ApiError)? preconditionRequired,
    R Function(ApiError)? tooManyRequests,
    R Function(ApiError)? requestHeaderFieldsTooLarge,
    R Function(ApiError)? unavailableForLegalReasons,
    R Function(ApiError)? internalServerError,
    R Function(ApiError)? notImplemented,
    R Function(ApiError)? badGateway,
    R Function(ApiError)? serviceUnavailable,
    R Function(ApiError)? gatewayTimeout,
    R Function(ApiError)? httpVersionNotSupported,
    R Function(ApiError)? variantAlsoNegotiates,
    R Function(ApiError)? insufficientStorage,
    R Function(ApiError)? loopDetected,
    R Function(ApiError)? notExtended,
    R Function(ApiError)? networkAuthenticationRequired,
  }) {
    if (isLoading) {
      return loading();
    }
    if (hasFailure) {
      return failure(this.failure!);
    }
    if (hasError) {
      switch (this.error!.response.statusCode) {
        case 400:
          return (badRequest ?? error)(this.error!);
        case 401:
          return (unauthorized ?? error)(this.error!);
        case 402:
          return (paymentRequired ?? error)(this.error!);
        case 403:
          return (forbidden ?? error)(this.error!);
        case 404:
          return (notfound ?? error)(this.error!);
        case 405:
          return (methodNotAllowed ?? error)(this.error!);
        case 406:
          return (notAcceptable ?? error)(this.error!);
        case 407:
          return (proxyAuthenticationRequired ?? error)(this.error!);
        case 408:
          return (requestTimeOut ?? error)(this.error!);
        case 409:
          return (conflict ?? error)(this.error!);
        case 410:
          return (gone ?? error)(this.error!);
        case 411:
          return (lengthRequired ?? error)(this.error!);
        case 412:
          return (preconditionFailed ?? error)(this.error!);
        case 413:
          return (payloadTooLarge ?? error)(this.error!);
        case 414:
          return (uriTooLong ?? error)(this.error!);
        case 415:
          return (unsupportedMediaType ?? error)(this.error!);
        case 416:
          return (rangeNotSatisfiable ?? error)(this.error!);
        case 417:
          return (expectationFailed ?? error)(this.error!);
        case 418:
          return (imATeapot ?? error)(this.error!);
        case 421:
          return (misdirectedRequest ?? error)(this.error!);
        case 422:
          return (unprocessableContent ?? error)(this.error!);
        case 423:
          return (locked ?? error)(this.error!);
        case 424:
          return (failedDependency ?? error)(this.error!);
        case 425:
          return (tooEarly ?? error)(this.error!);
        case 426:
          return (upgradeRequired ?? error)(this.error!);
        case 428:
          return (preconditionRequired ?? error)(this.error!);
        case 429:
          return (tooManyRequests ?? error)(this.error!);
        case 431:
          return (requestHeaderFieldsTooLarge ?? error)(this.error!);
        case 451:
          return (unavailableForLegalReasons ?? error)(this.error!);
        case 500:
          return (internalServerError ?? error)(this.error!);
        case 501:
          return (notImplemented ?? error)(this.error!);
        case 502:
          return (badGateway ?? error)(this.error!);
        case 503:
          return (serviceUnavailable ?? error)(this.error!);
        case 504:
          return (gatewayTimeout ?? error)(this.error!);
        case 505:
          return (httpVersionNotSupported ?? error)(this.error!);
        case 506:
          return (variantAlsoNegotiates ?? error)(this.error!);
        case 507:
          return (insufficientStorage ?? error)(this.error!);
        case 508:
          return (loopDetected ?? error)(this.error!);
        case 510:
          return (notExtended ?? error)(this.error!);
        case 511:
          return (networkAuthenticationRequired ?? error)(this.error!);
        default:
          return error(this.error!);
      }
    }
    return data(value as T);
  }

  factory Response.composite(List<dynamic> watched, T Function(List<dynamic>) dataReady) {
    if (watched.any((e) => e.isLoading)) {
      return const Response.loading();
    }
    dynamic error = watched.firstWhere(_hasError, orElse: () => null);
    if (error != null) {
      return Response.error(error.error!);
    }
    Response<dynamic>? failure = watched.firstWhere(_hasFailure, orElse: () => null);
    if (failure != null) {
      return Response.failure(failure.failure!);
    }
    return Response.data(dataReady(List.from(watched.map((e) => e.value!))));
  }

  static bool _hasError(element) {
    if (element is AsyncValue) return element.error != null;
    if (element is Response) return element.hasError;
    return false;
  }

  static bool _hasFailure(element) {
    if (element is Response) return element.hasFailure;
    return false;
  }
}
