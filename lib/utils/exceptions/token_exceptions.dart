class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Token has expired']);
  
  @override
  String toString() => message;
} 