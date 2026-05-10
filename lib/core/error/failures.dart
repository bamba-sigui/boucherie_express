import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server/Network related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur s\'est produite']);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local']);
}

/// Authentication related failures
class AuthFailure extends Failure {
  final String? code;
  const AuthFailure([super.message = 'Erreur d\'authentification', this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet']);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides']);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable']);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission refusée']);
}

/// Google sign-in detected a new (unregistered) user
class NewGoogleUserFailure extends Failure {
  final String email;
  final String name;
  final String? photoUrl;

  const NewGoogleUserFailure({
    required this.email,
    required this.name,
    this.photoUrl,
  }) : super('Nouvel utilisateur Google');

  @override
  List<Object?> get props => [message, email, name, photoUrl];
}

/// Phone OTP verified but no existing account → redirect to signup
class PhoneNewUserFailure extends Failure {
  final String phone;
  const PhoneNewUserFailure(this.phone) : super('Numéro non enregistré');

  @override
  List<Object?> get props => [message, phone];
}

/// Unknown/Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Une erreur inattendue s\'est produite',
  ]);
}
