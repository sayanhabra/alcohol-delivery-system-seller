import 'package:adm_seller/core/config/app_icons.dart';
import 'package:adm_seller/core/config/app_router.dart';
import 'package:adm_seller/core/config/app_theme.dart';
import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/modules/inventory/models/inventory_list_response.dart';
import 'package:adm_seller/modules/inventory/models/inventory_request_models.dart';
import 'package:adm_seller/modules/inventory/providers/inventory_provider.dart';
import 'package:adm_seller/modules/inventory/screens/add_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryProvider.notifier).loadInventory();
    });
  }

  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _stockFilter = 'ALL';
  String _categoryFilter = 'ALL';

  bool _showFilters = false;

  Future<void> _showManageInventoryDialog(
    BuildContext context,
    InventoryItem item,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ManageInventorySheet(item: item);
      },
    );

    if (result == true && mounted) {
      await ref.read(inventoryProvider.notifier).refresh();
    }
  }

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    return items.where((item) {
      final product = item.product;
      final variant = item.variant;

      // ============================================================
      // SEARCH
      // ============================================================

      final query = _searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          (product?.name.toLowerCase().contains(query) ?? false) ||
          (product?.brand?.name.toLowerCase().contains(query) ?? false) ||
          (product?.category?.name.toLowerCase().contains(query) ?? false) ||
          (variant?.sku.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) {
        return false;
      }

      // ============================================================
      // STATUS
      // ============================================================

      if (_statusFilter != 'ALL' &&
          item.status.toUpperCase() != _statusFilter) {
        return false;
      }

      // ============================================================
      // STOCK
      // ============================================================

      switch (_stockFilter) {
        case 'IN_STOCK':
          if (item.availableStock <= 0) {
            return false;
          }
          break;

        case 'LOW_STOCK':
          if (item.availableStock <= 0 || item.availableStock > 10) {
            return false;
          }
          break;

        case 'OUT_OF_STOCK':
          if (item.availableStock > 0) {
            return false;
          }
          break;
      }

      // ============================================================
      // CATEGORY
      // ============================================================

      if (_categoryFilter != 'ALL' &&
          product?.category?.name != _categoryFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : ColorName.primarybackground,
        title: const Text(
          'My Inventory',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),

        actions: [
          IconButton(
            tooltip: _showFilters ? 'Hide filters' : 'Search & filter',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            color: Colors.white,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _showFilters ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(_showFilters),
              ),
            ),
          ),

          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isRefreshing
                ? null
                : () {
                    ref.read(inventoryProvider.notifier).refresh();
                  },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),

          const SizedBox(width: 6),
        ],
      ),

      floatingActionButton: _buildAddInventoryButton(),

      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(inventoryProvider.notifier).refresh();
        },
        child: _buildBody(state, isDark),
      ),
    );
  }

  Widget _buildBody(InventoryState state, bool isDark) {
    if (state.isLoading && state.items.isEmpty) {
      return Container(
        color: (isDark ? ColorName.primaryBackgroundDark : Colors.white)
            .withValues(alpha: 0.7),
        child: Center(
          child: Lottie.asset(AppIcons.loading, height: 200, width: 200),
        ),
      );
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return _buildError(state.errorMessage!);
    }

    final filteredItems = _getFilteredItems(state.items);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (_showFilters) ...[
          _buildInventoryFilters(state),

          const SizedBox(height: 16),
        ],
        _buildSummaryHeader(state),

        const SizedBox(height: 16),

        // NEW FILTER
        const SizedBox(height: 16),

        // RESULT COUNT
        Row(
          children: [
            Expanded(
              child: Text(
                filteredItems.isEmpty
                    ? 'No inventory found'
                    : '${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                ),
              ),
            ),

            if (_hasActiveFilters())
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
          ],
        ),

        const SizedBox(height: 4),

        if (filteredItems.isEmpty)
          _buildNoFilterResult()
        else
          ...filteredItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InventoryCard(
                item: item,
                isDark: isDark,
                onManage: () {
                  _showManageInventoryDialog(context, item);
                },
              ),
            ),
          ),

        if (filteredItems.isNotEmpty && state.pagination != null)
          _buildPagination(state.pagination!),
      ],
    );
  }

  Widget _buildInventoryFilters(InventoryState state) {
    final categories =
        state.items
            .map((item) => item.product?.category?.name)
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // SEARCH
        // ==========================================================
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search product, brand or SKU',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? ColorName.secondary : ColorName.primarybackground,
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ==========================================================
        // FILTER CHIPS / DROPDOWNS
        // ==========================================================
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterDropdown(
                value: _statusFilter,
                label: 'Status',
                icon: Icons.circle_outlined,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                  DropdownMenuItem(
                    value: 'AVAILABLE',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),

              const SizedBox(width: 8),

              _buildFilterDropdown(
                value: _stockFilter,
                label: 'Stock',
                icon: Icons.inventory_2_outlined,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Stock')),
                  DropdownMenuItem(value: 'IN_STOCK', child: Text('In Stock')),
                  DropdownMenuItem(
                    value: 'LOW_STOCK',
                    child: Text('Low Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'OUT_OF_STOCK',
                    child: Text('Out of Stock'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _stockFilter = value;
                  });
                },
              ),

              if (categories.isNotEmpty) ...[
                const SizedBox(width: 8),

                _buildFilterDropdown(
                  value: _categoryFilter,
                  label: 'Category',
                  icon: Icons.category_outlined,
                  items: [
                    const DropdownMenuItem(
                      value: 'ALL',
                      child: Text('All Categories'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _categoryFilter = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.trim().isNotEmpty ||
        _statusFilter != 'ALL' ||
        _stockFilter != 'ALL' ||
        _categoryFilter != 'ALL';
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = 'ALL';
      _stockFilter = 'ALL';
      _categoryFilter = 'ALL';
    });
  }

  Widget _buildNoFilterResult() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: ColorName.primarybackground.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: ColorName.primarybackground,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No inventory found',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            'Try changing your search or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),

          if (_hasActiveFilters()) ...[
            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 135, maxWidth: 190),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
          items: items,
          onChanged: onChanged,
          selectedItemBuilder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return items.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: isDark ? ColorName.secondary : ColorName.primarybackground),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      item.value == 'ALL'
                          ? label
                          : item.child is Text
                          ? (item.child as Text).data ?? label
                          : label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(InventoryState state) {
    final totalItems = state.items.length;

    final totalStock = state.items.fold<int>(
      0,
      (sum, item) => sum + item.availableQuantity,
    );

    final available = state.items.where((item) => item.isAvailable).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppStyle.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyle.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage your products and stock',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Products',
                  value: totalItems.toString(),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Stock',
                  value: totalStock.toString(),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Available',
                  value: available.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddInventoryButton() {
    return FloatingActionButton.extended(
      backgroundColor: ColorName.primarybackground,
      foregroundColor: Colors.white,
      elevation: 5,
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
        );

        if (!mounted) return;

        ref.read(inventoryProvider.notifier).refresh();
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Inventory',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),

        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: ColorName.primarybackground.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: ColorName.primarybackground,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Your inventory is empty',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),

        Text(
          'Add products to start selling from your store.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
          ),
        ),

        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
            );

            if (!mounted) return;

            ref.read(inventoryProvider.notifier).refresh();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Inventory'),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),

        const Icon(
          Icons.error_outline_rounded,
          size: 60,
          color: ColorName.dangerLight,
        ),

        const SizedBox(height: 16),

        const Text(
          'Unable to load inventory',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),

        Text(
          message,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 20),

        OutlinedButton.icon(
          onPressed: () {
            ref.read(inventoryProvider.notifier).loadInventory();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildPagination(InventoryPagination pagination) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Page ${pagination.page} of ${pagination.totalPages} • '
          '${pagination.total} inventory items',
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isDark;
  final VoidCallback? onManage;

  const _InventoryCard({
    required this.item,
    required this.isDark,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final variant = item.variant;

    final imageUrl = product?.images.isNotEmpty == true
        ? product!.images.first.url
        : null;

    final availableStock = item.availableStock;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================================================
          // PRODUCT HEADER
          // ========================================================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(imageUrl),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product?.name ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // const SizedBox(width: 8),

                          // _StatusBadge(status: item.status),
                        ],
                      ),

                      const SizedBox(height: 7),

                      if (product?.brand != null)
                        Text(
                          product!.brand!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.65),
                          ),
                        ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          if (product?.category != null) ...[
                            Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                product!.category!.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],

                          if (variant != null) ...[
                            const SizedBox(width: 10),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${variant.volumeMl} ml',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // PRICE
          // ========================================================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : ColorName.primarybackground.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PriceInfo(
                    label: 'MRP',
                    value: '₹${(item.mrp / 100).toStringAsFixed(0)}',
                    crossed: true,
                  ),
                ),

                Expanded(
                  child: _PriceInfo(
                    label: 'Selling Price',
                    value: '₹${(item.sellingPrice / 100).toStringAsFixed(0)}',
                    highlighted: true,
                  ),
                ),

                Expanded(
                  child: _PriceInfo(
                    label: 'Discount',
                    value:
                        '₹${item.discountType == "PERCENTAGE" ? ((item.mrp - item.sellingPrice) / 100).toStringAsFixed(0) : (item.discountValue / 100).toStringAsFixed(0)}',
                    discount: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ========================================================
          // STOCK
          // ========================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _StockInfo(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Stock',
                    value: '${item.availableQuantity}',
                  ),
                ),

                Expanded(
                  child: _StockInfo(
                    icon: Icons.lock_outline,
                    label: 'Reserved',
                    value: '${item.reservedQuantity}',
                  ),
                ),

                Expanded(
                  child: _StockInfo(
                    icon: Icons.check_circle_outline,
                    label: 'Available',
                    value: '$availableStock',
                    valueColor: availableStock > 0
                        ? context.customColors.success
                        : context.customColors.danger,
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // FOOTER
          // ========================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'SKU: ${variant?.sku ?? '-'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.tune_rounded, size: 17),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : ColorName.primarybackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      height: 88,
      width: 76,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppStyle.backgroundColor,
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.liquor_outlined,
                size: 32,
                color: Colors.grey,
              ),
            )
          : const Icon(Icons.liquor_outlined, size: 32, color: Colors.grey),
    );
  }
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool crossed;
  final bool highlighted;
  final bool discount;

  const _PriceInfo({
    required this.label,
    required this.value,
    this.crossed = false,
    this.highlighted = false,
    this.discount = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;

    if (highlighted) {
      color = ColorName.primarybackground;
    } else if (discount) {
      color = ColorName.successLight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: highlighted ? 16 : 13,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
            color: color,
            decoration: crossed ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

class _StockInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StockInfo({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.55),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class _StatusBadge extends StatelessWidget {
//   final String status;

//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final normalized = status.toUpperCase();

//     final isAvailable = normalized == 'AVAILABLE';

//     final color = isAvailable ? ColorName.successLight : ColorName.dangerLight;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.10),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             height: 6,
//             width: 6,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),

//           const SizedBox(width: 5),

//           Text(
//             status,
//             style: TextStyle(
//               color: color,
//               fontSize: 9,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ManageInventorySheet extends ConsumerStatefulWidget {
  final InventoryItem item;

  const _ManageInventorySheet({required this.item});

  @override
  ConsumerState<_ManageInventorySheet> createState() =>
      _ManageInventorySheetState();
}

class _ManageInventorySheetState extends ConsumerState<_ManageInventorySheet> {
  late final TextEditingController _mrpController;
  // late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _reservedController;
  late final TextEditingController _discountController;

  late String _discountType;

  // late String _status;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _mrpController = TextEditingController(
      text: (widget.item.mrp / 100).toStringAsFixed(0),
    );

    // _sellingPriceController = TextEditingController(
    //   text: (widget.item.sellingPrice / 100).toStringAsFixed(0),
    // );
    _discountController = TextEditingController(
      text: widget.item.discountType == "PERCENTAGE"
          ? widget.item.discountValue.toString()
          : (widget.item.discountValue / 100).toStringAsFixed(0),
    );

    _discountType = widget.item.discountType;
    _stockController = TextEditingController(
      text: widget.item.availableQuantity.toString(),
    );

    _reservedController = TextEditingController(
      text: widget.item.reservedQuantity.toString(),
    );

    // _status = _normalizeStatus(widget.item.status);
  }

  // String _normalizeStatus(String status) {
  //   switch (status.toUpperCase()) {
  //     case 'AVAILABLE':
  //       return 'AVAILABLE';

  //     case 'UNAVAILABLE':
  //       return 'UNAVAILABLE';

  //     case 'OUT_OF_STOCK':
  //       return 'OUT_OF_STOCK';

  //     default:
  //       return 'AVAILABLE';
  //   }
  // }

  @override
  void dispose() {
    _mrpController.dispose();
    // _sellingPriceController.dispose();
    _stockController.dispose();
    _reservedController.dispose();

    super.dispose();
  }

  int get _calculatedSellingPrice {
    final mrp = int.tryParse(_mrpController.text.trim()) ?? 0;

    final discount = int.tryParse(_discountController.text.trim()) ?? 0;

    if (mrp <= 0 || discount <= 0) {
      return mrp;
    }

    if (_discountType == 'PERCENTAGE') {
      final discountAmount = (mrp * discount) ~/ 100;

      return (mrp - discountAmount).clamp(0, mrp);
    }

    return (mrp - discount).clamp(0, mrp);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);

    final isProcessing =
        state.isUpdating && state.processingInventoryId == widget.item.id;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? context.customColors.cardBackground : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // HANDLE
                  // =================================================
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // HEADER
                  // =================================================
                  Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Manage Inventory',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.item.product?.name ?? 'Inventory item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // =================================================
                  // PRICING
                  // =================================================
                  _sectionTitle(
                    icon: Icons.payments_outlined,
                    title: 'Pricing',
                  ),

                  const SizedBox(height: 12),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _integerField(
                  //         controller: _mrpController,
                  //         label: 'MRP',
                  //         icon: Icons.currency_rupee,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _integerField(
                  //         controller: _sellingPriceController,
                  //         label: 'Selling Price',
                  //         icon: Icons.sell_outlined,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  _integerField(
                    controller: _mrpController,
                    label: 'MRP',
                    icon: Icons.currency_rupee,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          value: _discountType,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'Discount',
                            prefixIcon: const Icon(Icons.local_offer_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'FLAT',
                              child: Text('Flat'),
                            ),
                            DropdownMenuItem(
                              value: 'PERCENTAGE',
                              child: Text('Percentage'),
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

                      Expanded(
                        flex: 5,
                        child: _integerField(
                          controller: _discountController,
                          label: _discountType == 'PERCENTAGE'
                              ? 'Discount %'
                              : 'Discount Amount',
                          icon: Icons.discount_outlined,
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildSellingPricePreview(),

                  const SizedBox(height: 20),

                  // =================================================
                  // STOCK
                  // =================================================
                  _sectionTitle(icon: Icons.inventory_outlined, title: 'Stock'),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _integerField(
                          controller: _stockController,
                          label: 'Stock',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _integerField(
                          controller: _reservedController,
                          label: 'Reserved',
                          icon: Icons.lock_outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // STATUS
                  // =================================================
                  // _sectionTitle(
                  //   icon: Icons.toggle_on_outlined,
                  //   title: 'Availability',
                  // ),

                  // const SizedBox(height: 12),

                  // DropdownButtonFormField<String>(
                  //   value: _status,
                  //   isExpanded: true,
                  //   decoration: AppStyle.inputDecoration(
                  //     label: 'Status',
                  //     prefixIcon: const Icon(Icons.circle_outlined),
                  //   ),
                  //   items: const [
                  //     DropdownMenuItem(
                  //       value: 'AVAILABLE',
                  //       child: Text('Available'),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: 'UNAVAILABLE',
                  //       child: Text('Unavailable'),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: 'OUT_OF_STOCK',
                  //       child: Text('Out of Stock'),
                  //     ),
                  //   ],
                  //   onChanged: isProcessing
                  //       ? null
                  //       : (value) {
                  //           if (value == null) {
                  //             return;
                  //           }

                  //           setState(() {
                  //             _status = value;
                  //           });
                  //         },
                  // ),
                  const SizedBox(height: 24),

                  // =================================================
                  // SAVE
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isProcessing ? null : _updateInventory,
                      icon: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        isProcessing ? 'Updating...' : 'Save Changes',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =================================================
                  // DELETE
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : _deleteInventory,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete Inventory'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? context.customColors.danger : ColorName.dangerLight,
                        side: BorderSide(
                          color: (isDark ? context.customColors.danger : ColorName.dangerLight).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellingPricePreview() {
    final sellingPrice = _calculatedSellingPrice;

    final mrp = int.tryParse(_mrpController.text.trim()) ?? 0;

    final discount = int.tryParse(_discountController.text.trim()) ?? 0;

    final hasDiscount = mrp > 0 && discount > 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppStyle.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? context.customColors.border : ColorName.primarybackground.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sell_outlined,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Selling Price',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.customColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '₹${_formatAmount(sellingPrice)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          if (hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: ColorName.successLight.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                _discountType == 'PERCENTAGE'
                    ? '$discount% OFF'
                    : '₹${_formatAmount(discount)} OFF',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ColorName.successLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatAmount(int value) {
    return value.toString();
  }

  Widget _integerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: _inputDecoration(
        label: label,
        hint: 'Enter $label',
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        final number = int.tryParse(value?.trim() ?? '');

        if (number == null || number < 0) {
          return 'Invalid value';
        }

        return null;
      },
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? ColorName.secondary : ColorName.primarybackground;
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: primaryColor),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Future<void> _updateInventory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mrp = int.tryParse(_mrpController.text.trim());

    final discount = int.tryParse(_discountController.text.trim());

    final stock = int.tryParse(_stockController.text.trim());

    final reserved = int.tryParse(_reservedController.text.trim());

    if (mrp == null || discount == null || stock == null || reserved == null) {
      return;
    }

    if (_discountType == 'PERCENTAGE') {
      if (discount > 100) {
        _showError('Percentage discount cannot exceed 100%.');
        return;
      }
    } else {
      if (discount > mrp) {
        _showError('Flat discount cannot be greater than MRP.');
        return;
      }
    }

    // ============================================================
    // STOCK VALIDATION
    // ============================================================

    if (reserved > stock) {
      _showError('Reserved quantity cannot be greater than stock.');
      return;
    }

    final request = UpdateInventoryRequest(
      mrp: mrp * 100,
      discountType: _discountType,
      discountValue: _discountType == 'FLAT'
          ? (int.parse(_discountController.text) * 100)
          : (int.parse(_discountController.text)),
      availableQuantity: stock,
      reservedQuantity: reserved,
      // status: _status,
    );

    final success = await ref
        .read(inventoryProvider.notifier)
        .updateInventory(inventoryId: widget.item.id, request: request);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory updated successfully')),
      );
    } else {
      final message =
          ref.read(inventoryProvider).errorMessage ??
          'Failed to update inventory';

      _showError(message);
    }
  }

  Future<void> _deleteInventory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: ColorName.dangerLight.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: ColorName.dangerLight,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Inventory?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove '
            '"${widget.item.product?.name ?? 'this inventory item'}" '
            'from your inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: ColorName.dangerLight,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success = await ref
        .read(inventoryProvider.notifier)
        .deleteInventory(widget.item.id);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory deleted successfully')),
      );
    } else {
      final message =
          ref.read(inventoryProvider).errorMessage ??
          'Failed to delete inventory';

      _showError(message);
    }
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDark ? context.customColors.danger : ColorName.dangerLight,
        content: Text(message),
      ),
    );
  }
}
