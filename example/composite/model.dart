// Simple class composed of information from multiple requests
class CompositeModel {
  final int number;
  final String numberFact;
  final String uselessFact;

  CompositeModel({required this.number, required this.numberFact, required this.uselessFact});

  factory CompositeModel.fromJson({
    required Map<String, dynamic> numberJson,
    required Map<String, dynamic> uselessJson,
  }) {
    return CompositeModel(
      number: numberJson["number"],
      numberFact: numberJson["text"],
      uselessFact: uselessJson["text"],
    );
  }

  @override
  String toString() => "number($number)=$numberFact / useless=$uselessFact";
}
