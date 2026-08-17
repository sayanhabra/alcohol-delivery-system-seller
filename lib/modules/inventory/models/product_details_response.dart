class ProductDetailsResponse {
  final int id;
  final String name;
  final String slug;
  final String description;

  final int brandId;
  final ProductBrandResponse? brand;

  final int categoryId;
  final ProductCategoryResponse? category;

  final String? alcoholType;
  final String? unit;
  final double? alcoholPercentage;
  final String? packagingType;
  final String? exciseCategory;
  final String? complianceInfo;

  final List<ProductVariantResponse> variants;
  final List<ProductImageResponse> images;

  final String? status;
  final int? requestedByVendorId;
  final String? rejectionReason;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductDetailsResponse({
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
    this.variants = const [],
    this.images = const [],
    this.status,
    this.requestedByVendorId,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      id: _toInt(json['id']) ?? 0,

      name: json['name']?.toString() ?? '',

      slug: json['slug']?.toString() ?? '',

      description: json['description']?.toString() ?? '',

      brandId: _toInt(json['brandId']) ?? 0,

      brand: json['brand'] is Map<String, dynamic>
          ? ProductBrandResponse.fromJson(json['brand'] as Map<String, dynamic>)
          : null,

      categoryId: _toInt(json['categoryId']) ?? 0,

      category: json['category'] is Map<String, dynamic>
          ? ProductCategoryResponse.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,

      alcoholType: json['alcoholType']?.toString(),

      unit: json['unit']?.toString(),

      alcoholPercentage: _toDouble(json['alcoholPercentage']),

      packagingType: json['packagingType']?.toString(),

      exciseCategory: json['exciseCategory']?.toString(),

      complianceInfo: json['complianceInfo']?.toString(),

      variants: json['variants'] is List
          ? (json['variants'] as List)
                .whereType<Map<String, dynamic>>()
                .map(ProductVariantResponse.fromJson)
                .toList()
          : [],

      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map<String, dynamic>>()
                .map(ProductImageResponse.fromJson)
                .toList()
          : [],

      status: json['status']?.toString(),

      requestedByVendorId: _toInt(json['requestedByVendorId']),

      rejectionReason: json['rejectionReason']?.toString(),

      createdAt: _toDateTime(json['createdAt']),

      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,

      'brandId': brandId,
      'brand': brand?.toJson(),

      'categoryId': categoryId,
      'category': category?.toJson(),

      'alcoholType': alcoholType,
      'unit': unit,
      'alcoholPercentage': alcoholPercentage,
      'packagingType': packagingType,
      'exciseCategory': exciseCategory,
      'complianceInfo': complianceInfo,

      'variants': variants.map((e) => e.toJson()).toList(),

      'images': images.map((e) => e.toJson()).toList(),

      'status': status,
      'requestedByVendorId': requestedByVendorId,
      'rejectionReason': rejectionReason,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class ProductBrandResponse {
  final int id;
  final String name;
  final String slug;
  final String? description;

  final String? logoPath;
  final String? logoUrl;

  final bool? isActive;
  final int? productCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductBrandResponse({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoPath,
    this.logoUrl,
    this.isActive,
    this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductBrandResponse.fromJson(Map<String, dynamic> json) {
    return ProductBrandResponse(
      id: _toInt(json['id']) ?? 0,

      name: json['name']?.toString() ?? '',

      slug: json['slug']?.toString() ?? '',

      description: json['description']?.toString(),

      logoPath: json['logoPath']?.toString(),

      logoUrl: json['logoUrl']?.toString(),

      isActive: json['isActive'] as bool?,

      productCount: _toInt(json['productCount']),

      createdAt: _toDateTime(json['createdAt']),

      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logoPath': logoPath,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class ProductCategoryResponse {
  final int id;
  final String name;
  final String slug;
  final String? description;

  final String? iconPath;
  final String? iconUrl;

  final bool? isActive;
  final int? productCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductCategoryResponse({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconPath,
    this.iconUrl,
    this.isActive,
    this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ProductCategoryResponse(
      id: _toInt(json['id']) ?? 0,

      name: json['name']?.toString() ?? '',

      slug: json['slug']?.toString() ?? '',

      description: json['description']?.toString(),

      iconPath: json['iconPath']?.toString(),

      iconUrl: json['iconUrl']?.toString(),

      isActive: json['isActive'] as bool?,

      productCount: _toInt(json['productCount']),

      createdAt: _toDateTime(json['createdAt']),

      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'iconPath': iconPath,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class ProductVariantResponse {
  final int id;
  final int productId;

  final String sku;
  final int volumeMl;

  final bool isDefault;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductVariantResponse({
    required this.id,
    required this.productId,
    required this.sku,
    required this.volumeMl,
    required this.isDefault,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariantResponse.fromJson(Map<String, dynamic> json) {
    return ProductVariantResponse(
      id: _toInt(json['id']) ?? 0,

      productId: _toInt(json['productId']) ?? 0,

      sku: json['sku']?.toString() ?? '',

      volumeMl: _toInt(json['volumeMl']) ?? 0,

      isDefault: json['isDefault'] == true,

      status: json['status']?.toString() ?? '',

      createdAt: _toDateTime(json['createdAt']),

      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sku': sku,
      'volumeMl': volumeMl,
      'isDefault': isDefault,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class ProductImageResponse {
  final int id;
  final int productId;

  final String path;
  final String url;

  final int displayOrder;

  final DateTime? createdAt;

  const ProductImageResponse({
    required this.id,
    required this.productId,
    required this.path,
    required this.url,
    required this.displayOrder,
    this.createdAt,
  });

  factory ProductImageResponse.fromJson(Map<String, dynamic> json) {
    return ProductImageResponse(
      id: _toInt(json['id']) ?? 0,

      productId: _toInt(json['productId']) ?? 0,

      path: json['path']?.toString() ?? '',

      url: json['url']?.toString() ?? '',

      displayOrder: _toInt(json['displayOrder']) ?? 0,

      createdAt: _toDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'path': path,
      'url': url,
      'displayOrder': displayOrder,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
