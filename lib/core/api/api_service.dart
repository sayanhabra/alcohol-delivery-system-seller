import 'dart:convert';

import 'package:adm_seller/modules/auth/models/check_phone_response.dart';
import 'package:adm_seller/modules/auth/models/seller_profile_response.dart';
import 'package:adm_seller/modules/auth/models/send_otp_response.dart';
import 'package:adm_seller/modules/auth/models/verify_otp_request.dart';
import 'package:adm_seller/modules/auth/models/verify_otp_response.dart';
import 'package:adm_seller/modules/inventory/models/inventory_list_response.dart';
import 'package:adm_seller/modules/inventory/models/inventory_request_models.dart';
import 'package:adm_seller/modules/inventory/models/product_request_models.dart';
import 'package:adm_seller/modules/inventory/models/product_variant_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<InventoryListResponse> getInventory({
    int page = 1,
    int limit = 10,
  }) async {
    return _handler.get(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventorys}',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) => InventoryListResponse.fromJson(json),
      errorMessage: 'Failed to get inventory',
    );
  }

  Future<BaseResponseModel> updateInventory({
    required int inventoryId,
    required UpdateInventoryRequest request,
  }) async {
    return _handler.patch(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}'
          '${ApiEndpoints.inventorys}/$inventoryId',
      data: request.toJson(),
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to update inventory',
    );
  }

  Future<BaseResponseModel> deleteInventory(int inventoryId) async {
    return _handler.delete(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}'
          '${ApiEndpoints.inventorys}/$inventoryId',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to delete inventory',
    );
  }

  Future<BaseResponseModel> addProductVariant({
    required int productId,
    required AddProductVariantRequest request,
  }) async {
    return _handler.post(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}'
          '${ApiEndpoints.inventoryProducts}'
          '/$productId/variant',
      data: request.toJson(),
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to add product variant',
    );
  }

  Future<BaseResponseModel> searchInventoryCategories(String search) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryCategories}',
      queryParameters: {'search': search.trim()},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to search categories',
    );
  }

  Future<BaseResponseModel> searchInventoryBrands(String search) async {
    return _handler.get(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryBrands}',
      queryParameters: {'search': search.trim()},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to search brands',
    );
  }

  Future<BaseResponseModel> searchInventoryProducts(String search) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryProducts}',
      queryParameters: {'search': search.trim()},
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to search products',
    );
  }
  //================================================

  Future<BaseResponseModel> getInventoryProductDetails({
    required int productId,
  }) async {
    return _handler.get(
      endpoint:
          '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventoryProducts}/$productId',
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to load product details',
    );
  }

  Future<BaseResponseModel> submitInventory(Map<String, dynamic> data) async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventorys}',
      data: data,
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to add inventory',
    );
  }

  Future<BaseResponseModel> createProductRequest({
    required ProductRequestModel request,
    required List<XFile> images,
  }) async {
    final formData = FormData.fromMap({
      'name': request.name,
      'description': request.description,
      'brandId': request.brandId,
      'categoryId': request.categoryId,
      'alcoholType': request.alcoholType,
      'unit': request.unit,
      'alcoholPercentage': request.alcoholPercentage,
      'packagingType': request.packagingType,
      'exciseCategory': request.exciseCategory,
      'complianceInfo': request.complianceInfo,
      'status': request.status,

      'variants': jsonEncode(request.variants.map((e) => e.toJson()).toList()),

      'images': [
        for (final image in images)
          await MultipartFile.fromFile(image.path, filename: image.name),
      ],
    });

    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.inventorySubmit}',
      data: formData,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to create product',
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
