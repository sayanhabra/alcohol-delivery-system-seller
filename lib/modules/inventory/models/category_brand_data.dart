class CategoryBrandData {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? logoPath;
  final String? logoUrl;
  final bool isActive;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryBrandData({
    required this.id,
    required this.name,
    this.slug = '',
    this.description = '',
    this.logoPath,
    this.logoUrl,
    this.isActive = true,
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryBrandData.fromJson(Map<String, dynamic> json) {
    return CategoryBrandData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      logoPath: json['logoPath'],
      logoUrl: json['logoUrl'],
      isActive: json['isActive'] ?? true,
      productCount: json['productCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
