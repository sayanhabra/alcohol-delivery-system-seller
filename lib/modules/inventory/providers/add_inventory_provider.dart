import 'dart:async';

import 'package:adm_seller/core/api/api_service.dart';
import 'package:adm_seller/modules/inventory/models/category_brand_data.dart';
import 'package:adm_seller/modules/inventory/models/product_details_response.dart';
import 'package:adm_seller/modules/inventory/models/product_variant_request_model.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  final List<CategoryBrandData> categories;
  final List<CategoryBrandData> brands;
  final List<CategoryBrandData> products;

  final CategoryBrandData? selectedCategory;
  final CategoryBrandData? selectedBrand;
  final CategoryBrandData? selectedProduct;

  final ProductDetailsResponse? productDetail;

  final ProductVariantResponse? selectedVariant;
  final List<ProductVariantResponse> variants;

  final int availableQuantity;
  final int reserveQuantity;

  final String? errorMessage;
  final bool isAddingVariant;

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

    this.availableQuantity = 0,
    this.reserveQuantity = 0,

    this.errorMessage,

    this.isAddingVariant = false,
  });

  AddInventoryState copyWith({
    bool? isLoadingCategories,
    bool? isLoadingBrands,
    bool? isLoadingProducts,
    bool? isLoadingProductDetails,
    bool? isSubmitting,

    List<CategoryBrandData>? categories,
    List<CategoryBrandData>? brands,
    List<CategoryBrandData>? products,

    CategoryBrandData? selectedCategory,
    CategoryBrandData? selectedBrand,
    CategoryBrandData? selectedProduct,

    ProductDetailsResponse? productDetail,

    ProductVariantResponse? selectedVariant,
    List<ProductVariantResponse>? variants,

    int? availableQuantity,
    int? reserveQuantity,

    String? errorMessage,

    bool clearCategory = false,
    bool clearBrand = false,
    bool clearProduct = false,
    bool clearProductDetail = false,
    bool clearVariant = false,
    bool clearError = false,

    bool? isAddingVariant,
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

      availableQuantity: availableQuantity ?? this.availableQuantity,
      reserveQuantity: reserveQuantity ?? this.reserveQuantity,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      isAddingVariant: isAddingVariant ?? this.isAddingVariant,
    );
  }
}

class AddInventoryNotifier extends StateNotifier<AddInventoryState> {
  final ApiService _apiService;

  Timer? _categoryDebounce;
  Timer? _brandDebounce;
  Timer? _productDebounce;

  AddInventoryNotifier(this._apiService) : super(const AddInventoryState());

  void selectVariant(ProductVariantResponse variant) {
    state = state.copyWith(selectedVariant: variant);
  }

  List<CategoryBrandData> _parseCategoryBrandList(dynamic data) {
    if (data is! Map) {
      return [];
    }

    final response = data['response'];

    if (response is! Map) {
      return [];
    }

    final responseData = response['data'];

    if (responseData is! List) {
      return [];
    }

    return responseData
        .whereType<Map>()
        .map(
          (item) => CategoryBrandData.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  //initial data load

  Future<void> loadInitialData() async {
    await Future.wait([
      _fetchCategories(''),
      _fetchBrands(''),
      // _fetchProducts(''),
    ]);
  }
  // ============================================================
  // CATEGORY
  // ============================================================

  void searchCategories(String value) {
    _categoryDebounce?.cancel();

    final search = value.trim();

    _categoryDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCategories(search);
    });
  }

  void addNewVariant({required String sku, required int volumeMl}) {
    final trimmedSku = sku.trim();

    if (trimmedSku.isEmpty || volumeMl <= 0) {
      return;
    }

    final newVariant = ProductVariantResponse(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: state.productDetail?.id ?? 0,
      sku: trimmedSku,
      volumeMl: volumeMl,
      isDefault: state.variants.isEmpty,
      status: 'ACTIVE',
      createdAt: null,
      updatedAt: null,
    );

    final updatedVariants = [...state.variants, newVariant];

    state = state.copyWith(
      variants: updatedVariants,
      selectedVariant: newVariant,
    );
  }

  Future<void> _fetchCategories(String search) async {
    state = state.copyWith(isLoadingCategories: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryCategories(search);

      final categories = _parseCategoryBrandList(response.data);

      state = state.copyWith(
        isLoadingCategories: false,
        categories: categories,
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

  void selectCategory(CategoryBrandData category) {
    state = state.copyWith(selectedCategory: category);
  }

  // ============================================================
  // BRAND
  // ============================================================

  void searchBrands(String value) {
    _brandDebounce?.cancel();

    final search = value.trim();

    _brandDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchBrands(search);
    });
  }

  Future<void> _fetchBrands(String search) async {
    state = state.copyWith(isLoadingBrands: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryBrands(search);

      final brands = _parseCategoryBrandList(response.data);

      state = state.copyWith(isLoadingBrands: false, brands: brands);
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
  void selectBrand(CategoryBrandData brand) {
    state = state.copyWith(selectedBrand: brand);
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  void searchProducts(String value) {
    _productDebounce?.cancel();

    final search = value.trim();

    if (search.isEmpty) {
      state = state.copyWith(products: [], isLoadingProducts: false);
      return;
    }

    _productDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchProducts(search);
    });
  }

  Future<void> _fetchProducts(String search) async {
    state = state.copyWith(isLoadingProducts: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryProducts(search);

      final products = _parseCategoryBrandList(response.data);

      state = state.copyWith(isLoadingProducts: false, products: products);
    } catch (e) {
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<CategoryBrandData>> fetchCategories(String query) async {
    final response = await _apiService.searchInventoryCategories(query);
    return _parseCategoryBrandList(response.data);
  }

  Future<List<CategoryBrandData>> fetchBrands(String query) async {
    final response = await _apiService.searchInventoryBrands(query);
    return _parseCategoryBrandList(response.data);
  }

  Future<List<CategoryBrandData>> fetchProducts(String query) async {
    final response = await _apiService.searchInventoryProducts(query);
    return _parseCategoryBrandList(response.data);
  }
  // ============================================================
  // PRODUCT SELECT
  // ============================================================

  Future<void> selectProduct(CategoryBrandData product) async {
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

      final rawData = response.data;

      Map<String, dynamic>? productJson;

      if (rawData is Map<String, dynamic>) {
        // ============================================================
        // API RESPONSE
        //
        // {
        //   "statusCode": 200,
        //   "message": "...",
        //   "response": {
        //      "id": 3,
        //      "name": "test3",
        //      ...
        //   }
        // }
        // ============================================================

        final apiResponse = rawData['response'];

        if (apiResponse is Map<String, dynamic>) {
          // Product details API returns the product
          // directly inside response.
          productJson = apiResponse;
        }

        // Fallback in case ApiService already unwraps response
        if (productJson == null &&
            rawData.containsKey('id') &&
            rawData.containsKey('name')) {
          productJson = rawData;
        }
      }

      if (productJson == null || productJson.isEmpty) {
        throw Exception('Invalid product details response');
      }

      final detail = ProductDetailsResponse.fromJson(productJson);

      state = state.copyWith(
        isLoadingProductDetails: false,
        productDetail: detail,
        variants: detail.variants,
        selectedVariant: _getDefaultVariant(detail.variants),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProductDetails: false,
        errorMessage: e.toString(),
      );
    }
  }

  ProductVariantResponse? _getDefaultVariant(
    List<ProductVariantResponse> variants,
  ) {
    if (variants.isEmpty) {
      return null;
    }

    for (final variant in variants) {
      if (variant.isDefault) {
        return variant;
      }
    }

    // If API doesn't mark any variant as default,
    // select the first one.
    return variants.first;
  }

  //quantities
  // setAvailableQuantity

  void setAvailableQuantity(int qty) {
    state = state.copyWith(availableQuantity: qty);
  }

  void setReserveQuantity(int qty) {
    state = state.copyWith(reserveQuantity: qty);
  }
  // ============================================================
  // SUBMIT
  // ============================================================

  Future<bool> submitInventory({
    required int mrp,
    required String discountType,
    required int discountValue,
  }) async {
    if (
    // state.selectedCategory == null ||
    //   state.selectedBrand == null ||
    state.availableQuantity == null || state.selectedProduct == null) {
      state = state.copyWith(errorMessage: 'Please select product.');

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
        // 'category_id': state.selectedCategory?.id,
        // 'brand_id': state.selectedBrand?.id,
        'productId': state.selectedProduct?.id,
        'variantId': state.selectedVariant?.id,
        // 'variant_name': state.selectedVariant?.sku,
        'mrp': mrp * 100,
        'discountType': discountType == 'percent' ? "PERCENTAGE" : "FLAT",
        'discountValue': discountType == "percent"
            ? discountValue
            : (discountValue * 100),
        // 'finalPrice': finalPrice * 100,
        'sellingPrice': finalPrice * 100,
        'availableQuantity': state.availableQuantity,
        'reservedQuantity': state.reserveQuantity,
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

  int calculateFinalPrice({
    required int mrp,
    required String discountType,
    required int discountValue,
  }) {
    if (discountValue <= 0) {
      return mrp;
    }

    int finalPrice;

    if (discountType == 'percent') {
      // Integer arithmetic to compute percentage directly on paisa
      finalPrice = (mrp * (100 - discountValue)) ~/ 100;
    } else {
      finalPrice = mrp - discountValue;
    }

    return finalPrice < 0 ? 0 : finalPrice;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      // Your actual API:
      //
      // response
      //   └── data
      //
      final response = data['response'];

      if (response is Map<String, dynamic>) {
        final responseData = response['data'];

        if (responseData is List) {
          return responseData;
        }
      }

      // Fallback support
      if (data['data'] is List) {
        return data['data'];
      }

      if (data['items'] is List) {
        return data['items'];
      }

      if (data['results'] is List) {
        return data['results'];
      }
    }

    return [];
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> addProductVariant({
    required int productId,
    required String sku,
    required int volumeMl,
    bool isDefault = false,
    String status = 'ACTIVE',
  }) async {
    state = state.copyWith(isAddingVariant: true, clearError: true);

    try {
      final request = AddProductVariantRequest(
        sku: sku.trim(),
        volumeMl: volumeMl,
        isDefault: isDefault,
        status: status,
      );

      await _apiService.addProductVariant(
        productId: productId,
        request: request,
      );

      // Reload product details so the newly
      // created variant comes from the backend.
      await _fetchProductDetails(productId);

      state = state.copyWith(isAddingVariant: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isAddingVariant: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  @override
  void dispose() {
    _categoryDebounce?.cancel();
    _brandDebounce?.cancel();
    _productDebounce?.cancel();

    super.dispose();
  }
}
