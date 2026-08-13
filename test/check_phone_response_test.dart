import 'package:flutter_test/flutter_test.dart';
import 'package:adm_seller/modules/auth/models/check_phone_response.dart';
import 'package:adm_seller/core/shared/const/next_step_enum.dart';

void main() {
  group('CheckPhoneResponse parsing tests', () {
    test('Parse Response 1: Phone number not registered (ENTER_NAME)', () {
      final json = {
        "statusCode": 200,
        "message": "Phone number not registered",
        "response": {"nextStep": "ENTER_NAME"},
      };

      final response = CheckPhoneResponse.fromJson(json);

      expect(response.statusCode, 200);
      expect(response.message, "Phone number not registered");
      expect(response.nextStep, NextStep.enterName);
      expect(response.isSuccess, true);
      expect(response.isNewUser, true);
      expect(response.isExistingUser, false);
      expect(response.challengeToken, isNull);
    });

    test(
      'Parse Response 2: User exists, OTP sent successfully (OTP_VERIFICATION)',
      () {
        final json = {
          "statusCode": 200,
          "message": "User exists, OTP sent successfully",
          "response": {
            "nextStep": "OTP_VERIFICATION",
            "challengeToken":
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwaG9uZSI6Ijg0MzYxODkxODIiLCJuZXh0U3RlcCI6Ik9UUF9WRVJJRklDQVRJT04iLCJpYXQiOjE3ODYyOTQ2MDAsImV4cCI6MTc4NjI5NDkwMH0.ZJ4zrLxs9V_fkHbf-MXN896e867QD4n17A-dVKi_7kQ",
            "expiresInSeconds": 300,
            "cooldownSeconds": 60,
          },
        };

        final response = CheckPhoneResponse.fromJson(json);

        expect(response.statusCode, 200);
        expect(response.message, "User exists, OTP sent successfully");
        expect(response.nextStep, NextStep.otpVerification);
        expect(response.isSuccess, true);
        expect(response.isNewUser, false);
        expect(response.isExistingUser, true);
        expect(
          response.challengeToken,
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwaG9uZSI6Ijg0MzYxODkxODIiLCJuZXh0U3RlcCI6Ik9UUF9WRVJJRklDQVRJT04iLCJpYXQiOjE3ODYyOTQ2MDAsImV4cCI6MTc4NjI5NDkwMH0.ZJ4zrLxs9V_fkHbf-MXN896e867QD4n17A-dVKi_7kQ",
        );
        expect(response.expiresInSeconds, 300);
        expect(response.cooldownSeconds, 60);
      },
    );
  });
}
