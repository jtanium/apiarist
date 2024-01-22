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

`AsyncValue` but for REST APIs.

Dart/Flutter library for interacting with an API, particularly a REST API.

The impetus for this was Riverpod's `AsyncValue`. The idea was great. And it is
great for the usual things like reading from device storage. But using `AsyncValue`
for API calls breaks down because it can only handle loading, data, and exceptions.
If you get an HTTP 400 Bad Request or HTTP 401 Unauthorized, you have to shoehorn
the error response into either "data" or "error", neither of which are ideal.

Apiarist introduces the concept of an API response object (`ApiResponse`) to handle
those situations better.

## Getting Started
Install the usual way
```shell
flutter pub get apiarist
```

## Usage

```dart
Widget build(BuildContext context) {
  ApiResponse<MyModel> apiResponse = ref.watch(myModelProvider);
  return apiResponse.when(
    loading: () => CircularLoadingIndicator(),
    data: (myModel) => Text(myModel.FullName),
    error: (apiError) {
      logger.warning("API ");
      return Text("${apiError.statusCode} - ${apiError.parsedBody()['errorDesc']}");
    },
    unauthorized: (apiError) => context.go("/login"),
    notFound: (apiError) => Text("Sorry, we couldn't find that one"),
    failure: (apiFailure) {
      logger.warning("API Failure: ${apiFailure.error}\n${apiFailure.stackTrace}");
      return Text("Request failed");
    },
  );
}
```

