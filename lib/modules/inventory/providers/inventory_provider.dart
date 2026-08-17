import 'package:adm_seller/core/api/api_service.dart';
import 'package:adm_seller/modules/inventory/models/inventory_list_response.dart';
import 'package:adm_seller/modules/inventory/models/inventory_request_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      return InventoryNotifier(ref.read(apiServiceProvider));
    });

class InventoryState {
  final bool isLoading;
  final bool isRefreshing;

  final bool isUpdating;
  final bool isDeleting;

  final int? processingInventoryId;

  final String? errorMessage;

  final List<InventoryItem> items;
  final InventoryPagination? pagination;

  const InventoryState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.processingInventoryId,
    this.errorMessage,
    this.items = const [],
    this.pagination,
  });

  InventoryState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isUpdating,
    bool? isDeleting,
    int? processingInventoryId,
    String? errorMessage,
    List<InventoryItem>? items,
    InventoryPagination? pagination,
    bool clearError = false,
    bool clearProcessingId = false,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,

      isRefreshing: isRefreshing ?? this.isRefreshing,

      isUpdating: isUpdating ?? this.isUpdating,

      isDeleting: isDeleting ?? this.isDeleting,

      processingInventoryId: clearProcessingId
          ? null
          : processingInventoryId ?? this.processingInventoryId,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      items: items ?? this.items,

      pagination: pagination ?? this.pagination,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final ApiService _apiService;

  InventoryNotifier(this._apiService) : super(const InventoryState());

  Future<void> loadInventory({int page = 1, bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final response = await _apiService.getInventory(page: page, limit: 10);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> updateInventory({
    required int inventoryId,
    required UpdateInventoryRequest request,
  }) async {
    state = state.copyWith(
      isUpdating: true,
      processingInventoryId: inventoryId,
      clearError: true,
    );

    try {
      await _apiService.updateInventory(
        inventoryId: inventoryId,
        request: request,
      );

      // Refresh the list so the UI gets the
      // exact values returned by backend.
      await loadInventory(page: state.pagination?.page ?? 1, refresh: true);

      state = state.copyWith(isUpdating: false, clearProcessingId: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        clearProcessingId: true,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  Future<bool> deleteInventory(int inventoryId) async {
    state = state.copyWith(
      isDeleting: true,
      processingInventoryId: inventoryId,
      clearError: true,
    );

    try {
      await _apiService.deleteInventory(inventoryId);

      final updatedItems = state.items
          .where((item) => item.id != inventoryId)
          .toList();

      state = state.copyWith(
        isDeleting: false,
        items: updatedItems,
        clearProcessingId: true,
      );

      // Optional: refresh pagination count.
      await loadInventory(page: state.pagination?.page ?? 1, refresh: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        clearProcessingId: true,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  Future<void> refresh() async {
    await loadInventory(page: 1, refresh: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
