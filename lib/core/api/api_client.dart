// api/api_client.dart

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_endpoints.dart';
import 'dart:convert';

/// Supported authentication types
enum AuthType {
  none, // No auth header
  basic, // Basic base64(username:password)
  bearer, // Bearer <token>
  apiKey, // X-API-Key: <token>  (or custom header)
  custom, // Custom prefix, e.g., "Token <token>", "JWT <token>"
}

/// Auth configuration holder
class AuthConfig {
  final AuthType type;
  final String? token;
  final String? username; // For Basic auth
  final String? password; // For Basic auth
  final String? headerName; // For API Key (default: X-API-Key)
  final String? customPrefix; // For Custom type (e.g., "Token", "JWT")

  const AuthConfig._({
    required this.type,
    this.token,
    this.username,
    this.password,
    this.headerName,
    this.customPrefix,
  });

  /// No authentication
  factory AuthConfig.none() => const AuthConfig._(type: AuthType.none);

  /// Basic authentication
  factory AuthConfig.basic({
    required String username,
    required String password,
  }) {
    return AuthConfig._(
      type: AuthType.basic,
      username: username,
      password: password,
    );
  }

  /// Bearer token authentication
  factory AuthConfig.bearer(String token) {
    return AuthConfig._(type: AuthType.bearer, token: token);
  }

  /// API Key authentication
  factory AuthConfig.apiKey(String key, {String headerName = 'X-API-Key'}) {
    return AuthConfig._(
      type: AuthType.apiKey,
      token: key,
      headerName: headerName,
    );
  }

  /// Custom prefix authentication (e.g., "Token <token>", "JWT <token>")
  factory AuthConfig.custom(String token, {required String prefix}) {
    return AuthConfig._(
      type: AuthType.custom,
      token: token,
      customPrefix: prefix,
    );
  }

  /// Build the auth header value
  String? get headerValue {
    switch (type) {
      case AuthType.none:
        return null;
      case AuthType.basic:
        if (username == null || password == null) return null;
        return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      case AuthType.bearer:
        if (token == null || token!.isEmpty) return null;
        return 'Bearer $token';
      case AuthType.apiKey:
        return null; // API Key uses a different header
      case AuthType.custom:
        if (token == null || customPrefix == null) return null;
        return '$customPrefix $token';
    }
  }

  /// Get the header name for API Key auth
  String? get apiKeyHeaderName {
    if (type == AuthType.apiKey) return headerName ?? 'X-API-Key';
    return null;
  }

  /// Get the header value for API Key auth
  String? get apiKeyHeaderValue {
    if (type == AuthType.apiKey) return token;
    return null;
  }
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  bool _isInitialized = false;

  // Default Basic Auth credentials (fallback)
  static const String _defaultUsername = 'alba_admin';
  static const String _defaultPassword = 'Albat@432!';

  // Current auth configuration
  AuthConfig _authConfig = AuthConfig.basic(
    username: _defaultUsername,
    password: _defaultPassword,
  );

  // ==================== INITIALIZATION ====================

  void init() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _setupInterceptors();
    _isInitialized = true;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Apply current auth configuration
          _applyAuth(options);

          // print('➡️ [${options.method}] ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // print('✅ [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          // print('❌ [${error.response?.statusCode}] ${error.requestOptions.uri}');

          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Apply auth headers based on current config
  void _applyAuth(RequestOptions options) {
    // Remove any existing auth headers to avoid conflicts
    options.headers.remove('Authorization');
    options.headers.remove('X-API-Key');

    switch (_authConfig.type) {
      case AuthType.none:
        // No auth headers added
        break;

      case AuthType.basic:
      case AuthType.bearer:
      case AuthType.custom:
        final value = _authConfig.headerValue;
        if (value != null) {
          options.headers['Authorization'] = value;
        }
        break;

      case AuthType.apiKey:
        final headerName = _authConfig.apiKeyHeaderName;
        final headerValue = _authConfig.apiKeyHeaderValue;
        if (headerName != null && headerValue != null) {
          options.headers[headerName] = headerValue;
        }
        break;
    }
  }

  // ==================== AUTH CONFIGURATION ====================

  /// Set authentication configuration dynamically
  void setAuth(AuthConfig config) {
    _authConfig = config;
  }

  /// Quick setter for Bearer token
  void setBearerToken(String token) {
    _authConfig = AuthConfig.bearer(token);
  }

  /// Quick setter for Basic auth
  void setBasicAuth(String username, String password) {
    _authConfig = AuthConfig.basic(username: username, password: password);
  }

  /// Quick setter for API Key
  void setApiKey(String key, {String headerName = 'X-API-Key'}) {
    _authConfig = AuthConfig.apiKey(key, headerName: headerName);
  }

  /// Quick setter for Custom prefix (e.g., "Token", "JWT")
  void setCustomAuth(String token, {required String prefix}) {
    _authConfig = AuthConfig.custom(token, prefix: prefix);
  }

  /// Remove all authentication (public endpoints)
  void clearAuth() {
    _authConfig = AuthConfig.none();
  }

  /// Reset to default Basic auth
  void resetToDefaultAuth() {
    _authConfig = AuthConfig.basic(
      username: _defaultUsername,
      password: _defaultPassword,
    );
  }

  // ==================== GETTERS ====================

  Dio get dio {
    if (!_isInitialized) init();
    return _dio;
  }

  AuthConfig get currentAuth => _authConfig;
  AuthType get currentAuthType => _authConfig.type;
  bool get isAuthenticated => _authConfig.type != AuthType.none;

  // ==================== PRIVATE ====================

  Future<void> _handleUnauthorized() async {
    clearAuth();
    // TODO: Navigate to login or trigger logout event
  }
}
