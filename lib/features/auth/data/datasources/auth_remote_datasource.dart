import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithPhoneCredential({
    required firebase_auth.PhoneAuthCredential credential,
    required String phone,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    List<String>? addresses,
  });
  Future<bool> isSignedIn();
  Future<bool> checkPhoneExists(String phone);
  Future<bool> checkEmailExists(String email);
  Stream<UserModel?> get authStateChanges;
  Future<void> saveFcmToken(String token);
  Future<String> uploadAvatar(String filePath);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final ApiClient apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.apiClient);

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final data = await apiClient.get(ApiConstants.profile);
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on NotFoundException {
      return _minimalUserModel(firebaseUser);
    } on NetworkException {
      return _minimalUserModel(firebaseUser);
    } catch (e) {
      throw ServerException('Erreur lors de la récupération de l\'utilisateur');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    firebase_auth.User? firebaseUser;
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = credential.user;
      if (firebaseUser == null) throw AuthException('Échec de la connexion');

      final data = await apiClient.get(ApiConstants.profile);
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } on AuthException {
      rethrow;
    } on NotFoundException catch (_) {
      return _minimalUserModel(firebaseUser!);
    } on NetworkException catch (_) {
      return _minimalUserModel(firebaseUser!);
    } on ServerException catch (_) {
      return _minimalUserModel(firebaseUser!);
    } catch (e) {
      throw AuthException('Erreur lors de la connexion');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw AuthException('Échec de l\'inscription');

      // Force-refresh the token right after creation so the backend
      // receives a fully-propagated Firebase ID token.
      await credential.user!.getIdToken(true);

      final data = await apiClient.put(
        ApiConstants.profile,
        data: {
          'name': name,
          if (phone != null) 'phone': _normalizePhone(phone),
        },
      );
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors de l\'inscription');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Connexion Google annulée');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw AuthException('Échec de la connexion Google');

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _ensureBackendProfile(
          name: firebaseUser.displayName ?? googleUser.displayName ?? 'Utilisateur',
          email: firebaseUser.email ?? googleUser.email,
          photoUrl: firebaseUser.photoURL,
        );
      }

      final data = await apiClient.get(ApiConstants.profile);
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors de la connexion Google');
    }
  }

  /// Crée ou met à jour le profil backend pour les nouveaux utilisateurs
  /// (Google, téléphone) qui n'ont pas encore de document côté serveur.
  /// Normalise un numéro vers le format E.164 (+225XXXXXXXXXX).
  static String _normalizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    return '+225$cleaned';
  }

  Future<void> _ensureBackendProfile({
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      await apiClient.put(ApiConstants.profile, data: {
        'name': name,
        'email': email,
        if (phone != null) 'phone': _normalizePhone(phone),
        if (photoUrl != null) 'photo_url': photoUrl,
      });
    } catch (_) {
      // Non-bloquant : si le profil existe déjà, l'API retournera les données
    }
  }

  /// Appelé par PhoneAuthRepository après vérification OTP réussie.
  /// Crée le profil backend si c'est un nouvel utilisateur téléphone.
  @override
  Future<UserModel> signInWithPhoneCredential({
    required firebase_auth.PhoneAuthCredential credential,
    required String phone,
  }) async {
    try {
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Échec de la vérification du code');
      }

      // Force-refresh pour que Firebase Admin SDK reconnaisse le nouveau compte
      await firebaseUser.getIdToken(true);

      await _ensureBackendProfile(
        name: firebaseUser.displayName ?? 'Utilisateur',
        email: firebaseUser.email ?? '',
        phone: phone,
      );

      try {
        final data = await apiClient.get(ApiConstants.profile);
        if (data == null) return _minimalUserModel(firebaseUser);
        return UserModel.fromJson(data as Map<String, dynamic>);
      } catch (_) {
        return _minimalUserModel(firebaseUser);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getPhoneErrorMessage(e.code), e.code);
    } on AuthException {
      rethrow;
    } on PhoneNewUserException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur lors de la vérification du code');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      apiClient.clearTokenCache();
      await Future.wait([
        firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Erreur lors de la déconnexion');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Erreur lors de la réinitialisation du mot de passe');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    List<String>? addresses,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = _normalizePhone(phone);

      final data = await apiClient.put(ApiConstants.profile, data: updates);
      return UserModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw AuthException('Erreur lors de la mise à jour du profil');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<bool> checkPhoneExists(String phone) async {
    final data = await apiClient.get(
      ApiConstants.checkPhone,
      queryParameters: {'phone': _normalizePhone(phone)},
    );
    return (data as Map<String, dynamic>)['exists'] as bool;
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    return false;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final data = await apiClient.get(ApiConstants.profile);
        return UserModel.fromJson(data as Map<String, dynamic>);
      } on NetworkException {
        // Backend injoignable : garder l'utilisateur connecté.
        return _minimalUserModel(firebaseUser);
      } on NotFoundException {
        // Profil backend inexistant (nouvel utilisateur OAuth).
        return _minimalUserModel(firebaseUser);
      } on AuthException {
        return _minimalUserModel(firebaseUser);
      } on ServerException {
        return _minimalUserModel(firebaseUser);
      } catch (_) {
        return _minimalUserModel(firebaseUser);
      }
    });
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum)';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cet email';
      case 'invalid-credential':
        return 'Identifiants invalides';
      default:
        return 'Une erreur s\'est produite';
    }
  }

  @override
  Future<void> saveFcmToken(String token) async {
    try {
      await apiClient.post('/profile/fcm-token', data: {'fcm_token': token});
    } catch (_) {
      // Non-bloquant
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final data = await apiClient.post('/users/me/avatar', data: formData);
    return (data as Map<String, dynamic>)['photoUrl'] as String;
  }

  UserModel _minimalUserModel(firebase_auth.User firebaseUser) => UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Utilisateur',
        phone: firebaseUser.phoneNumber,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );

  String _getPhoneErrorMessage(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Code de vérification incorrect';
      case 'session-expired':
        return 'Session expirée, veuillez réessayer';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide';
      default:
        return 'Erreur de vérification du code';
    }
  }
}
