import 'package:apiarist/apiarist.dart';
import 'package:riverpod/riverpod.dart';

import 'model.dart';
import 'response_providers.dart';

class RandomNumberAndUselessFactsNotifier extends Notifier<ApiResponse<CompositeModel>> {
  @override
  ApiResponse<CompositeModel> build() {
    return ApiResponse.composite(
      [
        ref.watch(numberFactResponseProvider),
        ref.watch(uselessFactResponseProvider),
      ],
          (data) {
        // <- called when we have received data for all watched provider
        print("data received from both api calls, instantiating model...");
        Map<String, dynamic> numberFact = data[0];
        Map<String, dynamic> uselessFact = data[1];
        return CompositeModel(
          number: numberFact["number"],
          numberFact: numberFact["text"],
          uselessFact: uselessFact["text"],
        );
      },
    );
  }
}

final numberAndUselessFactsProvider =
NotifierProvider<RandomNumberAndUselessFactsNotifier, ApiResponse<CompositeModel>>(
    RandomNumberAndUselessFactsNotifier.new);
