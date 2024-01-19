import 'api_error.dart';
import 'api_failure.dart';
import 'response.dart';

class ApiLoading<T> extends Response<T> {
  const ApiLoading._({
    required this.hasValue,
    required this.value,
    required this.error,
    required this.failure,
  }) : super.internal();

  const ApiLoading()
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
