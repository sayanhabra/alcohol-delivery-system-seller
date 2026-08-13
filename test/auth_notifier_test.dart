import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adm_seller/modules/auth/providers/auth_provider.dart';
import 'package:adm_seller/modules/auth/models/check_phone_response.dart';
import 'package:adm_seller/core/shared/const/next_step_enum.dart';
import 'package:adm_seller/core/api/api_service.dart';

class MockApiService extends ApiService {
  CheckPhoneResponse? mockCheckPhoneResponse;
  Object? checkPhoneError;

  @override
  Future<CheckPhoneResponse> checkPhone(String phoneNumber) async {
    if (checkPhoneError != null) {
      throw checkPhoneError!;
    }
    if (mockCheckPhoneResponse != null) {
      return mockCheckPhoneResponse!;
    }
    throw UnimplementedError('Mock checkPhone response not set');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService mockApiService;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier checkPhone Tests', () {
    test('checkPhone - Unregistered/New User (ENTER_NAME)', () async {
      mockApiService.mockCheckPhoneResponse = CheckPhoneResponse.fromJson({
        "statusCode": 200,
        "message": "Phone number not registered",
        "response": {"nextStep": "ENTER_NAME"},
      });

      final notifier = container.read(authNotifierProvider.notifier);

      // Trigger phone check
      await notifier.checkPhone('+919876543210');

      // Verify final state
      final authState = container.read(authNotifierProvider).asData?.value;
      expect(authState, isA<AuthPhoneChecked>());
      final phoneCheckedState = authState as AuthPhoneChecked;
      expect(phoneCheckedState.phoneNumber, '+919876543210');
      expect(phoneCheckedState.nextStep, NextStep.enterName);
    });

    test('checkPhone - Existing User (OTP_VERIFICATION)', () async {
      mockApiService.mockCheckPhoneResponse = CheckPhoneResponse.fromJson({
        "statusCode": 200,
        "message": "User exists, OTP sent successfully",
        "response": {
          "nextStep": "OTP_VERIFICATION",
          "challengeToken": "mock_token",
          "expiresInSeconds": 300,
          "cooldownSeconds": 60,
        },
      });

      final notifier = container.read(authNotifierProvider.notifier);

      // Trigger phone check
      await notifier.checkPhone('+919876543210');

      // Verify final state
      final authState = container.read(authNotifierProvider).asData?.value;
      expect(authState, isA<AuthOtpSent>());
      final otpSentState = authState as AuthOtpSent;
      expect(otpSentState.phoneNumber, '+919876543210');
      expect(otpSentState.challengeToken, 'mock_token');
      expect(otpSentState.cooldownSeconds, 60);
    });

    test('checkPhone - API Failure', () async {
      mockApiService.checkPhoneError = Exception('Network error');

      final notifier = container.read(authNotifierProvider.notifier);

      // Trigger phone check
      await notifier.checkPhone('+919876543210');

      // Verify final state is AuthUnauthenticated with error message
      final authState = container.read(authNotifierProvider).asData?.value;
      expect(authState, isA<AuthUnauthenticated>());
      final unauthState = authState as AuthUnauthenticated;
      expect(unauthState.message, contains('Network error'));
    });
  });
}
