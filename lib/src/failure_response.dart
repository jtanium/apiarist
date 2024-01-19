import 'api_error.dart';
import 'api_failure.dart';
import 'response.dart';

/*
 * This indicates we failed to get a response from the Api (server), or an exception occurred while trying to handle it
 */
class FailureResponse<T> extends Response<T> {
  const FailureResponse._({
    required this.error,
    required this.isLoading,
    required this.hasValue,
    required this.value,
    required this.failure,
  }) : super.internal();

  const FailureResponse(ApiFailure failure)
      : this._(
    error: null,
    isLoading: false,
    hasValue: false,
    value: null,
    failure: failure,
  );

  @override
  final T? value;

  @override
  final bool hasValue;

  @override
  final bool isLoading;

  @override
  final ApiError? error;

  @override
  final ApiFailure? failure;
}