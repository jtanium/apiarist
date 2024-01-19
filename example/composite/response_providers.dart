import 'dart:convert';

import 'package:apiarist/apiarist.dart';
import 'package:riverpod/riverpod.dart';


class NumberFactResponseNotifier extends StateNotifier<ApiResponse<Map<String, dynamic>>> {
  NumberFactResponseNotifier() : super(ApiResponse.loading()) { // set the state to loading
    _getNumberFact();
  }

  Future<void> _getNumberFact() async {
    ApiEndpoint endpoint = ApiEndpoint(baseUrl: "http://numbersapi.com");
    state = await endpoint.call(HttpMethod.get, "/random/trivia", queryParams: {"json": ""}, onSuccess: (body) => jsonDecode(body));
  }
}

final numberFactResponseProvider = StateNotifierProvider<NumberFactResponseNotifier, ApiResponse<Map<String, dynamic>>>(
        (ref) => NumberFactResponseNotifier());



class UselessFactResponseNotifier extends StateNotifier<ApiResponse<Map<String, dynamic>>> {
  UselessFactResponseNotifier() : super(ApiResponse.loading()) {
    _getUselessFact();
  }

  Future<void> _getUselessFact() async {
    ApiEndpoint endpoint = ApiEndpoint(baseUrl: "https://uselessfacts.jsph.pl/api/v2");
    state = await endpoint.call(HttpMethod.get, "/facts/random", onSuccess: (body) => jsonDecode(body));
  }
}

final uselessFactResponseProvider =
StateNotifierProvider<UselessFactResponseNotifier, ApiResponse<Map<String, dynamic>>>(
        (ref) => UselessFactResponseNotifier());
