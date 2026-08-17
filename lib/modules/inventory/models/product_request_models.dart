class ProductVariantRequest {
  final String sku;
  final int volumeMl;
  final bool isDefault;
  final String status;

  const ProductVariantRequest({
    required this.sku,
    required this.volumeMl,
    this.isDefault = false,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'volumeMl': volumeMl,
      'isDefault': isDefault,
      'status': status,
    };
  }
}

class ProductRequestModel {
  final String name;
  final String description;

  final int brandId;
  final int categoryId;

  final String? alcoholType;
  final String? unit;

  final double alcoholPercentage;

  final String? packagingType;
  final String? exciseCategory;
  final String? complianceInfo;

  final List<ProductVariantRequest> variants;

  final String status;

  const ProductRequestModel({
    required this.name,
    required this.description,
    required this.brandId,
    required this.categoryId,
    this.alcoholType,
    this.unit = 'ML',
    required this.alcoholPercentage,
    this.packagingType,
    this.exciseCategory,
    this.complianceInfo,
    required this.variants,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'brandId': brandId,
      'categoryId': categoryId,
      'alcoholType': alcoholType,
      'unit': unit,
      'alcoholPercentage': alcoholPercentage,
      'packagingType': packagingType,
      'exciseCategory': exciseCategory,
      'complianceInfo': complianceInfo,
      'status': status,
      'variants': variants.map((e) => e.toJson()).toList(),
    };
  }
}
