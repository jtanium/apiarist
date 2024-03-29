import 'api_error.dart';
import 'api_failure.dart';
import 'api_response.dart';

class LoadingResponse<T> extends ApiResponse<T> {
  const LoadingResponse()
      : hasValue = false,
        value = null,
        error = null,
        failure = null,
        super.internal();

  @override
  final T? value;

  @override
  final bool hasValue;

  @override
  bool get isLoading => true;

  @override
  final ApiError? error;

  @override
  final ApiFailure? failure;
}
