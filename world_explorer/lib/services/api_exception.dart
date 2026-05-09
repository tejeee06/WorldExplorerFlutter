enum ApiErrorType {
  noInternet,
  notFound,
  timeout,
  malformedResponse,
  server,
  unknown,
}

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;

  const ApiException(this.type, this.message);

  @override
  String toString() => message;
}