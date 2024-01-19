import 'package:apiarist/api.dart' as api;
import 'package:riverpod/riverpod.dart';

import 'model.dart';
import 'model_provider.dart';

Future<void> main() async {
  // Riverpod container for our Providers
  final container = ProviderContainer();

  // In a Flutter app, we would use ref.watch(), but since we don't have a Ref object we will use container.listen()
  // We are giving it a handler function to update the apiResponse variable once it gets a value
  api.Response<CompositeModel> apiResponse;
  apiResponse = container.listen(numberAndUselessFactsProvider, (previous, value) {
    print("apiResponse has changed");
    apiResponse = value;
  }).read();
  print("initial response state: ${apiResponse.runtimeType}");

  while (apiResponse.isLoading) {
    // To give time for the api calls to return data and the (apiResponse = value) handler above to do their thing, we
    // will just sleep for a short time, and periodically check to see if it is done loading
    await Future.delayed(Duration(milliseconds: 50), () {});
  }
  // Once it is done, print out the result
  apiResponse.when(
    data: (fact) => print(fact),
    loading: () => print("timed out"),
    error: (error) => print("error: $error"),
    failure: (failure) => print("failure: $failure"),
  );

  container.dispose();
}
