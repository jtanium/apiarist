import 'dart:convert';

import 'package:apiarist/api.dart' as api;
import 'package:riverpod/riverpod.dart';


class NumberFactResponseNotifier extends StateNotifier<api.Response<Map<String, dynamic>>> {
  NumberFactResponseNotifier() : super(api.Response.loading()) { // set the state to loading
    _getNumberFact();
  }

  Future<void> _getNumberFact() async {
    api.Endpoint endpoint = api.Endpoint(baseUrl: "http://numbersapi.com");
    state = await endpoint.call(api.HttpMethod.get, "/random/trivia", queryParams: {"json": ""}, onSuccess: (body) => jsonDecode(body));
  }
}

final numberFactResponseProvider = StateNotifierProvider<NumberFactResponseNotifier, api.Response<Map<String, dynamic>>>(
        (ref) => NumberFactResponseNotifier());



class UselessFactResponseNotifier extends StateNotifier<api.Response<Map<String, dynamic>>> {
  UselessFactResponseNotifier() : super(api.Response.loading()) {
    _getUselessFact();
  }

  Future<void> _getUselessFact() async {
    api.Endpoint endpoint = api.Endpoint(baseUrl: "https://uselessfacts.jsph.pl/api/v2");
    state = await endpoint.call(api.HttpMethod.get, "/facts/random", onSuccess: (body) => jsonDecode(body));
  }
}

final uselessFactResponseProvider =
StateNotifierProvider<UselessFactResponseNotifier, api.Response<Map<String, dynamic>>>(
        (ref) => UselessFactResponseNotifier());
