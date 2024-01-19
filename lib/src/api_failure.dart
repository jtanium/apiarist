class ApiFailure {
  final Object error;
  final StackTrace stackTrace;
  final Uri? uri;

  ApiFailure(this.error, this.stackTrace, [this.uri]);

  @override
  String toString() {
    return "$runtimeType<uri=$uri error=$error stacktrace=$stackTrace>";
  }
}
