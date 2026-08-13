class InventoryOption {
  final int id;
  final String name;

  const InventoryOption({required this.id, required this.name});

  factory InventoryOption.fromJson(Map<String, dynamic> json) {
    return InventoryOption(
      id:
          json['id'] ??
          json['category_id'] ??
          json['brand_id'] ??
          json['product_id'] ??
          0,
      name:
          json['name'] ??
          json['category_name'] ??
          json['brand_name'] ??
          json['product_name'] ??
          '',
    );
  }
}

class ProductDetail {
  final int id;
  final String name;
  final String description;
  final String image;
  final String categoryName;
  final String brandName;
  final List<ProductVariant> variants;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryName,
    required this.brandName,
    required this.variants,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      categoryName: json['category_name'] ?? '',
      brandName: json['brand_name'] ?? '',
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String? sku;
  final String? value;

  const ProductVariant({
    required this.id,
    required this.name,
    this.sku,
    this.value,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'],
      value: json['value'],
    );
  }
}
