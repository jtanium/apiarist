<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# Apiarist

A Dart package for handling API responses in a structured and type-safe way. Apiarist provides a clean abstraction for managing different API response states including loading, success, error, and failure scenarios.

## Features

- **Type-safe API response handling** - Generic `ApiResponse<T>` class for any data type
- **Comprehensive state management** - Support for loading, data, error, and failure states
- **HTTP status code handling** - Built-in support for all standard HTTP status codes
- **Riverpod integration** - Seamless integration with Riverpod for state management
- **Composite responses** - Combine multiple API responses with intelligent error handling
- **Graceful error handling** - Distinguish between API errors and application failures

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  apiarist: ^1.0.6
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Usage

```dart
import 'package:apiarist/apiarist.dart';

// Create different response states
ApiResponse<String> loadingResponse = ApiResponse.loading();
ApiResponse<String> dataResponse = ApiResponse.data("Hello, World!");
ApiResponse<String> errorResponse = ApiResponse.error(ApiError(/* error details */));
ApiResponse<String> failureResponse = ApiResponse.failure(ApiFailure(/* failure details */));

// Handle responses with pattern matching
String result = response.when(
  data: (data) => "Success: $data",
  loading: () => "Loading...",
  error: (error) => "Error: ${error.message}",
  failure: (failure) => "Failure: ${failure.message}",
);
```

### Advanced Error Handling

Handle specific HTTP status codes:

```dart
String handleResponse = response.when(
  data: (data) => "Success: $data",
  loading: () => "Loading...",
  error: (error) => "Generic error: ${error.message}",
  failure: (failure) => "Failure: ${failure.message}",
  
  // Specific HTTP status code handlers
  badRequest: (error) => "Bad request: ${error.message}",
  unauthorized: (error) => "Please log in again",
  forbidden: (error) => "Access denied",
  notfound: (error) => "Resource not found",
  internalServerError: (error) => "Server error, please try again later",
  // ... and many more status codes
);
```

### Composite Responses

Combine multiple API responses with intelligent error prioritization:

```dart
ApiResponse<CombinedData> combinedResponse = ApiResponse.composite([
  userResponse,
  settingsResponse,
  notificationsResponse,
], (responses) {
  // All responses are successful, combine the data
  return CombinedData(
    user: responses[0],
    settings: responses[1], 
    notifications: responses[2],
  );
});
```

### Data Conversion

Convert response data to different types:

```dart
ApiResponse<User> userResponse = ApiResponse.data(userData);
ApiResponse<String> userNameResponse = userResponse.convertData((user) => user.name);
```

### Checking Response State

```dart
if (response.isLoading) {
  // Show loading indicator
}

if (response.hasValue) {
  // Use response.value
}

if (response.hasError) {
  // Handle API error
  print("Error: ${response.error?.message}");
}

if (response.hasFailure) {
  // Handle application failure
  print("Failure: ${response.failure?.message}");
}
```

### Integration with Riverpod

```dart
import 'package:riverpod/riverpod.dart';

final userProvider = FutureProvider<ApiResponse<User>>((ref) async {
  try {
    final response = await apiService.getUser();
    return ApiResponse.data(response);
  } on ApiError catch (e) {
    return ApiResponse.error(e);
  } catch (e) {
    return ApiResponse.failure(ApiFailure(e.toString()));
  }
});

// In your widget
Consumer(
  builder: (context, ref, child) {
    final userResponse = ref.watch(userProvider);
    
    return userResponse.when(
      data: (response) => response.when(
        data: (user) => UserWidget(user: user),
        loading: () => CircularProgressIndicator(),
        error: (error) => ErrorWidget(error: error),
        failure: (failure) => FailureWidget(failure: failure),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  },
)
```

## API Reference

### ApiResponse<T>

The main class for handling API responses.

#### Constructors

- `ApiResponse.data(T value)` - Create a successful response with data
- `ApiResponse.loading()` - Create a loading response
- `ApiResponse.error(ApiError error)` - Create an error response
- `ApiResponse.failure(ApiFailure failure)` - Create a failure response

#### Properties

- `bool isLoading` - Whether the response is in loading state
- `bool hasValue` - Whether the response has data
- `T? value` - The response data (null if not in data state)
- `ApiError? error` - The API error (null if not in error state)
- `bool hasError` - Whether the response has an error
- `ApiFailure? failure` - The failure details (null if not in failure state)
- `bool hasFailure` - Whether the response has a failure

#### Methods

- `when<R>({...})` - Pattern match on the response state with optional specific status code handlers
- `convertData<R>(R Function(T) converter)` - Convert the response data to a different type
- `static composite<T>(List<ApiResponse> responses, T Function(List) combiner)` - Combine multiple responses

### ApiError

Represents an API error with HTTP response details.

### ApiFailure

Represents an application-level failure (non-HTTP errors).

## Error vs Failure

- **ApiError**: HTTP-related errors from the server (4xx, 5xx status codes)
- **ApiFailure**: Application-level failures (network issues, parsing errors, etc.)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
