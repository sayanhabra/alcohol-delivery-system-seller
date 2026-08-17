import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/modules/inventory/models/category_brand_data.dart';
import 'package:flutter/material.dart';

class SearchDropdownField extends StatefulWidget {
  final TextEditingController controller;

  final String label;
  final String hint;

  final IconData prefixIcon;

  final bool enabled;
  final bool readOnly;
  final bool isLoading;

  final List<CategoryBrandData> items;

  final CategoryBrandData? selectedItem;

  final ValueChanged<String> onChanged;
  final ValueChanged<CategoryBrandData> onSelected;

  const SearchDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    required this.onSelected,
    this.enabled = true,
    this.readOnly = false,
    this.isLoading = false,
    this.selectedItem,
  });

  @override
  State<SearchDropdownField> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState extends State<SearchDropdownField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // Do NOT dispose _controller (owned by parent)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<CategoryBrandData>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (!widget.enabled) return const Iterable<CategoryBrandData>.empty();
        // Return the latest items from the parent directly
        return widget.items;
      },
      onSelected: (item) {
        _controller.text = item.name;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        widget.onSelected(item);
        // Keep focus after selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.enabled) _focusNode.requestFocus();
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                labelText: widget.label,
                prefixIcon: Icon(widget.prefixIcon),
                suffixIcon: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.keyboard_arrow_down),
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
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryBrandColor = isDark ? ColorName.secondary : ColorName.primarybackground;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, minWidth: 300),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryBrandColor.withValues(
                        alpha: 0.08,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: primaryBrandColor,
                      ),
                    ),
                    title: Text(option.name, style: AppStyle.titleSmall),
                    subtitle: Text('ID: ${option.id}', style: AppStyle.caption),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
