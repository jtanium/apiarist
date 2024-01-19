class UselessFact {
  final String id;
  final String text;
  final String source;
  final String sourceUrl;
  final String language;
  final String permalink;

  UselessFact(
      {required this.id,
        required this.text,
        required this.source,
        required this.sourceUrl,
        required this.language,
        required this.permalink});

  factory UselessFact.fromJson(jsonMap) {
    return UselessFact(
      id: jsonMap["id"],
      text: jsonMap["text"],
      source: jsonMap["source"],
      sourceUrl: jsonMap["source_url"],
      language: jsonMap["language"],
      permalink: jsonMap["permalink"],
    );
  }

  @override
  String toString() {
    return "Useless Fact #$id: $text";
  }
}
