import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Centralized HTTP client that talks to the Flask backend.
///
/// Automatically injects the Firebase ID token in every request.
@lazySingleton
class ApiClient {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  String? _cachedToken;
  DateTime? _tokenExpiry;

  ApiClient(this._firebaseAuth)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  // ── Interceptors ─────────────────────────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    AppLogger.debug('API → ${options.method} ${options.uri}');
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      AppLogger.warning('API: no Firebase user — request sent without token');
      handler.next(options);
      return;
    }
    final token = await _getToken(user);
    if (token == null || token.isEmpty) {
      AppLogger.warning('API: getIdToken() returned null/empty');
      handler.next(options);
      return;
    }
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    AppLogger.error('API error: ${error.type} ${error.message}');
    handler.next(error);
  }

  Future<String?> _getToken(User user) async {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(minutes: 5)),
        )) {
      return _cachedToken;
    }
    final token = await user.getIdToken();
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    }
    return token;
  }

  void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }

  // ── Public helpers ───────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () => _dio.get(path, queryParameters: queryParameters),
    );
    return response;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final response = await _request(() => _dio.post(path, data: data));
    return response;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final response = await _request(() => _dio.put(path, data: data));
    return response;
  }

  Future<dynamic> delete(String path) async {
    final response = await _request(() => _dio.delete(path));
    return response;
  }

  // ── Internal ─────────────────────────────────────────────────────────

  Future<dynamic> _request(Future<Response> Function() call) async {
    try {
      final response = await call();
      final body = response.data;

      // 204 No Content
      if (response.statusCode == 204 || body == null) return null;

      if (body is Map && body['success'] == true) {
        return body['data'];
      }

      // If the backend returned an error message
      final errorMsg =
          (body is Map ? body['error'] : null) ?? 'Erreur serveur';
      throw ServerException(errorMsg);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException('Délai de connexion dépassé');
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException('Impossible de joindre le serveur');
    }

    final statusCode = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg =
        (body is Map ? body['error'] : null) as String? ?? '';

    switch (statusCode) {
      case 401:
        throw AuthException(
          serverMsg.isNotEmpty ? serverMsg : 'Non autorisé',
        );
      case 403:
        throw AuthException(
          serverMsg.isNotEmpty ? serverMsg : 'Accès refusé',
        );
      case 404:
        throw NotFoundException(
          serverMsg.isNotEmpty ? serverMsg : 'Ressource introuvable',
        );
      case 422:
        throw ValidationException(
          serverMsg.isNotEmpty ? serverMsg : 'Données invalides',
        );
      default:
        throw ServerException(
          serverMsg.isNotEmpty ? serverMsg : 'Erreur serveur ($statusCode)',
        );
    }
  }
}
