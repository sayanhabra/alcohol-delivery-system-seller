import 'dart:io';
import 'package:adm_seller/core/api/api_service.dart';
import 'package:adm_seller/modules/inventory/models/category_brand_data.dart';
import 'package:adm_seller/modules/inventory/models/product_details_response.dart';
import 'package:adm_seller/modules/inventory/models/product_request_models.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final addNewProductProvider =
    StateNotifierProvider<AddNewProductNotifier, AddNewProductState>((ref) {
      final apiService = ref.read(apiServiceProvider);

      return AddNewProductNotifier(apiService);
    });

class AddNewProductState {
  final bool isSubmitting;

  final bool isLoadingCategories;
  final bool isLoadingBrands;

  final List<CategoryBrandData> categories;
  final List<CategoryBrandData> brands;

  final CategoryBrandData? selectedCategory;
  final CategoryBrandData? selectedBrand;

  final List<ProductVariantRequest> variants;
  final List<XFile> selectedImages;
  final String productStatus;

  final String? errorMessage;

  const AddNewProductState({
    this.isSubmitting = false,
    this.isLoadingCategories = false,
    this.isLoadingBrands = false,
    this.categories = const [],
    this.brands = const [],
    this.selectedCategory,
    this.selectedBrand,
    this.selectedImages = const [],
    this.productStatus = 'ACTIVE',

    this.variants = const [],
    this.errorMessage,
  });

  AddNewProductState copyWith({
    bool? isSubmitting,
    bool? isLoadingCategories,
    bool? isLoadingBrands,
    List<CategoryBrandData>? categories,
    List<CategoryBrandData>? brands,
    CategoryBrandData? selectedCategory,
    CategoryBrandData? selectedBrand,
    List<ProductVariantRequest>? variants,
    List<XFile>? selectedImages,
    String? productStatus,

    String? errorMessage,

    bool clearCategory = false,
    bool clearBrand = false,
    bool clearError = false,
  }) {
    return AddNewProductState(
      isSubmitting: isSubmitting ?? this.isSubmitting,

      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,

      isLoadingBrands: isLoadingBrands ?? this.isLoadingBrands,

      categories: categories ?? this.categories,

      brands: brands ?? this.brands,

      selectedCategory: clearCategory
          ? null
          : selectedCategory ?? this.selectedCategory,

      selectedBrand: clearBrand ? null : selectedBrand ?? this.selectedBrand,

      variants: variants ?? this.variants,

      selectedImages: selectedImages ?? this.selectedImages,

      productStatus: productStatus ?? this.productStatus,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AddNewProductNotifier extends StateNotifier<AddNewProductState> {
  final ApiService _apiService;

  AddNewProductNotifier(this._apiService) : super(const AddNewProductState());

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // CATEGORY
  // ============================================================

  Future<void> loadCategories() async {
    state = state.copyWith(isLoadingCategories: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryCategories('');

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
  // BRAND
  // ============================================================

  Future<void> loadBrands() async {
    state = state.copyWith(isLoadingBrands: true, clearError: true);

    try {
      final response = await _apiService.searchInventoryBrands('');

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
  // CATEGORY SEARCH
  // ============================================================

  Future<void> searchCategories(String value) async {
    final search = value.trim();

    if (search.isEmpty) {
      await loadCategories();
      return;
    }

    state = state.copyWith(isLoadingCategories: true);

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
  // BRAND SEARCH
  // ============================================================

  Future<void> searchBrands(String value) async {
    final search = value.trim();

    if (search.isEmpty) {
      await loadBrands();
      return;
    }

    state = state.copyWith(isLoadingBrands: true);

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
  // SELECTION
  // ============================================================

  void selectCategory(CategoryBrandData category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectBrand(CategoryBrandData brand) {
    state = state.copyWith(selectedBrand: brand);
  }

  // ============================================================
  // VARIANT
  // ============================================================

  void addNewVariant({
    required String sku,
    required int volumeMl,
    bool isDefault = false,
    String status = 'ACTIVE',
  }) {
    if (sku.trim().isEmpty) {
      return;
    }

    if (volumeMl <= 0) {
      return;
    }

    final variants = List<ProductVariantRequest>.from(state.variants);

    // If this is default, remove default from existing variants.
    if (isDefault) {
      for (int i = 0; i < variants.length; i++) {
        variants[i] = ProductVariantRequest(
          sku: variants[i].sku,
          volumeMl: variants[i].volumeMl,
          isDefault: false,
          status: variants[i].status,
        );
      }
    }

    variants.add(
      ProductVariantRequest(
        sku: sku.trim(),
        volumeMl: volumeMl,
        isDefault: isDefault,
        status: status,
      ),
    );

    state = state.copyWith(variants: variants);
  }

  void removeVariant(int index) {
    final variants = List<ProductVariantRequest>.from(state.variants);

    if (index < 0 || index >= variants.length) {
      return;
    }

    variants.removeAt(index);

    state = state.copyWith(variants: variants);
  }

  //===============================
  //IMAGE
  //===============================
  Future<XFile> _compressIfNeeded(XFile image) async {
    try {
      final file = File(image.path);
      final size = await file.length();
      final limit = 1.5 * 1024 * 1024; // 1.5 MB in bytes

      if (size <= limit) {
        return image;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      var quality = 80;
      var compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
      );

      if (compressedFile != null) {
        var compressedSize = await File(compressedFile.path).length();
        while (compressedSize > limit && quality > 20) {
          quality -= 20;
          final newTargetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_q${quality}_${image.name}';
          final nextCompressedFile = await FlutterImageCompress.compressAndGetFile(
            image.path,
            newTargetPath,
            quality: quality,
            minWidth: 1280,
            minHeight: 1280,
          );
          if (nextCompressedFile == null) break;
          compressedFile = nextCompressedFile;
          compressedSize = await File(compressedFile.path).length();
        }
      }

      if (compressedFile != null) {
        return XFile(compressedFile.path);
      }
    } catch (e) {
      // If compression fails, fall back to original image
    }
    return image;
  }

  Future<void> pickImages() async {
    if (state.selectedImages.length >= 5) {
      state = state.copyWith(errorMessage: 'Maximum of 5 images allowed.');
      return;
    }

    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (images.isEmpty) {
        return;
      }

      var allowedImages = images;
      bool wasTruncated = false;
      if (state.selectedImages.length + images.length > 5) {
        final remainingAllowed = 5 - state.selectedImages.length;
        allowedImages = images.take(remainingAllowed).toList();
        wasTruncated = true;
      }

      final compressedImages = <XFile>[];
      for (final img in allowedImages) {
        final compressed = await _compressIfNeeded(img);
        compressedImages.add(compressed);
      }

      final updatedImages = [...state.selectedImages, ...compressedImages];

      state = state.copyWith(
        selectedImages: updatedImages,
        errorMessage: wasTruncated ? 'Only up to 5 images can be uploaded. Extra images were ignored.' : null,
        clearError: !wasTruncated,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Unable to select images: $e');
    }
  }

  Future<void> takePhoto() async {
    if (state.selectedImages.length >= 5) {
      state = state.copyWith(errorMessage: 'Maximum of 5 images allowed.');
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final compressed = await _compressIfNeeded(image);

      final updatedImages = [...state.selectedImages, compressed];

      state = state.copyWith(
        selectedImages: updatedImages,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Unable to take photo: $e');
    }
  }

  void removeImage(int index) {
    final images = List<XFile>.from(state.selectedImages);

    if (index < 0 || index >= images.length) {
      return;
    }

    images.removeAt(index);

    state = state.copyWith(
      selectedImages: images,
      clearError: true,
    );
  }

  void setProductStatus(String? status) {
    if (status == null) return;

    state = state.copyWith(productStatus: status);
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<bool> submitProduct({
    required String name,
    required String description,
    required int brandId,
    required int categoryId,
    String? alcoholType,
    String? unit,
    required double alcoholPercentage,
    String? packagingType,
    String? exciseCategory,
    String? complianceInfo,
  }) async {
    if (state.variants.isEmpty) {
      state = state.copyWith(errorMessage: 'At least one variant is required.');

      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final request = ProductRequestModel(
        name: name.trim(),
        description: description.trim(),
        brandId: brandId,
        categoryId: categoryId,
        alcoholType: _nullable(alcoholType),
        unit: _nullable(unit) ?? 'ML',
        alcoholPercentage: alcoholPercentage,
        packagingType: _nullable(packagingType),
        exciseCategory: _nullable(exciseCategory),
        complianceInfo: _nullable(complianceInfo),
        status: state.productStatus,
        variants: state.variants,
      );

      await _apiService.createProductRequest(
        request: request,
        images: state.selectedImages,
      );

      state = state.copyWith(isSubmitting: false);

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());

      return false;
    }
  }

  String? _nullable(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // PARSER
  // ============================================================

  List<CategoryBrandData> _parseCategoryBrandList(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return [];
    }

    final response = data['response'];

    if (response is! Map<String, dynamic>) {
      return [];
    }

    final list = response['data'];

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => CategoryBrandData.fromJson(json))
        .toList();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
