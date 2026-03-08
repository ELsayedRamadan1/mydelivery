/// Server Exception
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Network Exception
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'لا يوجد اتصال بالإنترنت'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Cache Exception
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Auth Exception
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Validation Exception
class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
