import 'api_response.dart';

/// Extension on Future<ApiResponse<T>> to enable fluent chaining syntax.
///
/// This extension allows you to chain API calls without needing intermediate
/// await statements, creating a more elegant fluent API.
///
/// Example:
/// ```dart
/// final result = await api
///   .getUser(userId)
///   .chain((user) => api.getProfile(user.profileId))
///   .chain((profile) => api.getSettings(profile.settingsId))
///   .convertData((settings) => settings.getDetails());
/// ```
extension FutureApiResponseExtension<T> on Future<ApiResponse<T>> {
  /// Chain this future response with another API call that depends on the data.
  ///
  /// This method awaits the current future, then calls [chain] on the resulting
  /// ApiResponse, enabling fluent chaining without intermediate variables.
  ///
  /// If the response has data, [fn] is called with that data and its result
  /// is returned. If the response is loading, error, or failure, those states
  /// are propagated without calling [fn].
  Future<ApiResponse<R>> chain<R>(
    Future<ApiResponse<R>> Function(T data) fn,
  ) async {
    return (await this).chain(fn);
  }

  /// Transform the data value if present, otherwise propagate the current state.
  ///
  /// This is a convenience method that awaits the future and calls [convertData]
  /// on the resulting ApiResponse.
  Future<ApiResponse<R>> convertData<R>(
    R Function(T data) convertFn,
  ) async {
    return (await this).convertData(convertFn);
  }
}