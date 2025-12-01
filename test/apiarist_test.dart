import 'package:apiarist/src/api_error.dart';
import 'package:apiarist/src/api_failure.dart';
import 'package:apiarist/src/api_response.dart';
import 'package:apiarist/src/future_api_response_extension.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('ApiResponse.composite', () {
    test('returns loading when no errors or failures', () {
      final responses = [
        const ApiResponse<String>.data('test1'),
        const ApiResponse<int>.loading(),
        const ApiResponse<bool>.data(true),
      ];

      final result = ApiResponse.composite(responses, (data) => data.join(','));

      expect(result.isLoading, isTrue);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
    });

    test('returns error when any response has error', () {
      final error = ApiError(
        http.Response('Error', 400),
        uri: Uri.parse('https://example.com'),
      );

      final responses = [
        const ApiResponse<String>.data('test1'),
        ApiResponse<int>.error(error),
        const ApiResponse<bool>.data(true),
        const ApiResponse<bool>.loading(),
      ];

      final result = ApiResponse.composite(responses, (data) => data.join(','));

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isTrue);
      expect(result.hasFailure, isFalse);
      expect(result.error, equals(error));
    });

    test('returns failure when any response has failure (no loading or error)', () {
      final failure = ApiFailure(
        Exception('Network error'),
        StackTrace.current,
        Uri.parse('https://example.com'),
      );

      final responses = [
        const ApiResponse<String>.data('test1'),
        ApiResponse<int>.failure(failure),
        const ApiResponse<bool>.data(true),
      ];

      final result = ApiResponse.composite(responses, (data) => data.join(','));

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isTrue);
      expect(result.failure, equals(failure));
    });

    test('returns data when all responses have data', () {
      final responses = [
        const ApiResponse<String>.data('hello'),
        const ApiResponse<String>.data('world'),
        const ApiResponse<String>.data('test'),
      ];

      final result = ApiResponse.composite(responses, (data) => data.join(' '));

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
      expect(result.value, equals('hello world test'));
    });

    test('prioritizes error and failure over loading', () {
      final error = ApiError(
        http.Response('Error', 400),
        uri: Uri.parse('https://example.com'),
      );
      final failure = ApiFailure(
        Exception('Network error'),
        StackTrace.current,
      );

      final responses = [
        const ApiResponse<String>.loading(),
        ApiResponse<int>.error(error),
        ApiResponse<bool>.failure(failure),
      ];

      final result = ApiResponse.composite(responses, (data) => data.toString());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isTrue);
      expect(result.hasFailure, isFalse);
    });

    test('prioritizes error over failure when no loading', () {
      final error = ApiError(
        http.Response('Error', 400),
        uri: Uri.parse('https://example.com'),
      );
      final failure = ApiFailure(
        Exception('Network error'),
        StackTrace.current,
      );

      final responses = [
        const ApiResponse<String>.data('test'),
        ApiResponse<int>.error(error),
        ApiResponse<bool>.failure(failure),
      ];

      final result = ApiResponse.composite(responses, (data) => data.toString());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isTrue);
      expect(result.hasFailure, isFalse);
      expect(result.error, equals(error));
    });

    test('handles empty list of responses', () {
      final responses = <ApiResponse<dynamic>>[];

      final result = ApiResponse.composite(responses, (data) => 'empty');

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
      expect(result.value, equals('empty'));
    });

    test('handles single response with data', () {
      final responses = [
        const ApiResponse<String>.data('single'),
      ];

      final result = ApiResponse.composite(responses, (data) => data.first.toUpperCase());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
      expect(result.value, equals('SINGLE'));
    });

    test('handles single response with loading', () {
      final responses = [
        const ApiResponse<String>.loading(),
      ];

      final result = ApiResponse.composite(responses, (data) => data.first.toString());

      expect(result.isLoading, isTrue);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
    });

    test('correctly processes data with different types', () {
      final responses = [
        const ApiResponse<int>.data(42),
        const ApiResponse<String>.data('test'),
        const ApiResponse<bool>.data(true),
      ];

      final result = ApiResponse.composite(responses, (data) {
        return '${data[0]}-${data[1]}-${data[2]}';
      });

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isTrue);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isFalse);
      expect(result.value, equals('42-test-true'));
    });

    test('returns first error found when multiple errors exist', () {
      final error1 = ApiError(
        http.Response('Error 1', 400),
        uri: Uri.parse('https://example1.com'),
      );
      final error2 = ApiError(
        http.Response('Error 2', 500),
        uri: Uri.parse('https://example2.com'),
      );

      final responses = [
        const ApiResponse<String>.data('test'),
        ApiResponse<int>.error(error1),
        ApiResponse<bool>.error(error2),
      ];

      final result = ApiResponse.composite(responses, (data) => data.toString());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isTrue);
      expect(result.hasFailure, isFalse);
      expect(result.error, equals(error1));
    });

    test('returns first failure found when multiple failures exist (no errors)', () {
      final failure1 = ApiFailure(
        Exception('Error 1'),
        StackTrace.current,
      );
      final failure2 = ApiFailure(
        Exception('Error 2'),
        StackTrace.current,
      );

      final responses = [
        const ApiResponse<String>.data('test'),
        ApiResponse<int>.failure(failure1),
        ApiResponse<bool>.failure(failure2),
      ];

      final result = ApiResponse.composite(responses, (data) => data.toString());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isTrue);
      expect(result.failure, equals(failure1));
    });

    test('gracefully converts AsyncValue.error to ApiResponse.failure', () {
      final responses = [
        const ApiResponse<String>.data('test'),
        AsyncValue<int>.error(Exception("Async error"), StackTrace.current),
      ];

      final result = ApiResponse.composite(responses, (data) => data.toString());

      expect(result.isLoading, isFalse);
      expect(result.hasValue, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasFailure, isTrue);
      expect(result.failure, isA<ApiFailure>());
      expect(result.failure!.error.toString(), Exception("Async error").toString());
    });
  });

  group('ApiResponse.chain', () {
    test('chains successful responses', () async {
      final response1 = const ApiResponse<int>.data(42);
      final response2 = await response1.chain((value) async {
        return ApiResponse<String>.data('Value: $value');
      });

      expect(response2.hasValue, isTrue);
      expect(response2.value, equals('Value: 42'));
      expect(response2.isLoading, isFalse);
      expect(response2.hasError, isFalse);
      expect(response2.hasFailure, isFalse);
    });

    test('propagates loading state without calling function', () async {
      var functionCalled = false;
      final response1 = const ApiResponse<int>.loading();
      final response2 = await response1.chain((value) async {
        functionCalled = true;
        return ApiResponse<String>.data('Value: $value');
      });

      expect(functionCalled, isFalse);
      expect(response2.isLoading, isTrue);
      expect(response2.hasValue, isFalse);
      expect(response2.hasError, isFalse);
      expect(response2.hasFailure, isFalse);
    });

    test('propagates error state without calling function', () async {
      var functionCalled = false;
      final error = ApiError(
        http.Response('Error', 404),
        uri: Uri.parse('https://example.com'),
      );
      final response1 = ApiResponse<int>.error(error);
      final response2 = await response1.chain((value) async {
        functionCalled = true;
        return ApiResponse<String>.data('Value: $value');
      });

      expect(functionCalled, isFalse);
      expect(response2.isLoading, isFalse);
      expect(response2.hasValue, isFalse);
      expect(response2.hasError, isTrue);
      expect(response2.hasFailure, isFalse);
      expect(response2.error, equals(error));
    });

    test('propagates failure state without calling function', () async {
      var functionCalled = false;
      final failure = ApiFailure(
        Exception('Network error'),
        StackTrace.current,
      );
      final response1 = ApiResponse<int>.failure(failure);
      final response2 = await response1.chain((value) async {
        functionCalled = true;
        return ApiResponse<String>.data('Value: $value');
      });

      expect(functionCalled, isFalse);
      expect(response2.isLoading, isFalse);
      expect(response2.hasValue, isFalse);
      expect(response2.hasError, isFalse);
      expect(response2.hasFailure, isTrue);
      expect(response2.failure, equals(failure));
    });

    test('chains multiple calls successfully', () async {
      final response1 = const ApiResponse<int>.data(10);
      final response2 = await response1.chain((value) async {
        return ApiResponse<int>.data(value * 2);
      });
      final response3 = await response2.chain((value) async {
        return ApiResponse<String>.data('Result: $value');
      });

      expect(response3.hasValue, isTrue);
      expect(response3.value, equals('Result: 20'));
    });

    test('stops chain on first error', () async {
      var secondCallMade = false;
      var thirdCallMade = false;

      final error = ApiError(
        http.Response('Error', 500),
        uri: Uri.parse('https://example.com'),
      );

      final response1 = const ApiResponse<int>.data(10);
      final response2 = await response1.chain((value) async {
        secondCallMade = true;
        return ApiResponse<int>.error(error);
      });
      final response3 = await response2.chain((value) async {
        thirdCallMade = true;
        return ApiResponse<String>.data('Should not happen');
      });

      expect(secondCallMade, isTrue);
      expect(thirdCallMade, isFalse);
      expect(response3.hasError, isTrue);
      expect(response3.error, equals(error));
    });

    test('stops chain on first failure', () async {
      var secondCallMade = false;
      var thirdCallMade = false;

      final failure = ApiFailure(
        Exception('Network error'),
        StackTrace.current,
      );

      final response1 = const ApiResponse<int>.data(10);
      final response2 = await response1.chain((value) async {
        secondCallMade = true;
        return ApiResponse<int>.failure(failure);
      });
      final response3 = await response2.chain((value) async {
        thirdCallMade = true;
        return ApiResponse<String>.data('Should not happen');
      });

      expect(secondCallMade, isTrue);
      expect(thirdCallMade, isFalse);
      expect(response3.hasFailure, isTrue);
      expect(response3.failure, equals(failure));
    });
  });

  group('FutureApiResponseExtension.chain', () {
    test('enables fluent chaining without intermediate variables', () async {
      Future<ApiResponse<int>> getInitialValue() async {
        return const ApiResponse<int>.data(5);
      }

      final result = await getInitialValue()
          .chain((value) async => ApiResponse<int>.data(value * 2))
          .chain((value) async => ApiResponse<String>.data('Result: $value'));

      expect(result.hasValue, isTrue);
      expect(result.value, equals('Result: 10'));
    });

    test('propagates error through fluent chain', () async {
      final error = ApiError(
        http.Response('Error', 400),
        uri: Uri.parse('https://example.com'),
      );

      Future<ApiResponse<int>> getInitialValue() async {
        return ApiResponse<int>.error(error);
      }

      final result = await getInitialValue()
          .chain((value) async => ApiResponse<int>.data(value * 2))
          .chain((value) async => ApiResponse<String>.data('Result: $value'));

      expect(result.hasError, isTrue);
      expect(result.error, equals(error));
    });

    test('combines chain and convertData fluently', () async {
      Future<ApiResponse<int>> getInitialValue() async {
        return const ApiResponse<int>.data(100);
      }

      final result = await getInitialValue()
          .chain((value) async => ApiResponse<int>.data(value + 50))
          .convertData((value) => 'Total: $value');

      expect(result.hasValue, isTrue);
      expect(result.value, equals('Total: 150'));
    });
  });
}
