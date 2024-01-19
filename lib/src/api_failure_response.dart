import 'api_error.dart';
import 'api_failure.dart';
import 'api_response.dart';

/*
 * This indicates we failed to get a response from the Api (server), or an exception occurred while trying to handle it
 */
class ApiFailureResponse<T> extends ApiResponse<T> {
  const ApiFailureResponse._({
    required this.error,
    required this.isLoading,
    required this.hasValue,
    required this.value,
    required this.failure,
  }) : super.internal();

  const ApiFailureResponse(ApiFailure failure)
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