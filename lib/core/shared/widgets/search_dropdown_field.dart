import 'package:adm_seller/core/shared/styles/app_colors.dart';
import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:adm_seller/modules/inventory/models/inventory_models.dart';
import 'package:flutter/material.dart';

class SearchDropdownField extends StatelessWidget {
  final TextEditingController controller;

  final String label;
  final String hint;

  final IconData prefixIcon;

  final bool enabled;
  final bool readOnly;
  final bool isLoading;

  final List<InventoryOption> items;

  final InventoryOption? selectedItem;

  final ValueChanged<String> onChanged;
  final ValueChanged<InventoryOption> onSelected;

  const SearchDropdownField({
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
  Widget build(BuildContext context) {
    return Autocomplete<InventoryOption>(
      displayStringForOption: (option) => option.name,

      optionsBuilder: (textEditingValue) {
        if (items.isEmpty) {
          return const Iterable<InventoryOption>.empty();
        }

        return items;
      },

      onSelected: onSelected,

      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            if (controller.text.isNotEmpty &&
                fieldController.text != controller.text) {
              fieldController.value = controller.value;
            }

            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              enabled: enabled,
              readOnly: readOnly,
              onChanged: onChanged,
              decoration: AppStyle.inputDecoration(
                label: label,
                hint: hint,
                prefixIcon: Icon(prefixIcon),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.keyboard_arrow_down),
              ),
            );
          },

      optionsViewBuilder: (context, onSelected, options) {
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
                      backgroundColor: ColorName.primarybackground.withValues(
                        alpha: 0.08,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: ColorName.primarybackground,
                      ),
                    ),
                    title: Text(option.name, style: AppStyle.titleSmall),
                    subtitle: Text('ID: ${option.id}', style: AppStyle.caption),
                    onTap: () {
                      onSelected(option);
                    },
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
