import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_error.dart';
import 'api_failure.dart';
import 'api_response.dart';

enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
}

class ApiEndpoint {
  late final String scheme;
  late final String host;
  late final String basePath;

  ApiEndpoint({required String baseUrl}) {
    Uri uri = Uri.parse(baseUrl);
    scheme = uri.scheme;
    host = uri.authority;
    basePath = uri.path;
  }

  Future<ApiResponse<T>> call<T>(
    HttpMethod method,
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? body,
    required T Function(dynamic) onSuccess,
  }) async {
    Uri uri;
    try {
      uri = _buildUri(path, queryParams);
    } catch (e, stackTrace) {
      return ApiResponse.failure(ApiFailure(e, stackTrace));
    }
    try {
      http.Response response = await _execute(method, uri, headers, body);
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return ApiResponse.data(_invokeOnSuccess(onSuccess, response));
      }
      return ApiResponse.error(ApiError(response, uri: uri));
    } on Exception catch (failure, stackTrace) {
      return ApiResponse.failure(ApiFailure(failure, stackTrace, uri));
    }
  }

  T _invokeOnSuccess<T>(T Function(dynamic) onSuccess, http.Response response) {
    if (_contentTypeIsJson(response)) return onSuccess(jsonDecode(response.body));

    return onSuccess(response.body);
  }

  Future<http.Response> _execute(HttpMethod method, Uri uri, Map<String, String>? headers, String? body) async {
    http.Response response;
    switch (method) {
      case HttpMethod.get:
        {
          response = await http.get(uri, headers: headers);
          break;
        }
      case HttpMethod.post:
        {
          response = await http.post(uri, headers: headers, body: body);
          break;
        }
      case HttpMethod.patch:
        {
          response = await http.patch(uri, headers: headers, body: body);
          break;
        }
      case HttpMethod.put:
        {
          response = await http.put(uri, headers: headers, body: body);
          break;
        }
      case HttpMethod.delete:
        {
          response = await http.delete(uri, headers: headers);
          break;
        }
    }
    return response;
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParams) {
    String fullPath = "$basePath${_pathWithLeadingSlash(path)}";
    if (queryParams != null && queryParams.isNotEmpty) {
      return _isHttps ? Uri.https(host, fullPath, queryParams) : Uri.http(host, fullPath, queryParams);
    }
    return _isHttps ? Uri.https(host, fullPath) : Uri.http(host, fullPath);
  }

  String _pathWithLeadingSlash(String path) => path.startsWith("/") ? path : "/$path";

  bool get _isHttps => scheme == "https";

  bool _contentTypeIsJson(http.Response response) => response.headers["Content-Type"] == "application/json";
}
