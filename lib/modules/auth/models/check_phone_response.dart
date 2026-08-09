// // features/auth/models/check_phone_response.dart

// import 'next_step_enum.dart';

// class CheckPhoneResponse {
//   final int statusCode;
//   final String message;
//   final NextStep nextStep;

//   const CheckPhoneResponse({
//     required this.statusCode,
//     required this.message,
//     required this.nextStep,
//   });

//   factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
//     final responseData = json['response'] as Map<String, dynamic>?;
//     return CheckPhoneResponse(
//       statusCode: json['statusCode'] as int? ?? 0,
//       message: json['message'] as String? ?? '',
//       nextStep: NextStep.fromString(responseData?['nextStep'] as String?),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'statusCode': statusCode,
//       'message': message,
//       'response': {'nextStep': nextStep.value},
//     };
//   }

//   bool get isSuccess => statusCode == 200;
//   bool get isNewUser => nextStep.isEnterName;
//   bool get isExistingUser => nextStep.isOtpVerification;

//   @override
//   String toString() =>
//       'CheckPhoneResponse(statusCode: $statusCode, nextStep: ${nextStep.value})';
// }

// features/auth/models/check_phone_response.dart

import 'next_step_enum.dart';

class CheckPhoneResponse {
  final int statusCode;
  final String message;
  final NextStep nextStep;
  final String? challengeToken;
  final int? expiresInSeconds;
  final int? cooldownSeconds;

  const CheckPhoneResponse({
    required this.statusCode,
    required this.message,
    required this.nextStep,
    this.challengeToken,
    this.expiresInSeconds,
    this.cooldownSeconds,
  });

  factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] as Map<String, dynamic>?;
    return CheckPhoneResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      nextStep: NextStep.fromString(responseData?['nextStep'] as String?),
      challengeToken: responseData?['challengeToken'] as String?,
      expiresInSeconds: responseData?['expiresInSeconds'] as int?,
      cooldownSeconds: responseData?['cooldownSeconds'] as int?,
    );
  }

  bool get isSuccess => statusCode == 200;
  bool get isNewUser => nextStep.isEnterName;
  bool get isExistingUser => nextStep.isOtpVerification;
}
