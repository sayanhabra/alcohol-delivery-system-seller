import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/modules/inventory/models/category_brand_data.dart';
import 'package:adm_seller/modules/inventory/models/product_details_response.dart';
import 'package:adm_seller/modules/inventory/screens/add_new_product_screen.dart';
import 'package:custom_dropdown_pro/custom_dropdown_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/add_inventory_provider.dart';

class AddInventoryScreen extends ConsumerStatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  ConsumerState<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends ConsumerState<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  // final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _productController = TextEditingController();

  final _mrpController = TextEditingController();
  final _discountController = TextEditingController();
  final _availableQtyController = TextEditingController();
  final _reserveQtyController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String _discountType = 'percent';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addInventoryProvider.notifier).loadInitialData();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _brandController.dispose();
    _productController.dispose();
    _mrpController.dispose();
    _discountController.dispose();

    super.dispose();
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: isDark
          ? ColorName.inputFillDark
          : ColorName.inputFillLight.withValues(alpha: 0.58),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white24 : ColorName.inputBorderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? ColorName.secondary : ColorName.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  BoxDecoration _cardDecoration({bool bordered = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? context.customColors.cardBackground : Colors.white,
      borderRadius: AppStyle.borderRadiusLarge,
      border: bordered
          ? Border.all(
              color: isDark ? context.customColors.border : AppStyle.borderColor,
            )
          : null,
      boxShadow: bordered ? null : [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addInventoryProvider);

    final provider = ref.read(addInventoryProvider.notifier);

    final mrp = int.tryParse(_mrpController.text) ?? 0;

    final discount = int.tryParse(_discountController.text) ?? 0;

    final finalPrice = provider.calculateFinalPrice(
      mrp: mrp,
      discountType: _discountType,
      discountValue: discount,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : ColorName.primarybackground,
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
              SizedBox(height: 15),
              _buildQuantityCard(state, provider),

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(bordered: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: (isDark ? ColorName.secondary : ColorName.primarybackground).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isDark ? ColorName.secondary : ColorName.primarybackground, size: 20),
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
    return SearchableDropdownField<CategoryBrandData>(
      items: const [], // not used when asyncItems is provided
      itemLabel: (item) => item.name,
      onSelected: (item) {
        _categoryController.text = item.name;
        provider.selectCategory(item);
      },
      hintText: 'Search category',
      textController: _categoryController,
      asyncItems: (query) => provider.fetchCategories(query),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No categories found'),
      ),
      mode: DropdownMode.dialog,
      style: const DropdownStyle(
        // customize as needed
      ),
      behavior: const DropdownBehavior(clearable: true),
      // mode: DropdownMode.bottomSheet, // or overlay
      enabled: true,
      // validator: ... optional
    );
  }

  // ============================================================
  // BRAND
  // ============================================================

  Widget _buildBrandField(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    return SearchableDropdownField<CategoryBrandData>(
      items: const [],
      itemLabel: (item) => item.name,
      onSelected: (item) {
        _brandController.text = item.name;
        provider.selectBrand(item);
      },
      hintText: 'Search brand',
      textController: _brandController,
      asyncItems: (query) => provider.fetchBrands(query),
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No brands found'),
      ),
      mode: DropdownMode.dialog,
    );
  }

  //===========================================
  //Quantities
  //===========================================
  Widget _buildQuantityCard(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildSectionCard(
      title: 'Inventory Quantities',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Quantity Field
              Expanded(
                child: TextFormField(
                  initialValue: state.availableQuantity > 0
                      ? state.availableQuantity.toString()
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    label: 'Available Qty',
                    hint: '0',
                  ),
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 0;
                    provider.setAvailableQuantity(qty);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Reserve Quantity Field
              Expanded(
                child: TextFormField(
                  initialValue: state.reserveQuantity > 0
                      ? state.reserveQuantity.toString()
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    label: 'Reserve Qty',
                    hint: '0',
                  ),
                  // controller: _re,
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 0;
                    provider.setReserveQuantity(qty);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Reserve Quantity Description
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: (isDark ? ColorName.secondary : ColorName.primarybackground).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Reserved stock is set aside for pending orders or back-ups and is not listed for public sale.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? context.customColors.secondaryText : ColorName.primarybackground.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT
  // ============================================================

  Widget _buildProductField(
    AddInventoryState state,
    AddInventoryNotifier provider,
  ) {
    return Column(
      children: [
        SearchableDropdownField<CategoryBrandData>(
          items: const [],
          itemLabel: (item) => item.name,
          onSelected: (item) {
            _productController.text = item.name;
            provider.selectProduct(item);
          },
          hintText: 'Search product',
          textController: _productController,
          asyncItems: (query) => provider.fetchProducts(query),
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No products found'),
          ),
          mode: DropdownMode.dialog,
        ),
        if (!state.isLoadingProducts && state.products.isEmpty) ...[
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _onAddProduct,

              icon: const Icon(Icons.add),

              label: const Text('Add New Product'),

              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark ? ColorName.secondary : ColorName.primarybackground,

                side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? ColorName.secondary : ColorName.primarybackground),

                minimumSize: const Size.fromHeight(48),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _onAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNewProductScreen()),
    );
    // final result = await context.push(AppRoutes.addProduct);
    if (!mounted) return;

    if (result == true) {
      // Product request was successfully submitted.
      //
      // Later you can refresh the product
      // search API here.
      ref
          .read(addInventoryProvider.notifier)
          .searchProducts(_productController.text);
    }
  }
  // ============================================================
  // PRODUCT DETAIL
  // ============================================================

  Widget _buildProductDetailCard(AddInventoryState state) {
    final product = state.productDetail!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;

    final images = List<ProductImageResponse>.from(product.images)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(bordered: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Text('Product Details', style: AppStyle.titleLarge),
            ],
          ),

          const SizedBox(height: 18),

          // ============================================================
          // PRODUCT IMAGE + INFORMATION
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------------
              // IMAGE CAROUSEL
              // --------------------------------------------------------
              SizedBox(
                height: 110,
                width: 110,
                child: images.isNotEmpty
                    ? _ProductImageCarousel(images: images)
                    : Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // --------------------------------------------------------
              // PRODUCT INFORMATION
              // --------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppStyle.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 7),

                    // BRAND
                    if (product.brand != null && product.brand!.name.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.branding_watermark_outlined,
                            size: 15,
                            color: ColorName.grey,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              product.brand!.name,
                              style: AppStyle.bodySmall.copyWith(
                                color: context.customColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    // CATEGORY
                    if (product.category != null &&
                        product.category!.name.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 15,
                            color: ColorName.grey,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              product.category!.name,
                              style: AppStyle.bodySmall.copyWith(
                                color: context.customColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    // ALCOHOL INFORMATION
                    if (product.alcoholPercentage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.percent,
                              size: 15,
                              color: ColorName.grey,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              '${product.alcoholPercentage}% ABV',
                              style: AppStyle.bodySmall.copyWith(
                                color: context.customColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // ============================================================
          // DESCRIPTION
          // ============================================================
          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppStyle.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.customColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          // ============================================================
          // PRODUCT STATUS
          // ============================================================
          if (product.status != null && product.status!.isNotEmpty) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  'Status:',
                  style: AppStyle.bodySmall.copyWith(
                    color: AppStyle.textSecondary,
                  ),
                ),

                const SizedBox(width: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorName.successLight.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.status!,
                    style: AppStyle.bodySmall.copyWith(
                      color: ColorName.successLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(bordered: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.layers_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Text('Product Variant', style: AppStyle.titleLarge),

              const Spacer(),

              TextButton.icon(
                onPressed: state.productDetail == null
                    ? null
                    : () {
                        _showAddVariantDialog(context, state.productDetail!.id);
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
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
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
                    variant.sku.isNotEmpty == true
                        ? '${variant.sku} - ${variant.volumeMl}'
                        : variant.sku,
                  ),
                  selectedColor: primaryColor.withValues(
                    alpha: 0.15,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? primaryColor
                        : (isDark ? Colors.white70 : AppStyle.textPrimary),
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

  Future<void> _showAddVariantDialog(
    BuildContext context,
    int productId,
  ) async {
    final skuController = TextEditingController();

    final volumeController = TextEditingController();

    bool isDefault = false;

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final inventoryState = ref.watch(addInventoryProvider);

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_to_photos_outlined,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Variant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: skuController,
                      decoration: _inputDecoration(
                        label: 'SKU Code',
                        hint: 'e.g. SKU-123456',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'SKU is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: volumeController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: 'Volume (ml)',
                        hint: 'e.g. 750',
                      ),
                      validator: (v) {
                        final volume = int.tryParse(v?.trim() ?? '');
                        if (volume == null || volume <= 0) {
                          return 'Enter valid volume';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      activeColor: ColorName.primarybackground,
                      title: const Text(
                        'Default Variant',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Use this as the default product variant',
                      ),
                      onChanged: inventoryState.isAddingVariant
                          ? null
                          : (value) {
                              setDialogState(() {
                                isDefault = value;
                              });
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: inventoryState.isAddingVariant
                      ? null
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
                  child: const Text('Cancel'),
                ),

                FilledButton.icon(
                  onPressed: inventoryState.isAddingVariant
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final success = await ref
                              .read(addInventoryProvider.notifier)
                              .addProductVariant(
                                productId: productId,
                                sku: skuController.text.trim(),
                                volumeMl: int.parse(
                                  volumeController.text.trim(),
                                ),
                                isDefault: isDefault,
                              );

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.pop(dialogContext, true);
                          }
                        },
                  icon: inventoryState.isAddingVariant
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    inventoryState.isAddingVariant
                        ? 'Adding...'
                        : 'Add Variant',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorName.primarybackground,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    skuController.dispose();
    volumeController.dispose();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Variant added successfully')),
      );
    }
  }

  // ============================================================
  // PRICING
  // ============================================================

  Widget _buildPricingCard(AddInventoryState state, int finalPrice) {
    final mrp = int.tryParse(_mrpController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;

    return Container(
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(bordered: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // SECTION HEADER
          // ============================================================
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.currency_rupee,
                  color: primaryColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pricing', style: AppStyle.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Set your selling price and discount',
                      style: AppStyle.bodySmall.copyWith(
                        color: context.customColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ============================================================
          // MRP
          // ============================================================
          TextFormField(
            controller: _mrpController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              setState(() {});
            },
            validator: (value) {
              final text = _mrpController.text.trim();

              if (text.isEmpty) {
                return 'Please enter MRP';
              }

              final value = int.tryParse(text);

              if (value == null || value <= 0) {
                return 'Enter a valid MRP';
              }

              return null;
            },
            decoration: _inputDecoration(
              label: 'MRP',
              hint: 'Enter MRP',
              prefixIcon: const Icon(Icons.currency_rupee),
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // DISCOUNT ROW
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount Type
              Expanded(
                flex: 5,
                child: DropdownButtonFormField<String>(
                  value: _discountType,
                  isExpanded: true,
                  menuMaxHeight: 280,
                  decoration: _inputDecoration(
                    label: 'Discount Type',
                    prefixIcon: const Icon(Icons.local_offer_outlined),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'percent',
                      child: Text(
                        'Percentage (%)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'flat',
                      child: Text(
                        'Flat (₹)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _discountType = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Discount Value
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    setState(() {});
                  },
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return null;
                    }

                    final discount = int.tryParse(text);

                    if (discount == null || discount < 0) {
                      return 'Invalid discount';
                    }

                    if (_discountType == 'percent' && discount > 100) {
                      return 'Max 100%';
                    }

                    if (_discountType == 'flat' && mrp > 0 && discount > mrp) {
                      return 'Cannot exceed MRP';
                    }

                    return null;
                  },
                  decoration: _inputDecoration(
                    label: _discountType == 'percent'
                        ? 'Discount %'
                        : 'Discount Amount',
                    hint: '0',
                    prefixIcon: Icon(
                      _discountType == 'percent'
                          ? Icons.percent
                          : Icons.currency_rupee,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ============================================================
          // PRICE BREAKDOWN
          // ============================================================
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? context.customColors.border : ColorName.greyBorder,
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  label: 'MRP',
                  value: mrp > 0 ? '₹${mrp.toString()}' : '₹0',
                ),

                const SizedBox(height: 10),

                _buildPriceRow(
                  label: 'Discount',
                  value: discount > 0
                      ? _discountType == 'percent'
                            ? '${discount.toStringAsFixed(0)}%'
                            : '₹${discount.toStringAsFixed(0)}'
                      : '₹0',
                  valueColor: context.customColors.success,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // FINAL PRICE
                Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.sell_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Selling Price',
                            style: AppStyle.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Price customer will pay',
                            style: AppStyle.bodySmall.copyWith(
                              color: context.customColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '₹${finalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ============================================================
          // SAVING MESSAGE
          // ============================================================
          if (mrp > 0 && discount > 0 && finalPrice < mrp) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.customColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.customColors.success.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 18,
                    color: context.customColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer saves ₹${(mrp - finalPrice).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: context.customColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppStyle.bodySmall.copyWith(color: context.customColors.secondaryText),
          ),
        ),
        Text(
          value,
          style: AppStyle.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? Colors.white : AppStyle.textPrimary),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppStyle.spaceLarge),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? context.customColors.danger.withValues(alpha: 0.1) : ColorName.toastErrorBg,
        border: Border.all(
          color: isDark ? context.customColors.danger.withValues(alpha: 0.4) : ColorName.toastErrorBorder,
        ),
        borderRadius: AppStyle.borderRadiusMedium,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: isDark ? context.customColors.danger : ColorName.toastErrorIcon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: isDark ? Colors.redAccent.shade100 : ColorName.toastErrorText),
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

    // if (state.selectedCategory == null) {
    //   _showMessage('Please select a category');
    //   return;
    // }

    // if (state.selectedBrand == null) {
    //   _showMessage('Please select a brand');
    //   return;
    // }

    if (state.selectedProduct == null) {
      _showMessage('Please select a product');
      return;
    }

    if (state.selectedVariant == null && state.variants.isNotEmpty) {
      _showMessage('Please select a variant');
      return;
    }

    final discount = int.tryParse(_discountController.text) ?? 0;
    final mrp = int.tryParse(_mrpController.text) ?? 0;

    // MRP Validation
    if (mrp <= 0) {
      _showMessage('Please enter a valid MRP');
      return;
    }

    // Discount Validation (Ensures discount doesn't exceed MRP or percent limit)
    if (_discountType == 'percent' && discount > 100) {
      _showMessage('Discount percentage cannot exceed 100%');
      return;
    } else if (_discountType == 'amount' && discount > mrp) {
      _showMessage('Discount amount cannot be greater than MRP');
      return;
    }

    // Available Quantity Validation
    if (state.availableQuantity <= 0) {
      _showMessage('Please enter a valid available quantity');
      return;
    }

    final success = await ref
        .read(addInventoryProvider.notifier)
        .submitInventory(
          mrp: int.parse(_mrpController.text),
          discountType: _discountType,
          discountValue: int.tryParse(_discountController.text)?.toInt() ?? 0,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory added successfully'),
          backgroundColor: ColorName.successLight,
        ),
      );

      context.pop(context);
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

class _ProductImageCarousel extends StatefulWidget {
  final List<ProductImageResponse> images;

  const _ProductImageCarousel({required this.images});

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // ==========================================================
        // IMAGE
        // ==========================================================
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];

                return Container(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
                  child: Image.network(
                    image.url,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },

                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 34,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // ==========================================================
        // PAGE INDICATORS
        // ==========================================================
        if (widget.images.length > 1) ...[
          const SizedBox(height: 7),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              final isSelected = index == _currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 5,
                width: isSelected ? 14 : 5,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? ColorName.secondary : ColorName.primarybackground)
                      : ColorName.greyLight1,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
