import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_endpoints.dart';
import 'dart:convert';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio dio;

  // Static Basic Auth credentials
  static const String _apiUsername = 'alba_admin';
  static const String _apiPassword = 'Albat@432!';

  String? _bearerToken;
  bool _isInitialized = false;

  // Initialize the API client
  void init() {
    if (_isInitialized) return;

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$_apiUsername:$_apiPassword'))}';

    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': basicAuth,
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Always add Basic Auth
          final basicAuth =
              'Basic ${base64Encode(utf8.encode('$_apiUsername:$_apiPassword'))}';
          options.headers['Authorization'] = basicAuth;

          // Add Bearer token if available
          if (_bearerToken != null) {
            options.headers['Authorization'] = 'Bearer $_bearerToken';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );

    // Add logger
    dio.interceptors.add(
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

    _isInitialized = true;
  }

  void setBearerToken(String token) {
    _bearerToken = token;
    if (_isInitialized) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void clearBearerToken() {
    _bearerToken = null;
    if (_isInitialized) {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$_apiUsername:$_apiPassword'))}';
      dio.options.headers['Authorization'] = basicAuth;
    }
  }

  void _handleUnauthorized() {
    clearBearerToken();
    // Navigate to login
  }

  // Get Dio instance (with initialization check)
  Dio get dioInstance {
    if (!_isInitialized) {
      init();
    }
    return dio;
  }
}
