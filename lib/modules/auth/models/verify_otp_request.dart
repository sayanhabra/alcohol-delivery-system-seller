// features/auth/models/verify_otp_request.dart

class VerifyOtpRequest {
  final String phone;
  final String code;
  final String? name;
  final String challengeToken;

  const VerifyOtpRequest({
    required this.phone,
    required this.code,
    this.name,
    required this.challengeToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'code': code,
      if (name != null && name!.isNotEmpty) 'name': name,
      'challengeToken': challengeToken,
    };
  }

  @override
  String toString() =>
      'VerifyOtpRequest(phone: $phone, code: $code, name: $name)';
}
