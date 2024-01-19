import 'api_error.dart';
import 'api_failure.dart';
import 'response.dart';

class DataResponse<T> extends Response<T> {
  const DataResponse._(
      this.value, {
        required this.isLoading,
        required this.error,
        required this.failure,
      }) : super.internal();

  const DataResponse(T value)
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
