/// Base class for all exceptions in the app
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server/API exceptions
class ServerException extends AppException {
  ServerException([super.message = 'Erreur serveur', super.code]);
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException([super.message = 'Erreur de cache', super.code]);
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException([super.message = 'Erreur d\'authentification', super.code]);
}

/// Network exceptions
class NetworkException extends AppException {
  NetworkException([super.message = 'Pas de connexion internet', super.code]);
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException([super.message = 'Données invalides', super.code]);
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException([super.message = 'Ressource introuvable', super.code]);
}

/// Phone OTP verified but no existing account found → redirect to signup
class PhoneNewUserException implements Exception {
  final String phone;
  const PhoneNewUserException(this.phone);
}

/// Google sign-in detected a new (unregistered) user
class NewGoogleUserException implements Exception {
  final String email;
  final String name;
  final String? photoUrl;

  const NewGoogleUserException({
    required this.email,
    required this.name,
    this.photoUrl,
  });
}
