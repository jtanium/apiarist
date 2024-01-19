import 'api_error.dart';
import 'api_failure.dart';
import 'response.dart';

class ErrorResponse<T> extends Response<T> {
  const ErrorResponse._({
    required this.error,
    required this.isLoading,
    required this.hasValue,
    required this.value,
    required this.failure,
  }) : super.internal();

  const ErrorResponse(ApiError error)
      : this._(
    error: error,
    isLoading: false,
    hasValue: false,
    value: null,
    failure: null,
  );

  @override
  final T? value;

  @override
  final bool hasValue;

  @override
  final bool isLoading;

  @override
  final ApiError error;

  @override
  final ApiFailure? failure;
}
