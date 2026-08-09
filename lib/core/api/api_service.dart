// // api/api_service.dart

// import 'package:albatross_project_management_system/features/auth/models/login_response.dart';
// import 'package:albatross_project_management_system/features/home/models/add_task_response_model.dart';
// import 'package:albatross_project_management_system/features/home/models/member_dashboard_model.dart';
// import 'package:albatross_project_management_system/features/home/models/member_task_list_response_model.dart';
// import 'package:albatross_project_management_system/features/home/models/task_details_work_list_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'api_client.dart';
// import 'api_endpoints.dart';
// import 'api_handler.dart';

// final apiServiceProvider = Provider<ApiService>((ref) {
//   return ApiService();
// });

// class ApiService {
//   late final ApiHandler _handler;
//   late final ApiClient _client;

//   ApiService() {
//     _client = ApiClient();
//     _handler = ApiHandler(dio: _client.dio);
//   }

//   // ==================== AUTH CONFIG HELPERS ====================

//   /// Switch to Bearer token auth (e.g., after login)
//   void setBearerToken(String token) => _client.setBearerToken(token);

//   /// Switch to Basic auth
//   void setBasicAuth(String username, String password) =>
//       _client.setBasicAuth(username, password);

//   /// Switch to API Key auth
//   void setApiKey(String key, {String headerName = 'X-API-Key'}) =>
//       _client.setApiKey(key, headerName: headerName);

//   /// Switch to custom prefix auth (e.g., "Token", "JWT")
//   void setCustomAuth(String token, {required String prefix}) =>
//       _client.setCustomAuth(token, prefix: prefix);

//   /// Use full AuthConfig for any combination
//   void setAuth(AuthConfig config) => _client.setAuth(config);

//   /// Remove auth (for public endpoints)
//   void clearAuth() => _client.clearAuth();

//   /// Reset to default Basic auth
//   void resetAuth() => _client.resetToDefaultAuth();

//   // ==================== AUTH ====================

//   Future<LoginResponse> login(String username, String password) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.login,
//       data: {'username': username, 'password': password},
//       fromJson: (json) => LoginResponse.fromJson(json),
//       errorMessage: 'Login failed',
//     );
//   }

//   // ==================== DASHBOARD ====================

//   Future<MemberDashboardModel> memberDashboard(String memberId) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.memberDashboard,
//       data: {'member_id': memberId},
//       fromJson: (json) => MemberDashboardModel.fromJson(json),
//       errorMessage: 'Failed to load dashboard',
//     );
//   }

//   // ==================== TASKS ====================

//   Future<MemberTaskListResponse> memberTaskList(String memberId) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.memberTaskList,
//       data: {'member_id': memberId},
//       fromJson: (json) => MemberTaskListResponse.fromJson(json),
//       errorMessage: 'Failed to load task list',
//     );
//   }

//   Future<TaskDetailsWorkListModel> taskDetailsWorkList(String taskId) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.taskDetailWorkList,
//       data: {'task_id': taskId},
//       fromJson: (json) => TaskDetailsWorkListModel.fromJson(json),
//       errorMessage: 'Failed to load task details',
//     );
//   }

//   Future<AddTaskResponseModel> addDailyTask(
//     int memberId,
//     int taskId,
//     int jobId,
//     String workName,
//     String workDesc,
//     String startTime,
//     String endTime,
//     String workDate,
//     String workOpt,
//     String permitBy,
//     String workReason,
//   ) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.addTaskWork,
//       data: {
//         'member_id': memberId,
//         'task_id': taskId,
//         'job_id': jobId,
//         'work_name': workName,
//         'work_description': workDesc,
//         'start_time': startTime,
//         'end_time': endTime,
//         'work_date': workDate,
//         'work_option': workOpt,
//         'permit_by': permitBy,
//         'work_reason': workReason,
//       },
//       fromJson: (json) => AddTaskResponseModel.fromJson(json),
//       errorMessage: 'Failed to add new task',
//     );
//   }

//   // ==================== EXAMPLES: OTHER METHODS ====================

//   /*
//   // ─── GET with query params ─────────────────────────────────────────────
//   Future<ProjectListResponse> getProjects({
//     String? status,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     return _handler.get(
//       endpoint: ApiEndpoints.projects,
//       queryParameters: {
//         if (status != null) 'status': status,
//         'page': page,
//         'limit': limit,
//       },
//       fromJson: (json) => ProjectListResponse.fromJson(json),
//       errorMessage: 'Failed to load projects',
//     );
//   }

//   // ─── GET with path param ───────────────────────────────────────────────
//   Future<ProjectDetailResponse> getProjectDetail(int projectId) async {
//     return _handler.get(
//       endpoint: '${ApiEndpoints.projects}/$projectId',
//       fromJson: (json) => ProjectDetailResponse.fromJson(json),
//       errorMessage: 'Failed to load project details',
//     );
//   }

//   // ─── PUT (update) ──────────────────────────────────────────────────────
//   Future<UpdateResponse> updateProfile(Map<String, dynamic> data) async {
//     return _handler.put(
//       endpoint: ApiEndpoints.updateProfile,
//       data: data,
//       contentType: RequestContentType.json,
//       fromJson: (json) => UpdateResponse.fromJson(json),
//       errorMessage: 'Failed to update profile',
//     );
//   }

//   // ─── DELETE ────────────────────────────────────────────────────────────
//   Future<DeleteResponse> deleteTask(int taskId) async {
//     return _handler.delete(
//       endpoint: '${ApiEndpoints.tasks}/$taskId',
//       fromJson: (json) => DeleteResponse.fromJson(json),
//       errorMessage: 'Failed to delete task',
//     );
//   }

//   // ─── PATCH ─────────────────────────────────────────────────────────────
//   Future<TaskResponse> updateTaskStatus(int taskId, String status) async {
//     return _handler.patch(
//       endpoint: '${ApiEndpoints.tasks}/$taskId',
//       data: {'status': status},
//       contentType: RequestContentType.json,
//       fromJson: (json) => TaskResponse.fromJson(json),
//       errorMessage: 'Failed to update task status',
//     );
//   }

//   // ─── UPLOAD SINGLE FILE ────────────────────────────────────────────────
//   Future<UploadResponse> uploadProfileImage(String filePath, int userId) async {
//     return _handler.uploadFile(
//       endpoint: ApiEndpoints.uploadProfile,
//       filePath: filePath,
//       fileKey: 'profile_image',
//       additionalData: {'user_id': userId},
//       fromJson: (json) => UploadResponse.fromJson(json),
//       errorMessage: 'Failed to upload profile image',
//       onSendProgress: (sent, total) {
//         final progress = (sent / total * 100).toStringAsFixed(0);
//         print('Upload progress: $progress%');
//       },
//     );
//   }

//   // ─── UPLOAD MULTIPLE FILES ─────────────────────────────────────────────
//   Future<UploadResponse> uploadTaskAttachments(
//     int taskId,
//     Map<String, String> files,
//   ) async {
//     return _handler.uploadMultipleFiles(
//       endpoint: ApiEndpoints.uploadAttachments,
//       files: files,
//       additionalData: {'task_id': taskId},
//       fromJson: (json) => UploadResponse.fromJson(json),
//       errorMessage: 'Failed to upload attachments',
//     );
//   }

//   // ─── DOWNLOAD FILE ─────────────────────────────────────────────────────
//   Future<void> downloadReport(String reportUrl, String savePath) async {
//     await _handler.downloadFile(
//       endpoint: reportUrl,
//       savePath: savePath,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           final progress = (received / total * 100).toStringAsFixed(0);
//           print('Download progress: $progress%');
//         }
//       },
//       errorMessage: 'Failed to download report',
//     );
//   }

//   // ─── CUSTOM HEADERS ────────────────────────────────────────────────────
//   Future<SpecialResponse> specialApiCall(Map<String, dynamic> data) async {
//     return _handler.post(
//       endpoint: ApiEndpoints.special,
//       data: data,
//       headers: {
//         'X-Custom-Header': 'custom-value',
//         'X-Device-Id': 'abc123',
//       },
//       contentType: RequestContentType.json,
//       fromJson: (json) => SpecialResponse.fromJson(json),
//       errorMessage: 'Special API call failed',
//     );
//   }

//   // ─── PUBLIC ENDPOINT (no auth) ─────────────────────────────────────────
//   Future<PublicDataResponse> fetchPublicData() async {
//     // Temporarily disable auth for this call
//     _client.clearAuth();
//     try {
//       final result = await _handler.get(
//         endpoint: ApiEndpoints.publicData,
//         fromJson: (json) => PublicDataResponse.fromJson(json),
//         errorMessage: 'Failed to fetch public data',
//       );
//       return result;
//     } finally {
//       // Restore default auth
//       _client.resetToDefaultAuth();
//     }
//   }
//   */
// }

// final apiService = ref.read(apiServiceProvider);

// // 1. Default: Basic Auth (auto-set on init)
// // No action needed

// // 2. After login → switch to Bearer
// final loginRes = await apiService.login('user', 'pass');
// apiService.setBearerToken(loginRes.token);

// // 3. Switch to API Key for a third-party endpoint
// apiService.setApiKey('sk-abc123', headerName: 'X-API-Key');

// // 4. Custom prefix (e.g., Django Token auth)
// apiService.setCustomAuth('abc123', prefix: 'Token');

// // 5. Full control via AuthConfig
// apiService.setAuth(AuthConfig.custom('mytoken', prefix: 'JWT'));

// // 6. Public endpoint — no auth
// apiService.clearAuth();

// // 7. Back to default Basic auth
// apiService.resetAuth();

// api/api_service.dart (Updated)

import 'package:adm_seller/modules/auth/models/check_phone_response.dart';
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
      data: {'refresh_token': refreshToken},
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
      errorMessage: 'Failed to refresh token',
    );
  }

  /// POST /seller/auth/logout
  Future<BaseResponseModel> logout() async {
    return _handler.post(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.logout}',
      data: {},
      contentType: RequestContentType.json,
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
  Future<BaseResponseModel> updateProfile(Map<String, dynamic> data) async {
    return _handler.put(
      endpoint: '${ApiEndpoints.baseUrlSeller}${ApiEndpoints.updateProfile}',
      data: data,
      contentType: RequestContentType.json,
      fromJson: (json) => BaseResponseModel.fromJson(json),
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
}

// features/seller/models/base_response_model.dart

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
