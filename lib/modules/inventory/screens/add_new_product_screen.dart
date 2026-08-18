import 'dart:io';

import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/core/shared/widgets/search_dropdown_field.dart';
import 'package:adm_seller/modules/inventory/models/product_request_models.dart';
import 'package:adm_seller/modules/inventory/providers/add_new_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewProductScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const AddNewProductScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<AddNewProductScreen> createState() =>
      _AddNewProductScreenState();
}

class _AddNewProductScreenState extends ConsumerState<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _categoryController = TextEditingController();

  final _brandController = TextEditingController();

  final _alcoholPercentageController = TextEditingController();

  final _complianceController = TextEditingController();

  String? _alcoholType;
  String? _unit;
  String? _packagingType;
  String? _exciseCategory;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(addNewProductProvider.notifier);

      provider.loadCategories();
      provider.loadBrands();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _alcoholPercentageController.dispose();
    _complianceController.dispose();

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
    final state = ref.watch(addNewProductProvider);

    final provider = ref.read(addNewProductProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : ColorName.primarybackground,
        foregroundColor: Colors.white,
        centerTitle: true,

        title: Text(
          widget.isEditMode ? 'Update Product' : 'Add New Product',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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

              _buildBasicInformation(state, provider),

              const SizedBox(height: AppStyle.spaceLarge),

              _buildProductProperties(),

              const SizedBox(height: AppStyle.spaceLarge),
              _buildProductImages(state, provider),

              const SizedBox(height: AppStyle.spaceLarge),

              _buildComplianceSection(),

              const SizedBox(height: AppStyle.spaceLarge),

              _buildVariants(state, provider),

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
            height: 54,
            width: 54,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.add_box_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'New Product Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Provide product details for admin approval.',
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
  // BASIC INFORMATION
  // ============================================================

  Widget _buildBasicInformation(
    AddNewProductState state,
    AddNewProductNotifier provider,
  ) {
    return _buildSectionCard(
      title: 'Basic Information',
      icon: Icons.inventory_2_outlined,

      child: Column(
        children: [
          TextFormField(
            controller: _nameController,

            textInputAction: TextInputAction.next,

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Product name is required';
              }

              return null;
            },

            decoration: _inputDecoration(
              label: 'Product Name *',
              hint: 'Enter product name',
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          TextFormField(
            controller: _descriptionController,

            maxLines: 4,

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }

              return null;
            },

            decoration: _inputDecoration(
              label: 'Description *',
              hint: 'Describe the product',
              prefixIcon: const Icon(Icons.description_outlined),
            ),
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          SearchDropdownField(
            controller: _categoryController,

            label: 'Category *',
            hint: 'Search category',

            prefixIcon: Icons.category_outlined,

            enabled: true,
            readOnly: false,

            isLoading: state.isLoadingCategories,

            items: state.categories,

            selectedItem: state.selectedCategory,

            onChanged: provider.searchCategories,

            onSelected: (item) {
              _categoryController.text = item.name;

              provider.selectCategory(item);
            },
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          SearchDropdownField(
            controller: _brandController,

            label: 'Brand *',
            hint: 'Search brand',

            prefixIcon: Icons.branding_watermark_outlined,

            enabled: true,
            readOnly: false,

            isLoading: state.isLoadingBrands,

            items: state.brands,

            selectedItem: state.selectedBrand,

            onChanged: provider.searchBrands,

            onSelected: (item) {
              _brandController.text = item.name;

              provider.selectBrand(item);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT PROPERTIES
  // ============================================================

  Widget _buildProductProperties() {
    return _buildSectionCard(
      title: 'Product Properties',
      icon: Icons.tune_outlined,

      child: Column(
        children: [
          _buildDropdown(
            label: 'Alcohol Type',
            hint: 'Select alcohol type',
            value: _alcoholType,

            items: const [
              'Whisky',
              'Vodka',
              'Rum',
              'Beer',
              'Wine',
              'Gin',
              'Brandy',
              'Other',
            ],

            onChanged: (value) {
              setState(() {
                _alcoholType = value;
              });
            },
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          _buildDropdown(
            label: 'Unit',
            hint: 'Select unit',
            value: _unit,

            items: const ['ml', 'L', 'Bottle', 'Can', 'Pack'],

            onChanged: (value) {
              setState(() {
                _unit = value;
              });
            },
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          TextFormField(
            controller: _alcoholPercentageController,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alcohol percentage is required';
              }

              final number = double.tryParse(value);

              if (number == null) {
                return 'Enter a valid percentage';
              }

              if (number < 0 || number > 100) {
                return 'Percentage must be between 0 and 100';
              }

              return null;
            },

            decoration: _inputDecoration(
              label: 'Alcohol Percentage *',
              hint: 'Example: 42.8',
              prefixIcon: const Icon(Icons.percent),
            ),
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          _buildDropdown(
            label: 'Packaging Type',
            hint: 'Select packaging type',
            value: _packagingType,

            items: const ['Bottle', 'Can', 'Box', 'Pouch', 'Other'],

            onChanged: (value) {
              setState(() {
                _packagingType = value;
              });
            },
          ),

          const SizedBox(height: AppStyle.spaceMedium),

          _buildDropdown(
            label: 'Excise Category',
            hint: 'Select excise category',
            value: _exciseCategory,

            items: const ['IMFL', 'Beer', 'Wine', 'Other'],

            onChanged: (value) {
              setState(() {
                _exciseCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }

  //====================================
  //IMAGES
  //====================================
  Widget _buildProductImages(
    AddNewProductState state,
    AddNewProductNotifier provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return _buildSectionCard(
      title: 'Product Images',
      icon: Icons.photo_library_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Add clear product images in JPG, JPEG or PNG format.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (state.selectedImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.selectedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final image = state.selectedImages[index];

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(image.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          provider.removeImage(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    if (index == 0)
                      Positioned(
                        left: 5,
                        bottom: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ColorName.primarybackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

          if (state.selectedImages.isNotEmpty) const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.selectedImages.length >= 5
                  ? null
                  : () {
                      _showImageSourcePicker(provider);
                    },
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                state.selectedImages.length >= 5
                    ? 'Maximum 5 Images Uploaded'
                    : (state.selectedImages.isEmpty
                        ? 'Add Product Images'
                        : 'Add More Images (${state.selectedImages.length}/5)'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: state.selectedImages.length >= 5
                    ? Colors.grey
                    : primaryColor,
                side: BorderSide(
                  color: state.selectedImages.length >= 5
                      ? Colors.grey.withValues(alpha: 0.5)
                      : primaryColor,
                ),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // COMPLIANCE
  // ============================================================

  Widget _buildComplianceSection() {
    return _buildSectionCard(
      title: 'Compliance Information',
      icon: Icons.verified_user_outlined,

      child: TextFormField(
        controller: _complianceController,

        maxLines: 4,

        decoration: _inputDecoration(
          label: 'Compliance Information',
          hint: 'Enter compliance / regulatory information',
          prefixIcon: const Icon(Icons.policy_outlined),
        ),
      ),
    );
  }

  // ============================================================
  // VARIANTS
  // ============================================================

  Widget _buildVariants(
    AddNewProductState state,
    AddNewProductNotifier provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return _buildSectionCard(
      title: 'Product Variants *',
      icon: Icons.layers_outlined,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: primaryColor,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    'At least one product variant is required.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (state.variants.isEmpty)
            _buildEmptyVariant()
          else
            ...List.generate(state.variants.length, (index) {
              return _buildVariantItem(state.variants[index], index, provider);
            }),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: () {
                _showAddVariantDialog(provider);
              },

              icon: const Icon(Icons.add),

              label: const Text('Add Variant'),

              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,

                side: BorderSide(color: primaryColor),

                minimumSize: const Size.fromHeight(48),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVariant() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),

      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? context.customColors.border : ColorName.greyBorder,
        ),
      ),

      child: Column(
        children: [
          Icon(Icons.layers_clear_outlined, size: 36, color: ColorName.grey),

          const SizedBox(height: 8),

          const Text(
            'No variants added',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 4),

          const Text(
            'Add at least one variant before submitting.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantItem(
    ProductVariantRequest variant,
    int index,
    AddNewProductNotifier provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppStyle.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: variant.isDefault
              ? primaryColor
              : (isDark ? context.customColors.border : ColorName.greyBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_bar_outlined,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.sku, style: AppStyle.titleMedium),

                const SizedBox(height: 4),

                Text(
                  '${variant.volumeMl} ML',
                  style: AppStyle.bodySmall.copyWith(
                    color: context.customColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    if (variant.isDefault)
                      _buildVariantBadge(
                        'DEFAULT',
                        ColorName.primarybackground,
                      ),

                    const SizedBox(width: 6),

                    _buildVariantBadge(variant.status, Colors.green),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              provider.removeVariant(index);
            },
            icon: const Icon(Icons.delete_outline, color: ColorName.red),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ADD VARIANT DIALOG
  // ============================================================

  void _showAddVariantDialog(AddNewProductNotifier provider) {
    final skuController = TextEditingController();
    final volumeController = TextEditingController();

    bool isDefault = ref.read(addNewProductProvider).variants.isEmpty;

    String status = 'ACTIVE';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.local_bar_outlined,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text('Add Variant'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: skuController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        label: 'SKU *',
                        hint: 'Example: JW-BLACK-750',
                        prefixIcon: const Icon(Icons.qr_code_2_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: volumeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      decoration: _inputDecoration(
                        label: 'Volume (ML) *',
                        hint: 'Example: 750',
                        prefixIcon: const Icon(Icons.local_drink_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: status,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        label: 'Variant Status',
                        hint: 'Select status',
                      ),
                      items: const ['ACTIVE', 'INACTIVE'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          status = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Default Variant',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Use this as the primary product variant',
                      ),
                      value: isDefault,
                      activeColor: primaryColor,
                      onChanged: (value) {
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorName.primarybackground,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Variant'),
                  onPressed: () {
                    final sku = skuController.text.trim();
                    final volume = int.tryParse(volumeController.text.trim());

                    if (sku.isEmpty || volume == null || volume <= 0) {
                      return;
                    }

                    provider.addNewVariant(
                      sku: sku,
                      volumeMl: volume,
                      isDefault: isDefault,
                      status: status,
                    );

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  //=====================================================
  //IMAGE OPTION PICKER
  //=====================================================
  void _showImageSourcePicker(AddNewProductNotifier provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Product Images',
                            style: AppStyle.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Choose how you want to add photos',
                            style: AppStyle.bodySmall.copyWith(
                              color: context.customColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Camera
                _buildImageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take Photo',
                  subtitle: 'Use your camera to capture a product photo',
                  onTap: () {
                    Navigator.pop(context);

                    provider.takePhoto();
                  },
                ),

                const SizedBox(height: 10),

                // Gallery
                _buildImageSourceOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle: 'Select one or multiple product images',
                  onTap: () {
                    Navigator.pop(context);

                    provider.pickImages();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyle.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.caption.copyWith(
                      color: context.customColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,

      isExpanded: true,

      decoration: _inputDecoration(label: label, hint: hint),

      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,

          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),

      onChanged: onChanged,
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
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
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
                  color: primaryColor.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(icon, color: primaryColor, size: 20),
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
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 18),

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

  Widget _buildSubmitButton(AddNewProductState state) {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppStyle.primaryGradient,

          borderRadius: AppStyle.borderRadiusMedium,
        ),

        child: ElevatedButton(
          onPressed: state.isSubmitting ? null : _submit,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,

            foregroundColor: Colors.white,

            shadowColor: Colors.transparent,

            shape: RoundedRectangleBorder(
              borderRadius: AppStyle.borderRadiusMedium,
            ),
          ),

          child: state.isSubmitting
              ? const SizedBox(
                  height: 23,
                  width: 23,

                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Icon(Icons.send_outlined),

                    const SizedBox(width: 8),

                    Text(
                      widget.isEditMode
                          ? 'Update Product'
                          : 'Submit Product Request',

                      style: const TextStyle(
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

    final state = ref.read(addNewProductProvider);

    final provider = ref.read(addNewProductProvider.notifier);

    if (state.selectedImages.isEmpty) {
      _showMessage('Please select at least one product image');
      return;
    }
    if (state.selectedCategory == null) {
      _showMessage('Please select a category');
      return;
    }

    if (state.selectedBrand == null) {
      _showMessage('Please select a brand');
      return;
    }

    if (state.variants.isEmpty) {
      _showMessage('Please add at least one variant');
      return;
    }

    final alcoholPercentage = double.tryParse(
      _alcoholPercentageController.text.trim(),
    );

    if (alcoholPercentage == null) {
      _showMessage('Enter a valid alcohol percentage');
      return;
    }

    final success = await provider.submitProduct(
      name: _nameController.text,
      description: _descriptionController.text,
      brandId: state.selectedBrand!.id,
      categoryId: state.selectedCategory!.id,
      alcoholType: _alcoholType,
      unit: _unit,
      alcoholPercentage: alcoholPercentage,
      packagingType: _packagingType,
      exciseCategory: _exciseCategory,
      complianceInfo: _complianceController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product request submitted successfully'),
          backgroundColor: ColorName.successLight,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
