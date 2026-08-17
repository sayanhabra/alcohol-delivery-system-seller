class InventoryListResponse {
  final List<InventoryItem> items;
  final InventoryPagination pagination;

  const InventoryListResponse({required this.items, required this.pagination});

  factory InventoryListResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'];

    if (response is! Map<String, dynamic>) {
      return const InventoryListResponse(
        items: [],
        pagination: InventoryPagination(page: 1, limit: 10, total: 0),
      );
    }

    final data = response['data'];

    return InventoryListResponse(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(InventoryItem.fromJson)
                .toList()
          : [],
      pagination: InventoryPagination.fromJson(response['pagination']),
    );
  }
}

class InventoryItem {
  final int id;
  final int sellerId;
  final int productId;
  final int variantId;

  final InventorySeller? seller;
  final InventoryProduct? product;
  final InventoryVariant? variant;

  final int mrp;
  final int sellingPrice;
  final int discountValue;
  final String discountType;

  final int availableQuantity;
  final int reservedQuantity;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.sellerId,
    required this.productId,
    required this.variantId,
    this.seller,
    this.product,
    this.variant,
    required this.mrp,
    required this.sellingPrice,
    required this.discountValue,
    required this.discountType,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  int get availableStock {
    return availableQuantity - reservedQuantity;
  }

  bool get isAvailable {
    return status.toUpperCase() == 'AVAILABLE' && availableStock > 0;
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: _toInt(json['id']),
      sellerId: _toInt(json['sellerId']),
      productId: _toInt(json['productId']),
      variantId: _toInt(json['variantId']),

      seller: json['seller'] is Map<String, dynamic>
          ? InventorySeller.fromJson(json['seller'])
          : null,

      product: json['product'] is Map<String, dynamic>
          ? InventoryProduct.fromJson(json['product'])
          : null,

      variant: json['variant'] is Map<String, dynamic>
          ? InventoryVariant.fromJson(json['variant'])
          : null,

      mrp: _toInt(json['mrp']),
      sellingPrice: _toInt(json['sellingPrice']),
      discountValue: _toInt(json['discountValue']),
      discountType: json['discountType'],

      availableQuantity: _toInt(json['availableQuantity']),
      reservedQuantity: _toInt(json['reservedQuantity']),

      status: json['status']?.toString() ?? '',

      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),

      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class InventoryVariant {
  final int id;
  final int productId;
  final String sku;
  final int volumeMl;
  final bool isDefault;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryVariant({
    required this.id,
    required this.productId,
    required this.sku,
    required this.volumeMl,
    required this.isDefault,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryVariant.fromJson(Map<String, dynamic> json) {
    return InventoryVariant(
      id: _toInt(json['id']),
      productId: _toInt(json['productId']),
      sku: json['sku']?.toString() ?? '',
      volumeMl: _toInt(json['volumeMl']),
      isDefault: json['isDefault'] == true,
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class InventoryProduct {
  final int id;
  final String name;
  final String slug;
  final String description;

  final int brandId;
  final InventoryBrand? brand;

  final int categoryId;
  final InventoryCategory? category;

  final String? alcoholType;
  final String? unit;
  final double? alcoholPercentage;

  final String? packagingType;
  final String? exciseCategory;
  final String? complianceInfo;

  final List<InventoryProductImage> images;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.brandId,
    this.brand,
    required this.categoryId,
    this.category,
    this.alcoholType,
    this.unit,
    this.alcoholPercentage,
    this.packagingType,
    this.exciseCategory,
    this.complianceInfo,
    required this.images,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    final images = json['images'];

    return InventoryProduct(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',

      brandId: _toInt(json['brandId']),

      brand: json['brand'] is Map<String, dynamic>
          ? InventoryBrand.fromJson(json['brand'])
          : null,

      categoryId: _toInt(json['categoryId']),

      category: json['category'] is Map<String, dynamic>
          ? InventoryCategory.fromJson(json['category'])
          : null,

      alcoholType: json['alcoholType']?.toString(),

      unit: json['unit']?.toString(),

      alcoholPercentage: double.tryParse(
        json['alcoholPercentage']?.toString() ?? '',
      ),

      packagingType: json['packagingType']?.toString(),

      exciseCategory: json['exciseCategory']?.toString(),

      complianceInfo: json['complianceInfo']?.toString(),

      images: images is List
          ? images
                .whereType<Map<String, dynamic>>()
                .map(InventoryProductImage.fromJson)
                .toList()
          : [],

      status: json['status']?.toString() ?? '',

      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),

      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class InventoryBrand {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;

  const InventoryBrand({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
  });

  factory InventoryBrand.fromJson(Map<String, dynamic> json) {
    return InventoryBrand(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
    );
  }
}

class InventoryCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;

  const InventoryCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
    );
  }
}

class InventoryProductImage {
  final int id;
  final int productId;
  final String path;
  final String url;
  final int displayOrder;

  const InventoryProductImage({
    required this.id,
    required this.productId,
    required this.path,
    required this.url,
    required this.displayOrder,
  });

  factory InventoryProductImage.fromJson(Map<String, dynamic> json) {
    return InventoryProductImage(
      id: _toInt(json['id']),
      productId: _toInt(json['productId']),
      path: json['path']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      displayOrder: _toInt(json['displayOrder']),
    );
  }
}

class InventorySeller {
  final int id;
  final String phone;
  final String? email;
  final String name;
  final String? profileImage;

  final InventorySellerProfile? sellerProfile;

  const InventorySeller({
    required this.id,
    required this.phone,
    this.email,
    required this.name,
    this.profileImage,
    this.sellerProfile,
  });

  factory InventorySeller.fromJson(Map<String, dynamic> json) {
    return InventorySeller(
      id: _toInt(json['id']),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),

      sellerProfile: json['sellerProfile'] is Map<String, dynamic>
          ? InventorySellerProfile.fromJson(json['sellerProfile'])
          : null,
    );
  }
}

class InventorySellerProfile {
  final String? storeName;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isStoreOpen;

  const InventorySellerProfile({
    this.storeName,
    this.city,
    this.state,
    this.pincode,
    required this.isStoreOpen,
  });

  factory InventorySellerProfile.fromJson(Map<String, dynamic> json) {
    return InventorySellerProfile(
      storeName: json['storeName']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      isStoreOpen: json['isStoreOpen'] == true,
    );
  }
}

class InventoryPagination {
  final int page;
  final int limit;
  final int total;

  const InventoryPagination({
    required this.page,
    required this.limit,
    required this.total,
  });

  int get totalPages {
    if (limit <= 0) return 1;

    return (total / limit).ceil();
  }

  factory InventoryPagination.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const InventoryPagination(page: 1, limit: 10, total: 0);
    }

    return InventoryPagination(
      page: _toInt(json['page']),
      limit: _toInt(json['limit']),
      total: _toInt(json['total']),
    );
  }
}
