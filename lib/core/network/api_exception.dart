class ApiException implements Exception {
  const ApiException({
    required this.userMessage,
    this.developerMessage,
    this.statusCode,
    this.isNetworkError = false,
  });

  final String userMessage;
  final String? developerMessage;
  final int? statusCode;
  final bool isNetworkError;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $userMessage)';
}