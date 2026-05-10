import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/phone_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implémentation Firebase Phone Auth.
///
/// Flow :
///   1. requestOtp(phone)  → Firebase.verifyPhoneNumber → SMS envoyé
///   2. verifyOtp(phone, code) → PhoneAuthCredential → signInWithCredential
///      → authStateChanges stream déclenché → AuthBloc.Authenticated
///   3. resendOtp(phone)   → re-déclenche verifyPhoneNumber
@LazySingleton(as: PhoneAuthRepository)
class PhoneAuthRepositoryImpl implements PhoneAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final AuthRemoteDataSource _authDataSource;

  String? _verificationId;
  int? _resendToken;

  PhoneAuthRepositoryImpl(this._firebaseAuth, this._authDataSource);

  @override
  Future<Either<Failure, void>> requestOtp(String phone) async {
    return _sendVerificationCode(phone);
  }

  @override
  Future<Either<Failure, void>> resendOtp(String phone) async {
    return _sendVerificationCode(phone, resendToken: _resendToken);
  }

  Future<Either<Failure, void>> _sendVerificationCode(
    String phone, {
    int? resendToken,
  }) async {
    final completer = Completer<Either<Failure, void>>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        // Côte d'Ivoire : +225 suivi des 10 chiffres
        phoneNumber: '+225$phone',
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),

        // Android : auto-vérification détectée
        verificationCompleted: (credential) async {
          try {
            await _authDataSource.signInWithPhoneCredential(
              credential: credential,
              phone: phone,
            );
            if (!completer.isCompleted) {
              completer.complete(const Right(null));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(Left(AuthFailure(e.toString())));
            }
          }
        },

        // Erreur Firebase (quota, numéro invalide…)
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.complete(Left(AuthFailure(_getPhoneErrorMessage(e.code))));
          }
        },

        // SMS envoyé → stocker le verificationId
        codeSent: (verificationId, resendTokenNew) {
          _verificationId = verificationId;
          _resendToken = resendTokenNew;
          if (!completer.isCompleted) {
            completer.complete(const Right(null));
          }
        },

        // Timeout sans auto-vérification → garder le verificationId
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(Left(AuthFailure('Erreur lors de l\'envoi du code')));
      }
    }

    return completer.future;
  }

  @override
  Future<Either<Failure, User>> verifyOtp(String phone, String code) async {
    try {
      if (_verificationId == null) {
        return const Left(
          AuthFailure('Session expirée, veuillez renvoyer le code'),
        );
      }

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final user = await _authDataSource.signInWithPhoneCredential(
        credential: credential,
        phone: phone,
      );

      return Right(user);
    } on PhoneNewUserException catch (e) {
      return Left(PhoneNewUserFailure(e.phone));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Code de vérification incorrect'));
    }
  }

  String _getPhoneErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'quota-exceeded':
        return 'Quota SMS dépassé, réessayez plus tard';
      case 'app-not-authorized':
        return 'Application non autorisée pour Phone Auth';
      default:
        return 'Erreur lors de l\'envoi du code SMS';
    }
  }
}
