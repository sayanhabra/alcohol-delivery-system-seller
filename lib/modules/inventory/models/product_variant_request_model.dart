class AddProductVariantRequest {
  final String sku;
  final int volumeMl;
  final bool isDefault;
  final String status;

  const AddProductVariantRequest({
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
