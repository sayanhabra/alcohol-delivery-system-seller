// features/auth/models/send_otp_response.dart

import 'next_step_enum.dart';

class SendOtpResponseData {
  final NextStep nextStep;
  final String challengeToken;
  final int expiresInSeconds;
  final int cooldownSeconds;

  const SendOtpResponseData({
    required this.nextStep,
    required this.challengeToken,
    required this.expiresInSeconds,
    required this.cooldownSeconds,
  });

  factory SendOtpResponseData.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseData(
      nextStep: NextStep.fromString(json['nextStep'] as String?),
      challengeToken: json['challengeToken'] as String? ?? '',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 300,
      cooldownSeconds: json['cooldownSeconds'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextStep': nextStep.value,
      'challengeToken': challengeToken,
      'expiresInSeconds': expiresInSeconds,
      'cooldownSeconds': cooldownSeconds,
    };
  }
}

class SendOtpResponse {
  final int statusCode;
  final String message;
  final SendOtpResponseData response;

  const SendOtpResponse({
    required this.statusCode,
    required this.message,
    required this.response,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      response: SendOtpResponseData.fromJson(
        json['response'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'response': response.toJson(),
    };
  }

  bool get isSuccess => statusCode == 200;
  String get challengeToken => response.challengeToken;
  int get expiresInSeconds => response.expiresInSeconds;
  int get cooldownSeconds => response.cooldownSeconds;
}
