import 'api_error.dart';
import 'api_failure.dart';
import 'api_response.dart';

class ApiDataResponse<T> extends ApiResponse<T> {
  const ApiDataResponse._(
      this.value, {
        required this.isLoading,
        required this.error,
        required this.failure,
      }) : super.internal();

  const ApiDataResponse(T value)
      : this._(
    value,
    isLoading: false,
    error: null,
    failure: null,
  );

  @override
  final T value;

  @override
  bool get hasValue => true;

  @override
  final bool isLoading;

  @override
  final ApiError? error;

  @override
  final ApiFailure? failure;
}
