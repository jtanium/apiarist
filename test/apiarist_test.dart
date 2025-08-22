import 'package:apiarist/src/api_error.dart';
import 'package:apiarist/src/api_failure.dart';
import 'package:apiarist/src/api_response.dart';
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
}
