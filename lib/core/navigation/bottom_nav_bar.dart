// core/shared/widgets/bottom_nav_bar.dart

import 'package:adm_seller/core/navigation/navigation_config.dart';
import 'package:adm_seller/core/shared/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(navigationItemsProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF98001F),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          elevation: 0, // Remove default elevation
          onTap: (index) {
            // Update selected index
            ref.read(selectedIndexProvider.notifier).state = index;

            // Navigate to the selected route
            final route = items[index].route;
            context.go(route);
          },
          items: items.map((item) {
            final isSelected = items.indexOf(item) == selectedIndex;
            return BottomNavigationBarItem(
              icon: SvgNavIcon(
                assetPath: item.iconPath,
                color: isSelected
                    ? const Color(0xFF98001F) // Selected color
                    : Colors.grey, // Unselected color
                size: 24,
              ),
              activeIcon: SvgNavIcon(
                assetPath: item.activeIconPath,
                color: const Color(0xFF98001F), // Selected color
                size: 24,
                isActive: true,
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
