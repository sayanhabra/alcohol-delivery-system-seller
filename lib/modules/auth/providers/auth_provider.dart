// features/auth/providers/auth_provider.dart

import 'package:adm_seller/core/api/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/next_step_enum.dart';
import '../models/user_model.dart';
import '../models/verify_otp_request.dart';

// ==================== PROVIDERS ====================

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final state = auth.asData?.value;
  return state is AuthAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return (auth.asData?.value as AuthAuthenticated?)?.user;
});

// ==================== TOKEN STORAGE ====================

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}

// ==================== STATE MODELS ====================

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthPhoneChecked extends AuthState {
  final String phoneNumber;
  final NextStep nextStep;
  const AuthPhoneChecked(this.phoneNumber, {required this.nextStep});
}

class AuthOtpSent extends AuthState {
  final String phoneNumber;
  final String? name;
  final String challengeToken;
  final int cooldownSeconds;
  const AuthOtpSent({
    required this.phoneNumber,
    this.name,
    required this.challengeToken,
    required this.cooldownSeconds,
  });
}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final UserModel user;
  const AuthAuthenticated({required this.accessToken, required this.user});
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated({this.message});
}

// ==================== NOTIFIER ====================

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final ApiService _apiService;
  late final TokenStorage _tokenStorage;

  @override
  Future<AuthState> build() async {
    _apiService = ref.read(apiServiceProvider);
    _tokenStorage = TokenStorage();
    return await _tryAutoLogin();
  }

  Future<AuthState> _tryAutoLogin() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) return const AuthUnauthenticated();

      _apiService.setBearerToken(accessToken);
      final profileRes = await _apiService.getProfile();

      return AuthAuthenticated(
        accessToken: accessToken,
        user: UserModel.fromJson(profileRes.data ?? {}),
      );
    } catch (e) {
      await _tokenStorage.clearTokens();
      _apiService.clearAuth();
      return const AuthUnauthenticated();
    }
  }

  Future<void> checkPhone(String phoneNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final response = await _apiService.checkPhone(phoneNumber);

        // Existing user: backend already sent OTP in check-phone response
        if (response.isExistingUser) {
          return AuthOtpSent(
            phoneNumber: phoneNumber,
            name: null,
            challengeToken: response.challengeToken ?? '',
            cooldownSeconds: response.cooldownSeconds ?? 60,
          );
        }

        // New user: show name input first
        return AuthPhoneChecked(phoneNumber, nextStep: response.nextStep);
      } catch (e) {
        return AuthUnauthenticated(message: e.toString());
      }
    });
  }

  Future<void> sendOtp({required String phone, String? name}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final response = await _apiService.sendOtp(phone: phone, name: name);
        return AuthOtpSent(
          phoneNumber: phone,
          name: name,
          challengeToken: response.challengeToken,
          cooldownSeconds: response.cooldownSeconds,
        );
      } catch (e) {
        final prev = state.asData?.value;
        if (prev is AuthPhoneChecked) return prev;
        return AuthUnauthenticated(message: e.toString());
      }
    });
  }

  Future<void> verifyOtp({
    required String phone,
    required String code,
    String? name,
    required String challengeToken,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final request = VerifyOtpRequest(
          phone: phone,
          code: code,
          name: name,
          challengeToken: challengeToken,
        );
        final response = await _apiService.verifyOtp(request);
        final accessToken = response.accessToken;

        await _tokenStorage.saveTokens(accessToken, null);
        _apiService.setBearerToken(accessToken);

        return AuthAuthenticated(accessToken: accessToken, user: response.user);
      } catch (e) {
        final prev = state.asData?.value;
        if (prev is AuthOtpSent) return prev;
        return AuthUnauthenticated(message: e.toString());
      }
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await _apiService.logout();
      } catch (_) {}
      await _tokenStorage.clearTokens();
      _apiService.clearAuth();
      return const AuthUnauthenticated();
    });
  }
}
