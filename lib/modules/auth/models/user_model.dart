import 'verification_status_enum.dart';

class UserModel {
  final int id;
  final String phone;
  final String name;
  final String? email;
  final String? profileImage;
  final String role;
  final VerificationStatus verificationStatus;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    this.email,
    this.profileImage,
    required this.role,
    required this.verificationStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      role: json['role'] as String? ?? 'SELLER',
      verificationStatus: VerificationStatus.fromString(
        json['verificationStatus'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'verificationStatus': verificationStatus.value,
    };
  }

  UserModel copyWith({
    int? id,
    String? phone,
    String? name,
    String? email,
    String? profileImage,
    String? role,
    VerificationStatus? verificationStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, phone: $phone, status: ${verificationStatus.value})';
}
