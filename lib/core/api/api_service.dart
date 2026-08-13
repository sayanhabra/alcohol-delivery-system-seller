import 'package:adm_seller/modules/auth/models/check_phone_response.dart';
import 'package:adm_seller/modules/auth/models/seller_profile_response.dart';
import 'package:adm_seller/modules/auth/models/send_otp_response.dart';
import 'package:adm_seller/modules/auth/models/verify_otp_request.dart';
import 'package:adm_seller/modules/auth/models/verify_otp_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_handler.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  late final ApiHandler _handler;
  late final ApiClient _client;

  ApiService() {
    _client = ApiClient();
    _handler = ApiHandler(dio: _client.dio);
  }

  // ==================== AUTH CONFIG ====================

  void setBearerToken(String token) => _client.setBearerToken(token);
  void clearAuth() => _client.clearAuth();

  // ==================== SELLER AUTH ====================

  /// POST /seller/auth/check-phone
  Future<CheckPhoneResponse> checkPhone(String phoneNumber) async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.checkPhoneNo}',
      data: {'phone': phoneNumber},
      contentType: RequestContentType.json,
      fromJson: (json) => CheckPhoneResponse.fromJson(json),
      errorMessage: 'Failed to check phone number',
    );
  }

  /// POST /seller/auth/send-otp
  /// [phone] is mandatory, [name] is optional (for new users)
  Future<SendOtpResponse> sendOtp({required String phone, String? name}) async {
    final data = {'phone': phone};
    if (name != null && name.isNotEmpty) {
      data['name'] = name;
    }

    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.sendOtp}',
      data: data,
      contentType: RequestContentType.json,
      fromJson: (json) => SendOtpResponse.fromJson(json),
      errorMessage: 'Failed to send OTP',
    );
  }

  /// POST /seller/auth/verify-otp
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.varifyOtp}',
      data: request.toJson(),
      contentType: RequestContentType.json,
      fromJson: (json) => VerifyOtpResponse.fromJson(json),
      errorMessage: 'Failed to verify OTP',
    );
  }

  /// POST /seller/auth/refresh
  Future<BaseResponseModel> refreshToken(String refreshToken) async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.authRefresh}',
      data: {'refreshToken': refreshToken},
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to refresh token',
    );
  }

  /// POST /seller/auth/logout
  Future logout() async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.logout}',
      data: {},
      contentType: RequestContentType.json,
      extra: {'skipAuth': false, 'skipRefresh': true},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Logout failed',
    );
  }

  /// GET /seller/auth/status
  Future<BaseResponseModel> getAuthStatus() async {
    return _handler.get(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.authStatus}',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to get auth status',
    );
  }

  /// GET /seller/auth/profile
  Future<BaseResponseModel> getProfile() async {
    return _handler.get(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.getProfile}',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to get profile',
    );
  }

  /// PUT /seller/auth/profile
  Future<SellerProfileResponse> updateProfile(Map<String, dynamic> data) async {
    return _handler.put(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.updateProfile}',
      data: data,
      contentType: RequestContentType.json,
      fromJson: (json) => SellerProfileResponse.fromJson(json),
      errorMessage: 'Failed to update profile',
    );
  }

  /// PATCH /seller/auth/profile-image
  Future<BaseResponseModel> updateProfileImage(String imageFilePath) async {
    return _handler.uploadFile(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.profileImage}',
      filePath: imageFilePath,
      fileKey: 'profile_image',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to update profile image',
    );
  }

  /// POST /seller/auth/profile/documents
  Future<BaseResponseModel> uploadProfileDocument(
    String filePath, {
    String fileKey = 'document',
    Map<String, dynamic>? extraData,
  }) async {
    return _handler.uploadFile(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.profileDocs}',
      filePath: filePath,
      fileKey: fileKey,
      additionalData: extraData,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to upload document',
    );
  }

  /// PATCH /seller/auth/stores-status
  Future<BaseResponseModel> toggleStoreStatus(bool isOpen) async {
    return _handler.patch(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.storeStatus}',
      data: {'is_open': isOpen},
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to toggle store status',
    );
  }

  // ==================== INVENTORY ====================

  Future<BaseResponseModel> searchInventoryCategories(String search) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryCategories}',
      queryParameters: {'search': search},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to search categories',
    );
  }

  Future<BaseResponseModel> getInventoryBrands({
    required int categoryId,
  }) async {
    return _handler.get(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryBrands}',
      queryParameters: {'category_id': categoryId},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to load brands',
    );
  }

  Future<BaseResponseModel> getInventoryProducts({
    required int brandId,
    String search = '',
  }) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryProducts}',
      queryParameters: {
        'brand_id': brandId,
        if (search.isNotEmpty) 'search': search,
      },
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to load products',
    );
  }

  Future<BaseResponseModel> getInventoryProductDetails({
    required int productId,
  }) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryProductDetails}/$productId',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to load product details',
    );
  }

  Future<BaseResponseModel> submitInventory(Map<String, dynamic> data) async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventorySubmit}',
      data: data,
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to add inventory',
    );
  }
}

class BaseResponseModel {
  final bool? success;
  final String? message;
  final dynamic data;
  final int? statusCode;

  BaseResponseModel({this.success, this.message, this.data, this.statusCode});

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      success: json['success'] ?? json['status'] == 'success',
      message: json['message'] ?? json['msg'] ?? json['detail'],
      data: json['data'] ?? json,
      statusCode: json['status_code'] ?? json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'status_code': statusCode,
    };
  }
}
