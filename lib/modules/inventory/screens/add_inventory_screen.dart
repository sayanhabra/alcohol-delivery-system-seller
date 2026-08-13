import 'package:adm_seller/core/shared/widgets/search_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/shared/styles/app_colors.dart';
import '../../../core/shared/styles/app_style.dart';
import '../providers/add_inventory_provider.dart';

class AddInventoryScreen extends ConsumerStatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  ConsumerState<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends ConsumerState<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _productController = TextEditingController();

  final _mrpController = TextEditingController();
  final _discountController = TextEditingController();

  String _discountType = 'percent';

  @override
  void dispose() {
    _categoryController.dispose();
    _brandController.dispose();
    _productController.dispose();
    _mrpController.dispose();
    _discountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addInventoryProvider);

    final provider = ref.read(addInventoryProvider.notifier);

    final mrp = int.tryParse(_mrpController.text) ?? 0;

    final discount = double.tryParse(_discountController.text) ?? 0;

    final finalPrice = provider.calculateFinalPrice(
      mrp: mrp,
      discountType: _discountType,
      discountValue: discount,
    );

    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorName.primarybackground,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Add Inventory',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppStyle.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: AppStyle.spaceLarge),

              _buildSectionCard(
                title: 'Product Selection',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _buildCategoryField(state, provider),

                    const SizedBox(height: AppStyle.spaceMedium),

                    _buildBrandField(state, provider),

                    const SizedBox(height: AppStyle.spaceMedium),

                    _buildProductField(state, provider),
                  ],
                ),
              ),

              if (state.isLoadingProductDetails)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (state.productDetail != null) _buildProductDetailCard(state),

              if (state.productDetail != null)
                _buildVariantCard(state, provider),

              _buildPricingCard(state, finalPrice),

              if (state.errorMessage != null) _buildError(state.errorMessage!),

              const SizedBox(height: AppStyle.spaceLarge),

              _buildSubmitButton(state),

              const SizedBox(height: AppStyle.spaceXXLarge),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppStyle.primaryGradient,
        borderRadius: AppStyle.borderRadiusLarge,
        boxShadow: AppStyle.mediumShadow,
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.add_business_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Select a product and set your selling price.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.borderedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: ColorName.primarybackground.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: ColorName.primarybackground, size: 20),
              ),

              const SizedBox(width: 10),

              Text(title, style: AppStyle.titleLarge),
            ],
          ),

          const SizedBox(height: AppStyle.spaceLarge),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryField(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    return SearchDropdownField(
      controller: _categoryController,
      label: 'Category',
      hint: 'Search category',
      prefixIcon: Icons.category_outlined,
      isLoading: state.isLoadingCategories,
      items: state.categories,
      selectedItem: state.selectedCategory,
      onChanged: provider.searchCategories,
      onSelected: (item) {
        _categoryController.text = item.name;

        provider.selectCategory(item);

        _brandController.clear();
        _productController.clear();
      },
    );
  }

  // ============================================================
  // BRAND
  // ============================================================

  Widget _buildBrandField(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    final enabled = state.selectedCategory != null;

    return SearchDropdownField(
      controller: _brandController,
      label: 'Brand',
      hint: enabled ? 'Select brand' : 'Select category first',
      prefixIcon: Icons.branding_watermark_outlined,
      enabled: enabled,
      isLoading: state.isLoadingBrands,
      items: state.brands,
      selectedItem: state.selectedBrand,
      readOnly: true,
      onChanged: (_) {},
      onSelected: (item) {
        _brandController.text = item.name;

        provider.selectBrand(item);

        _productController.clear();
      },
    );
  }

  // ============================================================
  // PRODUCT
  // ============================================================

  Widget _buildProductField(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    final enabled = state.selectedBrand != null;

    return SearchDropdownField(
      controller: _productController,
      label: 'Product',
      hint: enabled ? 'Search product' : 'Select brand first',
      prefixIcon: Icons.shopping_bag_outlined,
      enabled: enabled,
      isLoading: state.isLoadingProducts,
      items: state.products,
      selectedItem: state.selectedProduct,
      onChanged: provider.searchProducts,
      onSelected: (item) {
        _productController.text = item.name;

        FocusScope.of(context).unfocus();

        provider.selectProduct(item);
      },
    );
  }

  // ============================================================
  // PRODUCT DETAIL
  // ============================================================

  Widget _buildProductDetailCard(AddInventoryState state) {
    final product = state.productDetail!;

    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: ColorName.primarybackground,
              ),
              const SizedBox(width: 8),
              Text('Product Details', style: AppStyle.titleLarge),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 82,
                width: 82,
                decoration: BoxDecoration(
                  color: AppStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        size: 34,
                        color: Colors.grey,
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppStyle.titleMedium),

                    if (product.brandName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          product.brandName,
                          style: AppStyle.bodySmall.copyWith(
                            color: AppStyle.textSecondary,
                          ),
                        ),
                      ),

                    if (product.categoryName.isNotEmpty)
                      Text(
                        product.categoryName,
                        style: AppStyle.bodySmall.copyWith(
                          color: AppStyle.textSecondary,
                        ),
                      ),

                    if (product.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VARIANT
  // ============================================================

  Widget _buildVariantCard(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.borderedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: ColorName.primarybackground),

              const SizedBox(width: 8),

              Text('Select Variant', style: AppStyle.titleLarge),

              const Spacer(),

              TextButton.icon(
                onPressed: () {
                  _showAddVariantDialog(provider);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Variant'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (state.variants.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppStyle.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No variants available. Add a new variant.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: state.variants.map((variant) {
                final selected = state.selectedVariant?.id == variant.id;

                return ChoiceChip(
                  selected: selected,
                  label: Text(
                    variant.value?.isNotEmpty == true
                        ? '${variant.name} - ${variant.value}'
                        : variant.name,
                  ),
                  selectedColor: ColorName.primarybackground.withValues(
                    alpha: 0.15,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? ColorName.primarybackground
                        : AppStyle.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  onSelected: (_) {
                    provider.selectVariant(variant);
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD VARIANT DIALOG
  // ============================================================

  void _showAddVariantDialog(AddInventoryNotifier provider) {
    final nameController = TextEditingController();

    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Add New Variant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: AppStyle.inputDecoration(
                  label: 'Variant Name',
                  hint: 'Example: Size',
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: valueController,
                decoration: AppStyle.inputDecoration(
                  label: 'Variant Value',
                  hint: 'Example: XL',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primarybackground,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                provider.addNewVariant(
                  name: nameController.text,
                  value: valueController.text,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRICING
  // ============================================================

  Widget _buildPricingCard(AddInventoryState state, double finalPrice) {
    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.borderedCardDecoration,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _discountType,
            isExpanded: true,
            decoration: AppStyle.inputDecoration(label: 'Discount Type'),
            items: const [
              DropdownMenuItem<String>(
                value: 'percent',
                child: Text('Percentage (%)', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem<String>(
                value: 'flat',
                child: Text('Flat (₹)', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _discountType = value;
              });
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) {
              setState(() {});
            },
            decoration: AppStyle.inputDecoration(
              label: _discountType == 'percent' ? 'Discount %' : 'Discount ₹',
              hint: '0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPrice(double finalPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppStyle.primaryGradient,
        borderRadius: AppStyle.borderRadiusMedium,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sell_outlined, color: Colors.white),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Selling Price',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  'After discount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${finalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorName.toastErrorBg,
        border: Border.all(color: ColorName.toastErrorBorder),
        borderRadius: AppStyle.borderRadiusMedium,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ColorName.toastErrorIcon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: ColorName.toastErrorText),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Widget _buildSubmitButton(AddInventoryState state) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppStyle.primaryGradient,
          borderRadius: AppStyle.borderRadiusMedium,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: AppStyle.borderRadiusMedium,
            ),
          ),
          onPressed: state.isSubmitting ? null : _submit,
          child: state.isSubmitting
              ? const SizedBox(
                  height: 23,
                  width: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8),
                    Text(
                      'Add Inventory',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT ACTION
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = ref.read(addInventoryProvider);

    if (state.selectedCategory == null) {
      _showMessage('Please select a category');
      return;
    }

    if (state.selectedBrand == null) {
      _showMessage('Please select a brand');
      return;
    }

    if (state.selectedProduct == null) {
      _showMessage('Please select a product');
      return;
    }

    if (state.selectedVariant == null && state.variants.isNotEmpty) {
      _showMessage('Please select a variant');
      return;
    }

    final success = await ref
        .read(addInventoryProvider.notifier)
        .submitInventory(
          mrp: int.parse(_mrpController.text),
          discountType: _discountType,
          discountValue: double.tryParse(_discountController.text) ?? 0,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory added successfully'),
          backgroundColor: ColorName.successLight,
        ),
      );

      Navigator.pop(context);
    } else {
      final message = ref.read(addInventoryProvider).errorMessage;

      _showMessage(message ?? 'Failed to add inventory');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
