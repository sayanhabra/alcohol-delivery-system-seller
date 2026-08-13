import 'dart:async';

import 'package:adm_seller/core/api/api_service.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_models.dart';

final addInventoryProvider =
    StateNotifierProvider<AddInventoryNotifier, AddInventoryState>((ref) {
      final apiService = ref.read(apiServiceProvider);

      return AddInventoryNotifier(apiService);
    });

class AddInventoryState {
  final bool isLoadingCategories;
  final bool isLoadingBrands;
  final bool isLoadingProducts;
  final bool isLoadingProductDetails;
  final bool isSubmitting;

  final List<InventoryOption> categories;
  final List<InventoryOption> brands;
  final List<InventoryOption> products;

  final InventoryOption? selectedCategory;
  final InventoryOption? selectedBrand;
  final InventoryOption? selectedProduct;

  final ProductDetail? productDetail;

  final ProductVariant? selectedVariant;
  final List<ProductVariant> variants;

  final String? errorMessage;

  const AddInventoryState({
    this.isLoadingCategories = false,
    this.isLoadingBrands = false,
    this.isLoadingProducts = false,
    this.isLoadingProductDetails = false,
    this.isSubmitting = false,
    this.categories = const [],
    this.brands = const [],
    this.products = const [],
    this.selectedCategory,
    this.selectedBrand,
    this.selectedProduct,
    this.productDetail,
    this.selectedVariant,
    this.variants = const [],
    this.errorMessage,
  });

  AddInventoryState copyWith({
    bool? isLoadingCategories,
    bool? isLoadingBrands,
    bool? isLoadingProducts,
    bool? isLoadingProductDetails,
    bool? isSubmitting,

    List<InventoryOption>? categories,
    List<InventoryOption>? brands,
    List<InventoryOption>? products,

    InventoryOption? selectedCategory,
    InventoryOption? selectedBrand,
    InventoryOption? selectedProduct,

    ProductDetail? productDetail,

    ProductVariant? selectedVariant,
    List<ProductVariant>? variants,

    String? errorMessage,

    bool clearCategory = false,
    bool clearBrand = false,
    bool clearProduct = false,
    bool clearProductDetail = false,
    bool clearVariant = false,
    bool clearError = false,
  }) {
    return AddInventoryState(
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingBrands: isLoadingBrands ?? this.isLoadingBrands,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingProductDetails:
          isLoadingProductDetails ?? this.isLoadingProductDetails,
      isSubmitting: isSubmitting ?? this.isSubmitting,

      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      products: products ?? this.products,

      selectedCategory: clearCategory
          ? null
          : selectedCategory ?? this.selectedCategory,

      selectedBrand: clearBrand ? null : selectedBrand ?? this.selectedBrand,

      selectedProduct: clearProduct
          ? null
          : selectedProduct ?? this.selectedProduct,

      productDetail: clearProductDetail
          ? null
          : productDetail ?? this.productDetail,

      selectedVariant: clearVariant
          ? null
          : selectedVariant ?? this.selectedVariant,

      variants: variants ?? this.variants,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddInventoryNotifier extends StateNotifier<AddInventoryState> {
  final ApiService _apiService;

  Timer? _categoryDebounce;
  Timer? _productDebounce;

  AddInventoryNotifier(this._apiService) : super(const AddInventoryState());

  // ============================================================
  // CATEGORY
  // ============================================================

  void searchCategories(String value) {
    _categoryDebounce?.cancel();

    if (value.trim().isEmpty) {
      state = state.copyWith(categories: [], isLoadingCategories: false);
      return;
    }

    _categoryDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCategories(value.trim());
    });
  }

  Future<void> _fetchCategories(String search) async {
    state = state.copyWith(isLoadingCategories: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryCategories(search);

      final list = _extractList(response.data);

      state = state.copyWith(
        isLoadingCategories: false,
        categories: list
            .map((e) => InventoryOption.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategories: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // CATEGORY SELECT
  // ============================================================

  Future<void> selectCategory(InventoryOption category) async {
    state = state.copyWith(
      selectedCategory: category,
      brands: [],
      products: [],
      clearBrand: true,
      clearProduct: true,
      clearProductDetail: true,
      clearVariant: true,
    );

    await _fetchBrands(category.id);
  }

  // ============================================================
  // BRAND
  // ============================================================

  Future<void> _fetchBrands(int categoryId) async {
    state = state.copyWith(isLoadingBrands: true, clearError: true);

    try {
      final response = await _apiService.getInventoryBrands(
        categoryId: categoryId,
      );

      final list = _extractList(response.data);

      state = state.copyWith(
        isLoadingBrands: false,
        brands: list
            .map((e) => InventoryOption.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBrands: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // BRAND SELECT
  // ============================================================

  Future<void> selectBrand(InventoryOption brand) async {
    state = state.copyWith(
      selectedBrand: brand,
      products: [],
      clearProduct: true,
      clearProductDetail: true,
      clearVariant: true,
    );

    await _fetchProducts(brand.id);
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  void searchProducts(String value) {
    _productDebounce?.cancel();

    if (state.selectedBrand == null) {
      return;
    }

    _productDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchProducts(state.selectedBrand!.id, search: value.trim());
    });
  }

  Future<void> _fetchProducts(int brandId, {String search = ''}) async {
    state = state.copyWith(isLoadingProducts: true, clearError: true);

    try {
      final response = await _apiService.getInventoryProducts(
        brandId: brandId,
        search: search,
      );

      final list = _extractList(response.data);

      state = state.copyWith(
        isLoadingProducts: false,
        products: list
            .map((e) => InventoryOption.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // PRODUCT SELECT
  // ============================================================

  Future<void> selectProduct(InventoryOption product) async {
    state = state.copyWith(
      selectedProduct: product,
      clearProductDetail: true,
      clearVariant: true,
      variants: [],
    );

    await _fetchProductDetails(product.id);
  }

  // ============================================================
  // PRODUCT DETAIL
  // ============================================================

  Future<void> _fetchProductDetails(int productId) async {
    state = state.copyWith(isLoadingProductDetails: true, clearError: true);

    try {
      final response = await _apiService.getInventoryProductDetails(
        productId: productId,
      );

      final data = response.data;

      final Map<String, dynamic> json;

      if (data is Map<String, dynamic>) {
        json = data;
      } else {
        json = {};
      }

      final detail = ProductDetail.fromJson(json);

      state = state.copyWith(
        isLoadingProductDetails: false,
        productDetail: detail,
        variants: detail.variants,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProductDetails: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ============================================================
  // VARIANT
  // ============================================================

  void selectVariant(ProductVariant variant) {
    state = state.copyWith(selectedVariant: variant);
  }

  void addNewVariant({required String name, String? value}) {
    if (name.trim().isEmpty) return;

    final newVariant = ProductVariant(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name.trim(),
      value: value?.trim(),
    );

    final updatedVariants = [...state.variants, newVariant];

    state = state.copyWith(
      variants: updatedVariants,
      selectedVariant: newVariant,
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<bool> submitInventory({
    required int mrp,
    required String discountType,
    required double discountValue,
  }) async {
    if (state.selectedCategory == null ||
        state.selectedBrand == null ||
        state.selectedProduct == null) {
      state = state.copyWith(
        errorMessage: 'Please select category, brand and product.',
      );

      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final finalPrice = calculateFinalPrice(
        mrp: mrp,
        discountType: discountType,
        discountValue: discountValue,
      );

      final payload = {
        'category_id': state.selectedCategory!.id,
        'brand_id': state.selectedBrand!.id,
        'product_id': state.selectedProduct!.id,
        'variant_id': state.selectedVariant?.id,
        'variant_name': state.selectedVariant?.name,
        'mrp': mrp,
        'discount_type': discountType,
        'discount_value': discountValue,
        'final_price': finalPrice,
      };

      await _apiService.submitInventory(payload);

      state = state.copyWith(isSubmitting: false);

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());

      return false;
    }
  }

  // ============================================================
  // PRICE
  // ============================================================

  double calculateFinalPrice({
    required int mrp,
    required String discountType,
    required double discountValue,
  }) {
    if (discountValue <= 0) {
      return mrp.toDouble();
    }

    double finalPrice;

    if (discountType == 'percent') {
      finalPrice = mrp - (mrp * discountValue / 100);
    } else {
      finalPrice = mrp - discountValue;
    }

    if (finalPrice < 0) {
      return 0;
    }

    return finalPrice;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data['items'] is List) {
        return data['items'];
      }

      if (data['results'] is List) {
        return data['results'];
      }

      if (data['data'] is List) {
        return data['data'];
      }
    }

    return [];
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _categoryDebounce?.cancel();
    _productDebounce?.cancel();

    super.dispose();
  }
}
