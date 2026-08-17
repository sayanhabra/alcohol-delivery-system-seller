enum InventoryDiscountType {
  flat('FLAT'),
  percent('PERCENTAGE');

  final String value;

  const InventoryDiscountType(this.value);
}

class UpdateInventoryRequest {
  final int mrp;
  final String discountType;
  final int discountValue;
  final int availableQuantity;
  final int reservedQuantity;
  // final String status;

  const UpdateInventoryRequest({
    required this.mrp,
    required this.discountType,
    required this.discountValue,
    required this.availableQuantity,
    required this.reservedQuantity,
    // required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'mrp': mrp,
      'discountType': discountType,
      'discountValue': discountValue,
      'availableQuantity': availableQuantity,
      'reservedQuantity': reservedQuantity,
      // 'status': status,
    };
  }
}
