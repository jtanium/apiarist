import 'dart:convert';

import 'package:apiarist/apiarist.dart';

import 'model.dart';


Future<void> main() async {
  ApiEndpoint endpoint = ApiEndpoint(baseUrl: "https://uselessfacts.jsph.pl/api/v2");

  ApiResponse<UselessFact> randomFactResponse = await endpoint.call(HttpMethod.get, "/facts/random",
      onSuccess: (responseBody) => UselessFact.fromJson(jsonDecode(responseBody)));
  randomFactResponse.when(
    // this won't happen in this example because we are calling await
    loading: () => print("waiting on api..."),
    // this is what we expect will be called
    data: (uselessFact) => print(uselessFact),
    // these shouldn't happen in this example, but it might if the service is having an issue
    error: (apiError) => print("[api-error] ${apiError.response.statusCode} - ${apiError.uri}"),
    failure: (apiFailure) => print("[api-failure] ${apiFailure.error}"),
  );

  ApiResponse<UselessFact> notFoundResponse = await endpoint.call(HttpMethod.get, "/paththatdoesnotexist",
      onSuccess: (responseBody) => UselessFact.fromJson(jsonDecode(responseBody)));
  notFoundResponse.when(
    // this won't happen in this example because we are calling await
    loading: () => print("waiting on api..."),
    // these won't happen in this example
    data: (uselessFact) => print(uselessFact),
    error: (apiError) => print("[api-error] ${apiError.response.statusCode} - ${apiError.uri}"),
    // this is what we expect to be called
    failure: (apiFailure) => print("[api-failure] ${apiFailure.error}"),
  );
}
