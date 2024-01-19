import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiError {
  final http.Response response;
  final Map<String, dynamic> metadata;
  final Uri uri;

  ApiError(this.response, {required this.uri, this.metadata = const {}});

  String? get responseContentType => response.headers["Content-Type"];

  @override
  String toString() => "$runtimeType<httpStatus=${response.statusCode} responseBody=${response.body} uri=$uri>";

  dynamic parseBody() {
    switch (responseContentType) {
      case ("application/json"):
        return jsonDecode(response.body);
    }
    return response.body;
  }
}