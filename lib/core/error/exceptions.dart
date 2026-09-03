class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error']);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}
